#!/bin/bash
#SBATCH --array=1-58
#SBATCH --mem-per-cpu=3g
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=16
in=`sed -n $SLURM_ARRAY_TASK_ID"p" list.txt`
sh fungi_fq_bwa_bam.parallel.sh \
	-m SAMtools \
	-c 16 \
	-r /homes/liu3zhen/references/fungi/magnaporthe/B71Ref2/genome/bwa/B71Ref2 \
    -f $in

