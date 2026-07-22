# Alignment stack of chromosomes

For this example, sequences of chromosome 1 (chr1) were prepared in the directory of "chr1". For each genome, two files were prepared:
1. A FASTA file containing only the chr1 sequence
2. A BED file associated with chr1

The BED file is for highlighted regions with bars on chr1. The 5th column specifies the height of bars and the 7th column specifies the color of bars.
```
chr1	0	50000	.	0.15	+	#E5E5E5
chr1	25000	75000	.	0.15	+	#E5E5E5
...
```
After preparing genomic data, run [chr_stack.sh](chr_stack.sh). "homostack" is a module from package [Homotools](https://github.com/liu3zhenlab/homotools).  

