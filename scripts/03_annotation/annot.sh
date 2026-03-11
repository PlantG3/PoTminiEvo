#!/bin/bash
#SBATCH --cpus-per-task=48
#SBATCH --mem=48G
#SBATCH --time=10-00:00:00

ncpu=$SLURM_CPUS_PER_TASK

###############################################################################
# funannotate for Mo genome annotation
# pipeline assembled by Sanzhen Liu
# 5/3/2022
###############################################################################

###############################################################################
# module
###############################################################################
file_check () {
	infile=$1
	if [ ! -f ${infile} ]; then
		echo "${infile} does not exists"
		exit 1
	fi
}

###############################################################################
# genome data
###############################################################################
genome_unmasked_file=T_T47.v1.fasta # genome sequences
annot_id=T47a # output directory
isolate=T47 # isolate name
species="Magnaporthe oryzae" # species name
# repeat db
rep_lib=/bulk/liu3zhen/research/projects/panMoGenome/repeats/MoTL/T_T47/T_T47.v1.fasta.mod.EDTA.TElib.fa

# fullpath of genome sequences:
genome_unmasked=`realpath $genome_unmasked_file`

# check availability of inputs
file_check $genome_unmasked
file_check $rep_lib

###############################################################################
# setup to run the program in /fastscratch
###############################################################################
# run the annotation in this directory
if [ ! -z $1 ]; then
	if [ -d $1 ]; then
		rundir=$1
		echo "$rundir is a specified running path. Existing results will be reused." 
	else
		echo "Directory $rundir does not exist"
		exit 1
	fi
fi

#########################################################
tmpdir=/fastscratch/liu3zhen/annottmp # subject to change
#########################################################
curpath=$PWD
foldername=`basename $PWD`
rundir=${tmpdir}/${foldername}

if [ ! -d ${tmpdir} ]; then
	mkdir ${tmpdir}
fi

if [ ! -d ${rundir} ]; then
	mkdir ${rundir}
else
	# genearate 6 random strings
	random_str=`tr -dc A-Za-z0-9 </dev/urandom | head -c 6`
	rundir=${rundir}"_"${random_str}
	if [ ! -d ${rundir} ]; then
		mkdir ${rundir}
	else
		echo "$rundir exists, quit"
		exit 1
	fi
fi

echo "Annotation will be run at $rundir" > "0_runstart_ok"
pushd $rundir

###############################################################################

###############################################################################
# software
###############################################################################
. "/homes/liu3zhen/anaconda/etc/profile.d/conda.sh"
conda activate funannotate

phobius=/homes/liu3zhen/software/Phobius/phobius/phobius.pl
interproscan=/homes/liu3zhen/software/interproscan/interproscan-5.69-101.0/interproscan.sh
#interproscan=/homes/liu3zhen/software/interproscan/interproscan-5.65-97.0/interproscan.sh

file_check $phobius
file_check $nterproscan

##############################################################################
# input data (subject to change)
##############################################################################
# softmasked fasta
genome=`basename $genome_unmasked | sed 's/fasta$/mask.fasta/g; s/fas$/mask.fasta/g; s/fa$/mask.fasta/g'`

# RNA-seq evidence
fq1_1=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/B71/MoTB71-RNA-Lib1-5min_S1_L001.R1.pair.fq.gz
fq1_2=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/B71/MoTB71-RNA-Lib1-5min_S1_L001.R2.pair.fq.gz
fq2_1=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_MC7.R1.pair.fq
fq2_2=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_MC7.R2.pair.fq

# below RNA-seq data are NOT used
fq3_1=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_7212.R1.pair.fq
fq3_2=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_7212.R2.pair.fq
fq4_1=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_7202.R1.pair.fq
fq4_2=/bulk/liu3zhen/research/projects/mini2020/main_sl/01_TF05-1/3_MC7-RNASeq/3a_trim/TF05-1_7202.R2.pair.fq

file_check $fq1_1
file_check $fq1_2
file_check $fq2_1
file_check $fq2_2
file_check $fq3_1
file_check $fq3_2
file_check $fq4_1
file_check $fq4_2

# transcripts
transcript_se=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/B71/B71.SE.assembled.transcripts.fasta
bas1_pwl2=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/B71/B71_pwl2bas1.fas
file_check $transcript_se
file_check $bas1_pwl2

# protein
prot_1=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/proteins/Magnaporthe_oryzae.MG8.pep.all.fa
prot_2=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/proteins/uniprot_sprot.fasta
prot_3=/bulk/liu3zhen/research/projects/panMoGenome/annot/1_resources/proteins/known.effectors.db02.fasta
file_check $prot_1
file_check $prot_2
file_check $prot_3

# others
sbt=
#file_check $sbt

###############################################################################
# soft repeatmask
###############################################################################
repeatmask_ok=1_repeatmask.ok

