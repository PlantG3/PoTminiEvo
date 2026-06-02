#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=24G
#SBATCH --time=1-00:00:00

perl ~/scripts2/chrcomp/gcomp \
	--qry Br36.fasta \
	--qryname Br36 \
	--ref Br58.fasta \
	--refname Br58 \
	--nuc4para "--maxmatch --breaklen 500 --mincluster 500 --minmatch 20" \
	--comp chrcomp.table.txt \
	--prefix 1o_Br58_Br36 \
	--main "Br58 cores vs Br36 cores" \
	--bandcol "goldenrod3" \
	--pdfout "1o_Br58_Br36.gcomp.pdf" \
	--threads 16 \
	--invcol NA \
	--match 10000 \
	--identity 90 \
	--ygap 0.05 \
	--pdfwidth 5 \
	--pdfheight 4.5
