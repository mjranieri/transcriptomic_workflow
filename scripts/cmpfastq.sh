#!/bin/bash
# Compare paired-end fastq files with cmpfastq

source config.sh  # zebrafishaccessions

for f in $zebrafishaccessions
do
    perl scripts/cmpfastq.pl \
        data/prinseq/"$f"_prinseq_1.fastq \
        data/prinseq/"$f"_prinseq_2.fastq \
        > data/cmpfastq/"$f"_cmpfastq.txt
done

echo "cmpfastq analysis completed!"
