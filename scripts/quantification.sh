#!/bin/bash
# Quantification with StringTie

source config.sh

OUTDIR=data/stringtie_quant
MERGED_GTF=data/stringtie_guided/new_merged.gtf
mkdir -p $OUTDIR

MAX_PROCS=2
COUNTER=0

quantify_stringtie() {
    local f=$1
    echo "▶ Quantifying: $f"
    stringtie data/hisat2/"$f"_sorted.bam \
        -e -B -G $MERGED_GTF \
        -o $OUTDIR/"$f"_quant.gtf
}

for f in $zebrafishaccessions; do
    quantify_stringtie "$f" &
    ((COUNTER++))
    if [ $COUNTER -ge $MAX_PROCS ]; then
        wait
        COUNTER=0
    fi
done
wait

echo "Quantification completed for all samples!"
