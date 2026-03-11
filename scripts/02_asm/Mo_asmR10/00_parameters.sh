#!/bin/bash

# output prefix
export out=xxx

## Nanopore data (input fullpaths of the directories containing a fast5 subdirectory)
export fast5_directories="
xxx
"

## Illumina data
export pe1=xxx
export pe2=xxx

# basecalling
export guppy_model="/homes/liu3zhen/software/guppy/ont-guppy-cpu/data/dna_r10.4.1_e8.2_260bps_hac.cfg"
export basecall_narray=1000
export basecall_cpus=16

# Canu assembly
export asm_version="v0.1"
export genomeSize="45m"
export minReadLength=10000
export minOverlapLength=5000
export rawErrorRate=0.12
export correctedErrorRate=0.04
export corOutCoverage=40

## reference to compare
export ref=../lib/pasmannot/data/B71Ref2.fasta

## go to working directory
export mypath=`realpath ../`

## vbz plugin
export HDF5_PLUGIN_PATH=/homes/liu3zhen/software/asm_package/vbz/ont-vbz-hdf-plugin-1.0.1-Linux/usr/local/hdf5/lib/plugin

