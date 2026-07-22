#!/bin/bash
#SBATCH --mem=8G

# effector DB:
effector=../../data/known.effectors.db03.fasta

# input genome
fasta=xxx
out=`basename $fasta | sed 's/.fasta//'`

# map effectors to the genome
# clone the Git repository: https://github.com/liu3zhenlab/protmap
# run protmap
perl <path_to_protmap> \
	--dna $fasta \
	--prot $effector \
	--prefix $out
	
# sort by chromosome and then by position
sort -k1,1 -k2,2n $out.miniprot.bed > $out.miniprot.tmp.bed
mv $out.miniprot.tmp.bed $out.miniprot.bed

