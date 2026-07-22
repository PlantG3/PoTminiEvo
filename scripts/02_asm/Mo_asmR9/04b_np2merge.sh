#!/bin/sh

source 00_parameters.sh
cd $mypath

# out directory
outdir=${mypath}/cache/04_${out}.${asm_version}.np2
correctDir=${outdir}/4o_correction
out_fasta=$outdir/04_${out}.${asm_version}.np2.fasta
cat $correctDir/$np_prefix*/polished/polished.* > $out_fasta

echo "o polished fasta can be found at:"
echo "  "${out_fasta}

