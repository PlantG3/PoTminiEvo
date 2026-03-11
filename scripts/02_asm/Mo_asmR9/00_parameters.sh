#!/bin/bash

# basecalling
## Nanopore data (input fullpaths of the directories containing a fast5 subdirectory)
export fast5_directories="
xxx
"
export guppy_model="/homes/liu3zhen/software/guppy/ont-guppy-cpu/data/dna_r9.4.1_450bps_hac.cfg"
export basecall_narray=5000
export basecall_cpus=8

# Canu assembly
export out=xxx
export asm_version="v0.1"
export genomeSize="45m"
export minReadLength=10000
export minOverlapLength=5000
export rawErrorRate=0.2
export correctedErrorRate=0.05
export corOutCoverage=40

# polishing
np_prefix=np
np_ncpu=8
np_mem_per_cpu=6g

## Illumina data
export pe1=xxx
export pe2=xxx

# go to working directory
export mypath=`realpath ../`

# vbz plugin
export HDF5_PLUGIN_PATH=/homes/liu3zhen/software/asm_package/vbz/ont-vbz-hdf-plugin-1.0.1-Linux/usr/local/hdf5/lib/plugin

