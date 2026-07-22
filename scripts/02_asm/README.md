# Basecalling and genome assembly

Genome assembly pipelines using R9 and R10 Oxford Nanopore data were separately developed.  

For the both pipelines, input information and parameters ar4e set up in 00_parameters.sh and the rest shell scripts are excecuted step by step.  

The pipeline using R10 data including:
1. Basecalling: [01a_basecall.sh](Mo_asmR10/01a_basecall.sh)
2. Canu assembly: [02_canu.sh](Mo_asmR10/02_canu.sh)
3. First-round Pilon polishing: [03_pilon1.sh](Mo_asmR10/03_pilon1.sh)
4. Second-round Pilon polishing: [04_pilon2.sh](Mo_asmR10/04_pilon2.sh)

The pipeline using R9 data is similar to the R10 pipeline. However, two Nanopolish steps were added between Canu assembly and Pilon polishing.
- step 1: Nanopolishing with [03a_np1.sh](Mo_asmR9/03a_np1.sh) and merging polished data with [03b_np1merge.sh](Mo_asmR9/03b_np1merge.sh)
- step 2: Nanopolishing with [03a_np1.sh](Mo_asmR9/03a_np1.sh) and merging polished data with [04b_np2merge.sh](Mo_asmR9/04b_np2merge.sh)

