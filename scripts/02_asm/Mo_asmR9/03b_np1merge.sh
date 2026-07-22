#!/bin/sh

source 00_parameters.sh
cd $mypath

# out directory
outdir=${mypath}/cache/03_${out}.${asm_version}.np
correctDir=${outdir}/4o_correction
#np_prefix=np # this was defined in 00_parameters.sh
cat $correctDir/$np_prefix*/polished/polished.* > $outdir/03_${out}.${asm_version}.np.fasta

echo "o polished fasta can be found at:"
echo "  "$outdir/03_${out}.${asm_version}.np.fasta

