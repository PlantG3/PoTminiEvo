#!/bin/bash
. "/homes/liu3zhen/anaconda/etc/profile.d/conda.sh"
conda activate syri
ref=`realpath ../../07_chrstack/chr1/T_B71.v2.fasta`
refname="T_B71.v2"
chr="chr1"
indir=../../07_chrstack/${chr}
indir_abspath=`realpath $indir`
outdir=01o_$chr
if [ ! -d $outdir ]; then
	mkdir $outdir
fi
pushd $outdir
for fasta in ${indir_abspath}/*fasta; do
	genome=`basename $fasta | sed 's/.fasta//'`
	perl ~/scripts2/chrcomp/chrcomp \
		--qry $fasta \
		--ref $ref \
		--qchr $genome \
		--rchr $refname \
		--newqchr $chr \
		--newrchr $chr \
		--prefix $genome \
		--syriOption "--nosnp --invgaplen 1000000 --allow-offset 100"
done
popd
