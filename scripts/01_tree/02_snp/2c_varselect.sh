#!/bin/bash -l
#SBATCH --mem-per-cpu=60G
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1

#module load Java/1.8.0_192

# generate a bam list
vcf=1o_TueOct151720442024/1o.vcf
ref=/homes/liu3zhen/references/fungi/magnaporthe/B71Ref2/genome/gatk/B71Ref2.fasta
out=Mo
gatk SelectVariants \
	-R $ref \
	-V $vcf \
	-select 'DP >= 300' \
	-select 'DP <= 50000' \
	--select-type-to-include SNP \
	--restrict-alleles-to BIALLELIC \
	-O ${out}.1.vcf &>${out}.1.log


#############################
# remove redundancy of T-B2
#############################
#perl ~/scripts2/vcfbox/vcfbox.pl select -f list ${out}.1.vcf > ${out}.1.tmp.vcf

# B71 matches REF
perl ~/scripts2/vcfbox/vcfbox.pl genomatch \
	-t T_B71 -g 0 \
	-o ${out}.2.B71eqREF.vcf \
	${out}.1.vcf

# modify strain names
#sed -i 's/_[ES]RR[0-9]*//g' Mo.2.B71eqREF.vcf
#sed -i 's/-1\t/\t/g' Mo.2.B71eqREF.vcf
#sed -i 's/_3\t/\t/g' Mo.2.B71eqREF.vcf

