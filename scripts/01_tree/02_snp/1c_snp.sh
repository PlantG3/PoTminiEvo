#!/bin/bash
bamdir=../01_aln
ref=B71Ref2.fasta
perl gatk.sbatch.pl \
        --outbase 1o \
        --bampaths $bamdir \
        --otherpara "--sample-ploidy 1" \
        --ref $ref \
        --mem 16G \
        --time "3-00:00:00"\
        --maxlen 200000