if [ ! -f ${repeatmask_ok} ]; then
	funannotate mask \
		-i ${genome_unmasked} \
		-o ${genome} \
		-m repeatmasker \
		-l ${rep_lib} \
		--cpus $ncpu

	if [ $? -eq 0 ]; then
		touch $repeatmask_ok
	else
		echo "repeatmask error"; exit 1
	fi
fi


###############################################################################
# training
###############################################################################
training_ok=2_training.ok

if [ ! -f ${training_ok} ]; then
# use --cpus 1 to see if the problem can be solved.
	funannotate train \
		--cpus $ncpu \
		-i ${genome} \
		-o ${annot_id} \
		--left $fq1_1 $fq2_1 \
		--right $fq1_2 $fq2_2 \
		--stranded no \
		--species "$species" \
		--isolate ${isolate} --strain ${isolate} \
		--no_trimmomatic --jaccard_clip
	
	if [ $? -eq 0 ]; then
		touch $training_ok
	else
		echo "training error"; exit 1
	fi
fi

###############################################################################
# predict
###############################################################################
predict_ok=3_predit.ok

if [ ! -f ${predict_ok} ]; then
	funannotate predict -i $genome \
		--augustus_species "magnaporthe_grisea" \
		-o ${annot_id} -s "$species" \
		--protein_evidence $prot_1 $prot_2 $prot_3 \
		--transcript_evidence $transcript_se $bas1_pwl2 \
		--isolate ${isolate} \
		--strain ${isolate} \
		--name ${annot_id} \
		--cpus $ncpu
	
	if [ $? -eq 0 ]; then
		touch ${predict_ok}
	else
		echo "predict error"; exit 1
	fi
fi

###############################################################################
# update
###############################################################################
update_ok=4_update.ok

if [ ! -f ${update_ok} ]; then
	funannotate update -i ${annot_id} --cpus $ncpu
	if [ $? -eq 0 ]; then
		touch ${update_ok}
	else
		echo "update error"; exit 1
	fi
fi

###############################################################################
# phobius 
###############################################################################
phobius_ok=5_phobius.ok

if [ ! -f ${phobius_ok} ]; then
	annot_outdir=${annot_id}/annotate_misc/
	update_outdir=${annot_id}/update_results/

	protein_outfile=`ls ${update_outdir}/*.proteins.fa 2>/dev/null`

	if [ ! -z ${protein_outfile} ]; then
		if [ ! -d ${annot_outdir} ]; then
			mkdir ${annot_outdir}
		fi
		# phobius
		perl ${phobius} -short ${protein_outfile} >${annot_outdir}/phobius.results.txt
		if [ $? -eq 0 ]; then
			touch ${phobius_ok}
		else
			echo "phobius error"; exit 1
		fi
	else
		echo "no protein sequence in "${update_outdir}
		exit 1
	fi
fi

###############################################################################
# interproscan
###############################################################################
iprscan_ok=6_iprscan.ok

if [ ! -f ${iprscan_ok} ]; then
	update_outdir=${annot_id}/update_results/
	protein_outfile=`ls ${update_outdir}/*.proteins.fa 2>/dev/null`
	
	annot_outdir=${annot_id}/annotate_misc/
	ipr_outfile=${annot_outdir}/iprscan.xml

	if [ ! -z ${protein_outfile} ]; then
		if [ ! -d ${annot_outdir} ]; then
			mkdir ${annot_outdir}
		fi
		# interproscan
		temp_out=${annot_outdir}/temp
		sh $interproscan -cpu ${ncpu} -i ${protein_outfile} -f XML -o ${ipr_outfile} --tempdir $temp_out
		if [ $? -eq 0 ]; then
			touch ${iprscan_ok}
			if [ -d $temp_out ]; then
				rm -rf $temp_out
			fi
		else
			echo "Interproscan error"; exit 1
		fi
	else
		echo "no protein sequence in "${update_outdir}
		exit 1
	fi
fi

###############################################################################
# annotation
###############################################################################
annotate_ok=7_annotate.ok

if [ ! -f ${annotate_ok} ]; then
	if [ -z $sbt ]; then
		funannotate annotate -i ${annot_id} --cpus $ncpu	
		if [ $? -eq 0 ]; then touch ${annotate_ok}; fi
	else
		funannotate annotate -i ${annot_id} --cpus $ncpu --sbt $sbt
		if [ $? -eq 0 ]; then touch ${annotate_ok}; fi
	fi
fi

###############################################################################
# cp data to current directory
###############################################################################
resultcopy_ok=8_resultcopy.ok
cd ${curpath}
if [ -d  ${rundir}/${annot_id}/annotate_results ]; then
	if [ ! -d ${annot_id} ]; then
		mkdir ${annot_id}
	fi
	cp -rf ${rundir}/${annot_id}/annotate_results ${annot_id}/
	if [ $? -eq 0 ]; then touch ${result_ok}; fi
fi

# cleanup
rm 0_runstart_ok

