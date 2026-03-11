#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=../cache/06_pilon2slurm.out

ncpu=$SLURM_CPUS_PER_TASK

source 00_parameters.sh
cd $mypath

module load Java
module load SAMtools

########################################
ref=${mypath}/cache/05_${out}.${asm_version}.pilon1/05_${out}.${asm_version}.np2p1.fasta
outdir=cache/06_${out}.${asm_version}.pilon2

if [ ! -f $outdir ]; then
	mkdir $outdir
fi

pilonJar=$mypath/lib/pilon-1.24.jar
refname=$(basename $ref)
out_prefix=06_${out}.${asm_version}.np2p2
final_contigs=${out}.${asm_version}.pctg.fasta
log=$mypath/$outdir/pilon2.log
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
$mypath/lib/bwa/bwa mem -t $ncpu $refname $pe1 $pe2 > ${out}.sam

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

cp $outdir/${out_prefix}.fasta $mypath/output/$final_contigs

