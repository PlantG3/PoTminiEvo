#!/bin/bash
#SBATCH --mem=8G
effector=../18_putativeEffector/1o_B71effector.protein.fasta
indir=../03_finishedASM
for fasta in $indir/*fasta; do
	out=`basename $fasta | sed 's/.fasta//'`
	# protmap
	perl /homes/liu3zhen/scripts2/miniprot/protmap/protmap \
		--dna $fasta \
		--prot $effector \
		--prefix $out
	
	# sort
	sort -k1,1 -k2,2n $out.miniprot.bed > $out.miniprot.tmp.bed
	mv $out.miniprot.tmp.bed $out.miniprot.bed
done

