#!/usr/bin/env bash
#SBATCH -J ior
#SBATCH -C gpu
#SBATCH -t 60:00
#SBATCH --gpus-per-task 0
#SBATCH -A nstaff
#SBATCH -N 4
#SBATCH --tasks-per-node 64
#SBATCH -A nstaff_g

IOR="/global/u2/g/glock/src/git/ior-incompress/install.perlmutter/bin/ior"

OUTPUT_DIR="/pscratch/sd/g/glock/ost100"

set -e
set -x

# Run benchmark
for threads in 1 2 4 8 16 24 32 48 64
do
    output_f="bw-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID"
    srun -N $SLURM_NNODES -n $((SLURM_NNODES * threads)) "$IOR" \
         -a posix -F \
         -t 1m -b 1g -s 1024 \
         -l random \
         -w -e \
         --posix.odirect \
         -D 45 \
         -vv \
         -o "$OUTPUT_DIR/testFile" 2>&1 > "${output_f}.out"
done
