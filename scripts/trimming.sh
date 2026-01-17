#!/bin/bash
# Quality check with FastQC and trimming with PRINSEQ


mkdir -p data/fastqc data/prinseq

source config.sh  

# FastQC
for f in $zebrafishaccessions
do
    fastqc data/raw/"$f"_1.fastq data/raw/"$f"_2.fastq -o data/fastqc &
done
wait

# PRINSEQ trimming
trim_prinseq() {
    local f=$1
    prinseq-lite.pl \
        -fastq data/raw/"$f"_1.fastq \
        -fastq2 data/raw/"$f"_2.fastq \
        -trim_ns_left 1 \
        -trim_ns_right 1 \
        -min_qual_score 20 \
        -trim_qual_left 20 \
        -trim_qual_right 20 \
        -trim_qual_type min \
        -min_len 25 \
        -out_good data/prinseq/"$f"_prinseq \
        -out_format 3
}

for f in $zebrafishaccessions
do
    trim_prinseq "$f" &
done
wait

echo "QC e trimming completati!"
