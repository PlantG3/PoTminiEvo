#!/bin/sh
####################################
# initiate parameters
####################################
source 00_parameters.sh
echo $asm_version
cd $mypath
module load Java/1.8.0_192
####################################
# run canu
####################################
infastq=$mypath/cache/01_basecall/input/*/pass/*fastq
mergefastq=$mypath/cache/01_basecall/${out}.fastq
#if [ ! -f $mergefastq ]; then
cat $infastq >  $mergefastq
#fi

# run canu
echo "run canu"
$mypath/lib/canu-2.2/bin/canu \
	-d $mypath/cache/02_"$out".asm"${asm_version}" \
	-p "${out}"."${asm_version}" \
	genomeSize="$genomeSize" \
	minReadLength="$minReadLength" \
	minOverlapLength="$minOverlapLength" \
	rawErrorRate="$rawErrorRate" \
	correctedErrorRate="$correctedErrorRate" \
	corOutCoverage="$corOutCoverage" \
	-gridOptions="--time=6-00:00:00" \
	corThreads=32 \
	-gridOptionsCOR="--cpus-per-task=32" \
	-nanopore ${mergefastq} \
	&> $mypath/cache/02_"${out}".asm"${asm_version}".log

