#!/bin/bash
# FASTQ download from the SRA and adding /1 and /2 identifiers

mkdir -p data/raw

# Lista degli accession numbers
source config.sh

download_sra() {
    local f=$1
    fastq-dump "$f" --split-files -O data/raw -I -F
    sed -i '' '/^+HW/ s/$/\/1/' data/raw/"$f"_1.fastq
    sed -i '' '/^+HW/ s/$/\/2/' data/raw/"$f"_2.fastq
    sed -i '' '/^@HW/ s/$/\/1/' data/raw/"$f"_1.fastq
    sed -i '' '/^@HW/ s/$/\/2/' data/raw/"$f"_2.fastq
}

for f in $zebrafishaccessions
do
    download_sra "$f" &
done
wait

echo "Downloaded"

