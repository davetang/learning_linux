#!/usr/bin/env bash
#$ -S /bin/bash
#$ -N make_job
#$ -q all.q
#$ -pe make 4
#$ -cwd
#$ -j y
#$ -o make_job.log

make -j $NSLOTS
