#!/bin/bash -l
#SBATCH --mem-per-cpu=60G
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1

# setup
vcf=<output_dir>/1o.vcf
ref=B71Ref2.fasta
out=Mo

# select variants:
gatk SelectVariants \
	-R $ref \
	-V $vcf \
	-select 'DP >= 300' \
	-select 'DP <= 50000' \
	--select-type-to-include SNP \
	--restrict-alleles-to BIALLELIC \
	-O ${out}.1.vcf &>${out}.1.log


# B71 matches REF
perl vcfbox.pl genomatch \
	-t T_B71 -g 0 \
	-o ${out}.2.B71eqREF.vcf \
	${out}.1.vcf

