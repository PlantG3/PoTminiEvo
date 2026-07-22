# Analysis for non-founder regions 

https://github.com/liu3zhenlab/homotools

step 1: The comparative genomics tool [chrcomp](https://github.com/liu3zhenlab/chrcomp) was employed to compare each chromosome from a non-B71 strain and the B71 genome (B71v2). The comparison identified syntenic regions. Shared syntenic regions, at least 10 kb, among all non-B71 genomes were identifed.

Run the following scripts for this step:

- [01c_chrcomp.sh](01c_chrcomp.sh)  
- [02c_synteny.sh](02c_synteny.sh)  

step 2: Each shared B71 region syntenic with all other genomes was divided into continued 10-kb windows. Each 10-kb sequence was used to search and extract its homologous sequences in all other genomes through module homocomp in package [Homotools](https://github.com/liu3zhenlab/homotools).

- [03c_seqextract.sh](03c_seqextract.sh)  

step 3: All homologous sequences of the 10-kb sequence were then clustered with CD-HIT

- [04c_clust.sh](04c_clust.sh), which calls [cdhit2group.pl](cdhit2group.pl)  

step 4: Cluster types of each 10-kb interval were converted to 0 if the cluster at least included both T47 and T3, and to 1 otherwise. These binary data were input for the segmentation that statistically merged neighboring intervals with the same cluster types (0 or 1) with a certain level of tolerance. The segmentation resulted in founder (T47/T3) chromosomal segments and non-founder chromosomal segments.

- [05c_genoPlot.R](05c_genoPlot.R)  

