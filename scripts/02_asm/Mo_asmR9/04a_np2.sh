#!/bin/sh
#SBATCH --job-name=np2run
#SBATCH --output=../cache/04_npslurm.out
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00

####################################
# initiate
####################################
source 00_parameters.sh
cd $mypath

module load Java/1.8.0_192
module load SAMtools
module load GATK

ncpus=$SLURM_CPUS_PER_TASK

########################################
# input
########################################
ref=${mypath}/cache/03_${out}.${asm_version}.np/03_${out}.${asm_version}.np.fasta
ont_fastq=${mypath}/cache/01_basecall/${out}.fastq
f5Dir=${mypath}/input/fast5
fqsum_dir=${mypath}/cache/01_basecall/*/*/sequencing_summary.txt
sfw_dir=${mypath}/lib

########################################
# output
########################################
outdir=${mypath}/cache/04_${out}.${asm_version}.np2
reads=$outdir/ont.fastq                                                                            
outaln=$outdir/1o_aln
seqsumList=$outdir/2o_seqsum_list                                                                  
splitseqDir=${outdir}/3o_split                                                                     
correctDir=${outdir}/4o_correction                                                                 
np_log=${outdir}/np2_run.log  

if [ ! -d $outdir ]; then
	mkdir $outdir
fi

if [ -d $splitseqDir ]; then
	rm -rf $splitseqDir
fi
mkdir $splitseqDir

if [ -d $correctDir ]; then
	rm -rf $correctDir
fi
mkdir $correctDir

########################################
# read alignment
########################################

echo "step 1. reads and alignment"
echo "1. reads and alignment" > $np_log

## filter reads less than 5kb
seqtk seq -L 5000 $ont_fastq 1>$reads 2>>$np_log

${sfw_dir}/minimap2/minimap2 -ax map-ont --secondary=no -t $ncpus $ref $reads \
	1>${outaln}.sam 2>>$np_log

## bam and sort
samtools view -@ $ncpus -b ${outaln}.sam \
	| samtools sort -@ $ncpus -o ${outaln}.bam 2>>$np_log
samtools index -@ $ncpus ${outaln}.bam 2>>$np_log
rm ${outaln}.sam

########################################
# nanopolish
########################################
# spliting
echo "step2a. nanopolsh - split fasta"
echo "2a. split fasta" &>>$np_log
cd $splitseqDir
perl $sfw_dir/npcor/utils/split.fasta.pl --num 1 --prefix $np_prefix --decrease $ref &>>$np_log

# index reads:
echo "step2b. nanopolsh - index reads for nanopolish"
echo "2. index reads for nanopolish" &>>$np_log
## generate a list for sequencing_summary.txt, including full paths
ls -1 $fqsum_dir > $seqsumList
${sfw_dir}/nanopolish/nanopolish index -d $f5Dir -f $seqsumList $reads &>>$np_log

# run correction
echo "step2c. nanopolsh - run NP correction"
echo "3. run NP correction" &>>$np_log
cd $correctDir
for ctg in $splitseqDir/*[0-9]; do
	echo "- np: "$ctg >> $np_log
	
	${sfw_dir}/npcor/npcor \
		-n ${sfw_dir}/nanopolish \
		-f $ctg \
		-r $reads \
		-b ${outaln}.bam \
		-s $sfw_dir/npcor/utils \
		-c $np_ncpu \
		-g $np_mem_per_cpu \
		-y 1 \
        >> $np_log
done

