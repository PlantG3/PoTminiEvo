#!/bin/bash

for fasta in ../03_finishedASM/*fasta; do
	asm=`basename $fasta | sed 's/.fasta$//'`
	echo $asm
	if [ ! -d $asm ]; then
		mkdir $asm
	fi
	~/scripts2/miniC/miniscan/miniscan \
		-f $fasta \
		-o $asm \
		-p $asm \
		-l 100000 \
		-w 50000 \
		-s 25000 \
		-x
done
