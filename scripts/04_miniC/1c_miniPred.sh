#!/bin/bash -l
#SBATCH --mem=8G
#SBATCH --time=6-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:geforce_rtx_2080_ti:1
#SBATCH --gres=killable:1
#SBATCH --partition=ksu-gen-gpu.q

# inputs
infq=xxx  # Illumina data (trimmed clean data)
outdir=xxx # ouput directory

# conda environment
conda activate minic

# miniC model:
k=9
kcount=11
h5model=/bulk/liu3zhen/research/projects/mini_prediction/main_minicLSTM_new/1_training/train/saved_model/model_final.h5

outbase=`basename $infq | sed 's/.pair.fq.gz//g'`
filtfq=${outdir}/${outbase}.filt.fq.gz

# filter core/mini common sequences:
infq_base=`basename $infq`
bash /homes/liu3zhen/scripts2/miniC/utils/bowtie2.filt.sh $infq $filtfq

# miniC running
pred_prob_threshold=0.99
python <path_to minicPred.py> \
    --model_path $h5model \
    --data_file $filtfq \
    --kmer_length $k \
    --kmer_count $kcount \
    --output_dir ${outdir} \
    --prediction_threshold $pred_prob_threshold \
    --save_pred_seq

# cleanup
rm $filtfq

