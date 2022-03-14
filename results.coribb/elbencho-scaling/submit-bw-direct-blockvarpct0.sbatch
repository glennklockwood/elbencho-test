#!/usr/bin/env bash
#SBATCH -J elbencho
#SBATCH --qos regular
#SBATCH -t 60:00
#SBATCH -A nstaff
#SBATCH -C haswell
#SBATCH -N 4
#SBATCH --tasks-per-node 1
#SBATCH --cpus-per-task 64
#DW jobdw type=scratch access_mode=striped capacity=1TiB

ELBENCHO="../../src/elbencho/bin.cori/elbencho"

OUTPUT_DIR="$DW_JOB_STRIPED"

# Build elbencho compatible list of hostnames
HOSTNAMES=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | tr "\n" ",")

# Start service on all nodes
srun $ELBENCHO --service --foreground &

sleep 5

# Run benchmark
for threads in 1 2 4 8 16 24 32 48 64
do
    output_f="bw-direct.$(printf "%02d" $threads)threads.$SLURM_JOBID"
    $ELBENCHO --hosts "$HOSTNAMES" \
              --threads $threads \
              --files 1 --size 1t --block 1m \
              --blockvaralgo fast --blockvarpct 0 \
              --mkdirs --write --sync \
              --dirsharing --direct \
              --delfiles --deldirs \
              --timelimit 45 \
              --resfile ${output_f}.out \
              --csvfile ${output_f}.csv \
              --livecsv ${output_f}.live.csv \
              --liveint 5000 \
              --nolive \
              "${OUTPUT_DIR}"

    $ELBENCHO --hosts "$HOSTNAMES" \
              --threads $threads \
              --files 1 --size 1t --block 1m \
              --dirsharing \
              --delfiles --deldirs \
              --nolive \
              "${OUTPUT_DIR}" 2>&1 > "${output_f}.cleanup.out"
done

# Quit services
$ELBENCHO --quit --hosts "$HOSTNAMES"
