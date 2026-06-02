#!/usr/bin/perl -w
#======================================================================
# cdhit2pggb.pl 
#
# Author: Sanzhen Liu <liu3zhen@ksu.edu>
# 11/27/2021
#
# to reformat fasta data based on cd-hit clustering result
#======================================================================

use strict;
use warnings;
use Getopt::Long;

my $prefix = "postcdhit";

sub prompt {
    print <<EOF;
    Usage: perl $0 --fasta <fasta> --clust <cd-hit cluster> [options]
    [Options]
    --fasta <file>     fasta file containing all sequence in cd-hit clusters; required
    --clust <file>     cluster output from cd-hit-est; required
    --prefix <str>     output prefix ($prefix)
    --clustinfo <file> output file of clustering information ($prefix.cdhit.clust.info)
    --help          help information
EOF
exit;
}
###############################################
# parameters:
###############################################
my (@fasta, $cluster);

my %opts = ();
&GetOptions(\%opts, "fasta=s@", "clust=s", "prefix",
                    "clustinfo=s", "clustseq=s", "help");

&prompt if exists $opts{help} or !%opts;

if (!exists $opts{fasta} or !exists $opts{clust}) {
	print STDERR "Both --fasta and --clust are required\n";
	&prompt;
} else {
	@fasta = @{$opts{fasta}} if exists $opts{fasta};
	$cluster = $opts{clust} if exists $opts{clust};
}

$prefix = $opts{prefix} if exists $opts{prefix};

###############################################
# fasta sequence
###############################################
my (%fasta_seq, $seq, $name);
foreach my $efasta (@fasta) {
	open(IN, $efasta) || die;
	while (<IN>) {
		chomp;
		if (/^>(.+)/) {
			if (defined $name) {
				$fasta_seq{$name} = $seq;
			}	
			$name = $1;
			$seq = '';
		} else {
			$seq .= $_;
		}
	}
	$fasta_seq{$name} = $seq;
	close IN;
}

###############################################
# output files
###############################################
my $cluster_info_out;
if (exists $opts{clustinfo}) {
	$cluster_info_out = $opts{clustinfo};
} else {
	$cluster_info_out = $prefix.".cdhit.clust.info";
}

my $seq_out;
if (exists $opts{clustseq}) {
	$seq_out = $opts{clustseq};
} else {
	$seq_out = $prefix.".cdhit.fasta";
}

open(CLUSTINFO, ">", $cluster_info_out) || die;
###############################################
# cd-hit cluster
###############################################
#>Cluster 0
#0	60001nt, >Ki3... *
#>Cluster 1
#0	30804nt, >CML103... at +/89.42%
#1	30891nt, >CML277... at +/96.62%

my $ncluster = 0;
my (%cluster, $cluster_id, $seqname, $seqinfo);
my (%seq, %representative, %member);
open(CLUSTER, "<", $cluster) || die;
while (<CLUSTER>) {
	chomp;
	if (/^>Cluster (\d+)/) {
		$ncluster++;
		$cluster_id = $1;
	} elsif (/>(\S+)\.\.\. (.+)/) {
		$seqname = $1;
		$seqinfo = $2;
		if (exists $fasta_seq{$seqname}) {
			my $cluster_name = "c".$cluster_id;
			$seq{$seqname} = $fasta_seq{$seqname};
			#&format_print($fasta_seq{$seqname}, 80);
			if ($seqinfo eq "*") {
				# representative sequence
				$representative{$cluster_id} = $seqname;
				# = $fasta_seq{$seqname};
			} elsif ($seqinfo =~ /\+\/([\d\.]+)\%/) {
			# 1	17888nt, >Oh7B... at +/100.00%
				my $iden2rep = $1;
				$member{$cluster_id}{$seqname} = $iden2rep;
			} else {
				print STDERR "cdhit output has a nonstandard output\n";
			}
		} else {
			print STDERR "$seqname does not exist in fasta input\n";
		}
	} else {
		print STDERR "Unexpected line(s) in $cluster: \n";
		print STDERR "    $_\n";
	}
}
close CLUSTER;

# print cluster information
# cluster, seqname, representative or member, identity
my %group = ();
my @all_cluster_ids = sort {$a <=> $b} keys %representative;
foreach my $cid (@all_cluster_ids) { 
	$group{$representative{$cid}} = $cid;
	if (exists $member{$cid}) {
		my %sname_iden = %{$member{$cid}};
		foreach my $sname (sort {$sname_iden{$b} <=> $sname_iden{$a}} keys %sname_iden) { # identity from high to low
			$group{$sname} = $cid;
		}
	}
}

# output
my @taxa = sort {$a cmp $b} keys %group;
print CLUSTINFO "interval";
foreach (@taxa[1..$#taxa]) {
	print CLUSTINFO "\t$_";
}
print CLUSTINFO "\n";

my $count = 0;
foreach (@taxa) {
	if ($count == 0) {
		print CLUSTINFO "$_\t";
	} elsif ($count == $#taxa) {
		print CLUSTINFO "$group{$_}\n";
	} else {
		print CLUSTINFO "$group{$_}\t";
	}	
	$count++;
}
close CLUSTINFO;

