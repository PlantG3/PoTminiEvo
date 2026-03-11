#!/bin/sh

####################################
# initiate parameters
####################################
source 00_parameters.sh
cd $mypath

####################################
# input folder 
####################################
infolder=input/fast5

if [ ! -d input ]; then
	mkdir input
fi

if [ ! -d $infolder ]; then
	mkdir $infolder
fi

cd $infolder

for ef5dir in $fast5_directories; do
	echo $ef5dir
	if [ ! -d $ef5dir/fast5 ]; then
		echo "no fast5 subdirectory in $ef5dir"
		exit
	fi
	# softline
	ln -s -f $ef5dir/fast5/*fast5 .
done

cd $mypath

# create a output folder
outdir=cache/01_basecall

if [ ! -d cache ]; then
	mkdir cache
fi

if [ ! -d $outdir ]; then
	mkdir $outdir
fi

####################################
# base call using cpu
####################################
guppy_script=lib/cpuGuppy
$guppy_script \
	-d input \
	-o $outdir\
    -c $guppy_model \
    -n $basecall_narray \
    -u $basecall_cpus

