#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --mem=64G

out=3o_hlstack
for chrnum in `seq 7`; do
	chr="chr"$chrnum
	# homostack
	perl ~/scripts2/homotools/homostack \
		--seq $chr/L_ATCC64557.v1.fasta --annot $chr/L_ATCC64557.v1.minic.hl.bed \
		--seq $chr/L_TF05-1.v1.fasta --annot $chr/L_TF05-1.v1.minic.hl.bed \
    	--seq $chr/L_LpKY97.v1.fasta --annot $chr/L_LpKY97.v1.minic.hl.bed \
    	--seq $chr/T_T47.v1.fasta --annot $chr/T_T47.v1.minic.hl.bed \
	    --seq $chr/T_T3.v1.fasta --annot $chr/T_T3.v1.minic.hl.bed \
    	--seq $chr/T_B71.v2.fasta --annot $chr/T_B71.v2.minic.hl.bed \
    	--seq $chr/T_16MOT01.v1.fasta --annot $chr/T_16MOT01.v1.minic.hl.bed \
   		--seq $chr/T_OKI18.v1.fasta --annot $chr/T_OKI18.v1.minic.hl.bed \
    	--seq $chr/T_T21.v1.fasta --annot $chr/T_T21.v1.minic.hl.bed \
    	--seq $chr/T_NE20.v1.fasta --annot $chr/T_NE20.v1.minic.hl.bed \
    	--seq $chr/T_Br48.v1.fasta --annot $chr/T_Br48.v1.minic.hl.bed \
    	--seq $chr/T_B2.v1.fasta --annot $chr/T_B2.v1.minic.hl.bed \
    	--seq $chr/T_P3.v1.fasta --annot $chr/T_P3.v1.minic.hl.bed \
		--identity 90 --match 30000 \
		--title $chr \
		--prefix $out \
		--cleanup \
		--seqheight 0.15 \
		--minident 90 \
		--maxident 100 \
		--threads 24
	# rename pdf
	mv ${out}/${out}.3.alnstack.pdf ${out}/${chr}.alnstack.pdf
done

