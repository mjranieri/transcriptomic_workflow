#!/bin/bash
# Mapping RNA-seq on zebrafish genome with HISAT2

set -e 

mkdir -p data/hisat2

GENOME_FA="data/genome/Danio_rerio.GRCz11.dna_rm.toplevel.fa"
INDEX="data/genome/zebrafish_index"

if [ ! -f "${INDEX}.1.ht2" ]; then
    echo "Building HISAT2 index from genome FASTA..."
    hisat2-build "$GENOME_FA" "$INDEX"
else
    echo "HISAT2 index already exists, skipping build."
fi

source config.sh  

map_hisat2() {
    local f=$1
    echo "Mapping $f with HISAT2..."
    
    # mapping
    hisat2 -x "$INDEX" \
        -1 data/prinseq/"$f"_prinseq_1.fastq \
        -2 data/prinseq/"$f"_prinseq_2.fastq \
        -S data/hisat2/"$f".sam \
        --no-unal --threads 8

   # convert SAM to BAM, sort, and index
    samtools view -bS data/hisat2/"$f".sam > data/hisat2/"$f".bam
    samtools sort data/hisat2/"$f".bam -o data/hisat2/"$f"_sorted.bam
    samtools index data/hisat2/"$f"_sorted.bam

    # remove temporary files
    rm data/hisat2/"$f".sam data/hisat2/"$f".bam

    echo "Mapping completed for $f"
}

for f in $zebrafishaccessions
do
    map_hisat2 "$f" &
done

wait
echo "All mappings completed!"
