#!/usr/bin/env bash
#SBATCH -J elbencho
#SBATCH -C gpu
#SBATCH -t 20:00
#SBATCH -G 0
#SBATCH -A nstaff
#SBATCH -N 4
#SBATCH --tasks-per-node 1
#SBATCH --cpus-per-task 32

ELBENCHO="/global/u2/g/glock/src/elbencho/bin.cgpu/elbencho"

OUTPUT_DIR="/vast/$USER"

# Build elbencho compatible list of hostnames
HOSTNAMES=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | tr "\n" ",")

# Start service on all nodes
srun $ELBENCHO --service --foreground &

sleep 5

# Run benchmark
for threads in 1 2 4 8 16 24 32
do
    $ELBENCHO --hosts "$HOSTNAMES" \
              --threads $threads \
              --files 1 --size 1t --block 4k \
              --blockvaralgo fast --blockvarpct 100 \
              --mkdirs --write --sync \
              --dirsharing --direct --rand \
              --delfiles --deldirs \
              --timelimit 45 \
              --resfile iops-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.out \
              --csvfile iops-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.csv \
              --livecsv iops-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID.live.csv \
              --liveint 5000 \
              --nolive \
              "${OUTPUT_DIR}"
done
# Quit services
$ELBENCHO --quit --hosts "$HOSTNAMES"
