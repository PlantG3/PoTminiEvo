#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=2g
#SBATCH --time=1-00:00:00

fasta=../02_snp/Mo.3.recode.min8.fasta
in=MoTmini88
ln -s $fasta $in

# iqtree2
iqtree2 -s $in -bb 10000 -m MFP -nt 24 -redo

