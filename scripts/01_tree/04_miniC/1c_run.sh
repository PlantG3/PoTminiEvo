#!/bin/bash
#SBATCH --time=6-00:00:00
outdir=_predout
if [ ! -d $outdir ]; then
	mkdir $outdir
fi

ls ../../00_fastq/*R1.pair.fq.gz -1 | sed 's/.*\///' | sed 's/.R1.pair.fq.gz//' > 1i_isolate_list.txt
readarray -t strains <<< "$(cat 1i_isolate_list.txt)"

for strain in "${strains[@]}"; do
	echo "$strain"
	fq1=/bulk/liu3zhen/research/projects/panMoGenome/main_MoTmini/00_fastq/${strain}.R1.pair.fq.gz
	fq2=/bulk/liu3zhen/research/projects/panMoGenome/main_MoTmini/00_fastq/${strain}.R2.pair.fq.gz
	
	if [ -f $fq1 ]; then
		sbatch 1m_predRun.sh $fq1 $outdir
	fi
	
	if [ -f $fq2 ]; then
		sbatch 1m_predRun.sh $fq2 $outdir
	fi
done

