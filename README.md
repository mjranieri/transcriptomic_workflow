# Transcriptome Analysis of Cold-Acclimated Zebrafish Larvae

## Sample Study Background

The dataset we are using for this tutorial comes from a transcriptomics study published in **BMC Genomics, 2013**, entitled *"Transcriptomic characterization of cold acclimation in larval zebrafish"* (Long et al., 2013).

The authors pre-exposed **96 zebrafish larvae** to cold stress for 24 hours, defined as **16°C** for these organisms. They then subjected a subset of larvae to **extreme cold stress (12°C)** for varying durations: **6, 12, 24, 36, or 48 hours**. RNA was extracted from these larvae and sequenced to study the transcriptional changes associated with cold acclimation.

The study revealed that cold stress affected genes involved in:

- **RNA splicing**  
- **Ribosome biogenesis**  
- **Protein catabolism**  

Moreover, the larvae showed **alternative splicing and promoter switching**, allowing them to produce slightly different gene isoforms. This mechanism enables the transcriptional machinery to function more efficiently under cold stress, demonstrating an adaptive molecular response to environmental change.

### Why This Dataset is Useful

This dataset is ideal for demonstrating an RNA-seq workflow because:

1. **Paired-end reads**: allows demonstration of QC, trimming, and mapping workflows.  
2. **Differential expression**: clear biological signal between control and stressed larvae.  
3. **Transcript assembly**: alternative splicing events provide real examples for transcript reconstruction and quantification.  

## Installation

1. Install **Miniconda** or **Anaconda**: [Miniconda installation guide](https://docs.conda.io/en/latest/miniconda.html)  
2. Create the Conda environment:
```bash
conda env create -f environment.yml
conda activate transcriptome_rnaseq






Although the input FASTQ files are paired-end, quality filtering with PRINSEQ can break read pairing. 
The cmpfastq step is therefore used to recover properly paired reads before alignment, following the logic of the original workflow.
