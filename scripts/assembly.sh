#!/bin/bash
set -e

source config.sh

OUTDIR=data/stringtie_guided
GTF=data/genome/Danio_rerio.GRCz11.109.gtf

mkdir -p "$OUTDIR"

assemble_stringtie() {
    local f=$1
    echo "▶ Running StringTie (guided) for: $f"
    stringtie data/hisat2/"$f"_sorted.bam \
        -G "$GTF" \
        -o "$OUTDIR/$f.gtf" \
        -p 2
}

for f in $zebrafishaccessions; do
    assemble_stringtie "$f"
done

echo "Merging transcripts"
stringtie --merge \
    -G "$GTF" \
    -o "$OUTDIR/new_merged.gtf" \
    "$OUTDIR"/SRR*.gtf

echo "Guided assembly and merge completed"
