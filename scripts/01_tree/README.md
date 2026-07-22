# SNP variants

1. Clean reads were aligned to the B71 reference genome with [BWA](https://github.com/lh3/BWA)
   - Alignments were subjected to filtering. Both alignments and filtering were implemented in [fungi_fq_bwa_bam.parallel.sh](01_aln/fungi_fq_bwa_bam.parallel.sh)   
   - Alignment&filtering jobs were run on a Slurm system. Command "esbatch" from [easysbatch](https://github.com/liu3zhenlab/easysbatch.git) was used for a batch submission.  

2. Genomic variant calling was conducted with [GATK4](https://github.com/broadinstitute/gatk)
   - GATK module HaplotypeCaller was implemented in [gatk.sbatch.pl](02_snp/gatk.sbatch.pl)
   - SNPs supported by reasonable read depths were selected using GATK module SelectVariants
   - Only SNPs with B71 genotypes matching the B71 reference genome remained via [vcfbox.pl](02_snp/vcfbox.pl)
   - Variant genotyping data were formated using [vcf2phylip.py](02_snp/vcf2phylip.py) 

3. A maximum likelihood tree was constructed with [iqtree2](https://github.com/iqtree/iqtree2)  
   - The procedure was implemented in [1c_iqtree2.sh](03_tree/1c_iqtree2.sh)

