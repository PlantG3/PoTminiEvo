#!/bin/bash
#SBATCH --time=3-00:00:00
#SBATCH --mem=8G
ref=`realpath ../../03_finishedASM/T_B71.v2.fasta`
chr="chr1"
abs_fasta_dir=`realpath ../../07_chrstack/${chr}`
outdir=03o_$chr
if [ ! -d $outdir ]; then
	mkdir $outdir
fi

abs_outdir=`realpath $outdir`

bedtools makewindows -b 02o_$chr.synteny.bed -w 10000 > 03o_$chr.synteny.10kb.bed

nentry=`wc -l 03o_$chr.synteny.10kb.bed | sed 's/ .*//'`

#entry=1
for entry in `seq $nentry`; do
	head 03o_$chr.synteny.10kb.bed -n $entry | tail -n 1 > $abs_outdir/03o_$chr.interval.$entry.bed
	bedtools getfasta -fi $ref -bed $abs_outdir/03o_$chr.interval.$entry.bed -fo $abs_outdir/03o_$chr.interval.$entry.fasta
	cp $abs_outdir/03o_$chr.interval.$entry.fasta $abs_outdir/03o_${chr}.interval.${entry}.merged.fasta
	
	#if [ -f $abs_outdir/03o_${chr}.interval.${entry}.merged.fasta ]; then
	#	rm $abs_outdir/03o_${chr}.interval.${entry}.merged.fasta
	#fi

	pushd $abs_outdir

	for fasta in $abs_fasta_dir/T*fasta; do
		genome=`basename $fasta | sed 's/.fasta//'`
		cp $fasta $genome.fasta
		makeblastdb -dbtype nucl -in $genome.fasta
		perl ~/scripts2/homotools/homocomp \
			--query 03o_$chr.interval.$entry.fasta \
			--match 5000 \
			--expand 2 \
			--db $genome.fasta \
			--dbacc $chr \
			--ref $genome.fasta \
			--prefix $genome
	
		cat */*4.target.fas >> 03o_${chr}.interval.${entry}.merged.fasta
		# cleanup
		rm $genome* -rf
	done
	
	# modify sequence names
	#sed -i 's/(.*//' 03o_${chr}.interval.${entry}.merged.fasta
	sed -i 's/\:.*(.*//' 03o_${chr}.interval.${entry}.merged.fasta

	popd
	
	# cleanup
	rm $abs_outdir/03o_$chr.interval.$entry.bed
	rm $abs_outdir/03o_$chr.interval.$entry.fasta
done
