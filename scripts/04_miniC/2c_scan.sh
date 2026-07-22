#!/bin/bash
# scan each sequence of a genome for understanding if each region is mini-like or core-like.

# input genome
fasta=xxx
asm=`basename $fasta | sed 's/.fasta$//'`
# create an output directory:
if [ ! -d $asm ]; then
	mkdir $asm
fi

# command miniscan from miniC (https://github.com/PlantG3/miniC) 
~/scripts2/miniC/miniscan/miniscan \
	-f $fasta \
	-o $asm \
	-p $asm \
	-l 100000 \
	-w 50000 \
	-s 25000 \
	-x
