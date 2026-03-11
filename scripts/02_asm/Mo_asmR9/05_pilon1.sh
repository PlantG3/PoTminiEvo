#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=../cache/05_pilon1slurm.out

ncpu=$SLURM_CPUS_PER_TASK

source 00_parameters.sh
cd $mypath

module load Java
module load SAMtools

########################################
ref=${mypath}/cache/04_${out}.${asm_version}.np2/04_${out}.${asm_version}.np2.fasta
outdir=cache/05_${out}.${asm_version}.pilon1

if [ ! -f $outdir ]; then
	mkdir $outdir
fi

pilonJar=$mypath/lib/pilon-1.24.jar
refname=$(basename $ref)
out_prefix=05_${out}.${asm_version}.np2p1
newasm=${out_prefix}.fasta
log=$mypath/$outdir/pilon.log
#########################################

# tmp directory
tmpdir=$outdir/1otmp
mkdir $tmpdir

# aln
cd $tmpdir
ln -s $ref .
$mypath/lib/bwa/bwa index $refname
out=1o-read2asm
# alignment
$mypath/lib/bwa/bwa mem -t $ncpu $refname $pe1 $pe2 >${out}.sam

# sam2bam
samtools view -@ $ncpu -b ${out}.sam | samtools sort -@ $ncpu -o ${out}.sort.bam
samtools index ${out}.sort.bam

cd $mypath

# pilon
java -Xmx32g -jar $pilonJar \
        --genome $tmpdir/$refname \
        --frags $tmpdir/${out}.sort.bam \
        --output $out_prefix \
        --outdir $outdir \
        --minmq 40 \
        --minqual 15 \
        --fix bases \
        --changes --vcf &>$log

# modify sequence names
sed -i 's/_pilon//g' $outdir/${out_prefix}.fasta

# cleanup
rm -rf $tmpdir

