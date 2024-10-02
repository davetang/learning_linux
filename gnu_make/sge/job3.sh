#!/usr/bin/env bash
#$ -S /bin/bash
#$ -N job3
#$ -q all.q
#$ -cwd
#$ -l h_rt=01:00:00
#$ -l h_rss=30720M,mem_free=30720M
#$ -j y
#$ -o job3.log

export LANGUAGE=en_AU.UTF-8

sleep 10
cat 2.txt > 3.txt
echo job3 >> 3.txt
