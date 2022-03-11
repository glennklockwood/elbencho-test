#!/usr/bin/env bash
#SBATCH -J elbencho
#SBATCH -C gpu
#SBATCH -t 20:00
#SBATCH -G 0
#SBATCH -A nstaff
#SBATCH -N 4
#SBATCH -n 128

ELBENCHO="/global/u2/g/glock/src/elbencho/bin.cgpu/elbencho"
IOR="/global/u2/g/glock/src/git/n10/vast-eval/src/ior+incompress/install.cgpu/bin/ior"

OUTPUT_DIR="/vast/$USER"


set -e
set -x

# Run benchmark
for threads in 1 2 4 8 16 24 32
do
    srun -N $SLURM_NNODES -n $((SLURM_NNODES * threads)) "$IOR" \
         -a posix -F \
         -t 1m -b 1g -s 1024 \
         -l random \
         -w -e \
         --posix.odirect \
         -D 45 \
         -vv \
         -o "$OUTPUT_DIR/testFile"

#   $ELBENCHO --hosts "$HOSTNAMES" \
#             --threads $threads \
#             --files 1 --size 1t --block 1m \
#             --blockvaralgo fast --blockvarpct 100 \
#             --mkdirs --write --sync \
#             --dirsharing --direct \
#             --delfiles --deldirs \
#             --timelimit 45 \
#             --resfile bw-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.out \
#             --csvfile bw-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.csv \
#             --livecsv bw-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.live.csv \
#             --liveint 5000 \
#             --nolive \
#             "${OUTPUT_DIR}"
done
