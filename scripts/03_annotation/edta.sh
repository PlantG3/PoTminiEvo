#!/bin/bash -l
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=1G
#SBATCH --time=6-00:00:00

. "/homes/liu3zhen/anaconda3/etc/profile.d/conda.sh"
export PATH="/homes/liu3zhen/anaconda3/bin:$PATH"
conda activate edta

genome=T_T47.v1.fasta
curated=1o_MgRepeats.DB.v0.1.fasta

EDTA.pl \
	--genome $genome \
	-sensitive 1 \
	--anno 1 \
	--evaluate 1 \
	--curatedlib $curated \
	--threads 32

