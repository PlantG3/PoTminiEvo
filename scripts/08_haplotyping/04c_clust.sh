#!/bin/bash
chr=chr1
outdir=04o_clust
if [ ! -d $outdir ]; then
	mkdir $outdir
fi

#03o_chr1.interval.100.merged.fasta
for fasta in 03o_chr1/*merged.fasta; do
	out=`basename $fasta | sed 's/.*interval.//' | sed 's/.merged.fasta//'`
	~/software/cdhit/cd-hit-est -sc 1 -d 30 -g 1 -s 0.95 -c 0.99 -r 0 -i $fasta -o 04o_tmp
	perl cdhit2group.pl --fasta $fasta --clust 04o_tmp.clstr --clustinfo $outdir/$chr.interval.$out.clustinfo
	rm 04o_tmp*
done

# merge
# merged 26 only has one sequence, which caused different outputs
# "grep -P "\tinterval" -v" was introduced to solve the issue
cat $outdir/* | awk '!unseen[$1]++' | grep -P "\tinterval" -v > 04o_clust.txt


