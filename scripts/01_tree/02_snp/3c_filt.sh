#!/bin/bash
in=Mo.2.B71eqREF.vcf
prefix=Mo.3
vcftools --vcf $in --maf 0.1 --max-missing 0.2 --recode --out $prefix
/homes/liu3zhen/software/vcf2phylip/vcf2phylip.py -i ${prefix}.recode.vcf -f -m 8
perl ~/scripts2/vcfbox/vcfbox.pl recode ${prefix}.recode.vcf > ${prefix}.recode.txt

