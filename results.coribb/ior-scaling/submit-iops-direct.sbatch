#!/usr/bin/env bash
#SBATCH -J ior
#SBATCH --qos regular
#SBATCH -t 60:00
#SBATCH -A nstaff
#SBATCH -C haswell
#SBATCH -N 4
#SBATCH --tasks-per-node 32
#DW jobdw type=scratch access_mode=striped capacity=1TiB

IOR="/global/u2/g/glock/src/git/ior-incompress/install.cori/bin/ior"

OUTPUT_DIR="$DW_JOB_STRIPED"

set -e
set -x

# Run benchmark
for threads in 1 2 4 8 16 24 32
do
    output_f="iops-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID"
    srun -N $SLURM_NNODES -n $((SLURM_NNODES * threads)) "$IOR" \
         -a posix -F \
         -t 4k -b 1g -s 1024 -z \
         -l random \
         -w -e \
         --posix.odirect \
         -D 45 \
         -vv \
         -o "$OUTPUT_DIR/testFile" 2>&1 > "${output_f}.out"
done
