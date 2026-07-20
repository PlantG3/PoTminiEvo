#!/bin/bash
in=Mo.2.B71eqREF.vcf
prefix=Mo.3

# filtering based on minor allele frequence and missing data rates
vcftools --vcf $in --maf 0.1 --max-missing 0.2 --recode --out $prefix

# format and keep SNP loci with at least 8 genotyped samples
# FASTA output was generated
vcf2phylip.py -i ${prefix}.recode.vcf -f -m 8

