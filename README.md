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

### Deviations from the original workflow
This project is inspired by the original RNA-seq workflow described in the referenced paper. Several of the tools used in the original workflow are now obsolete, unmaintained, or difficult to install on modern systems due to severe dependency and versioning issues (e.g. reliance on Python 2.7 and deprecated aligners).

| Original tool (deprecated)      | Replacement used in this project |
|----------------------------|----------------------------------|
| TopHat                     | HISAT2                           |
| Cufflinks / cuffmerge / cuffdiff| StringTie                        |
| IGVtools (old versions)    | Modern IGV-compatible outputs    |
| Legacy SAMtools workflows  | Updated SAMtools                 |

The workflow also includes tools that were not part of the original pipeline, but are now standard in RNA-seq analysis:
- **fastqc / fastp** – quality control and trimming
- **bedtools** – genomic interval operations
- **DESeq2** and **ballgown** – differential expression analysis

## Installation

1. Install **Miniconda** or **Anaconda**: [Miniconda installation guide](https://docs.conda.io/en/latest/miniconda.html)  
2. Create the Conda environment:
```bash
conda env create -f environment.yml
conda activate tx_workflow
```
## Download of RNA‑seq data

RNA‑seq FASTQ files corresponding to the samples from the study were downloaded from SRA using the provided accession numbers.
```bash
bash scripts/download_fastq.sh
```
For practical reasons, only this subset was used:
| Accession | Condition |
|-----------|-----------|
| SRR633516 | ck        |
| SRR633540 | ck        |
| SRR633541 | ck        |
| SRR633544 | cold      |
| SRR633545 | cold      |

> **Note:** The `config.sh` file contains a variable with all the SRR accession numbers of the paper.

## Quality Control and Trimming with FastQC and PRINCEQ
```bash
bash scripts/trimming.sh
```
PRINSEQ is used to remove reads with minimum quality score < 20 and discard reads shorter than 25 nucleotides.
Trimmed reads are saved in the `data/prinseq`

## Compare paired-end reads with cmpfastq
Although the input FASTQ files are paired-end, quality filtering with PRINSEQ can break read pairing. 
The cmpfastq step is therefore used to recover properly paired reads before alignment, following the logic of the original workflow.

```bash
perl scripts/cmpfastq.pl data/prinseq/<ACCESSION>_prinseq_1.fastq data/prinseq/<ACCESSION>_prinseq_2.fastq > data/cmpfastq/<ACCESSION>_cmpfastq.txt
```
The output files are written to the directory `data/cmpfastq`.

Although the input FASTQ files are paired-end, quality filtering with PRINSEQ can break read pairing. 
The cmpfastq step is therefore used to recover properly paired reads before alignment, following the logic of the original workflow.

## Mapping
Download the zebrafish reference genome
```bash
mkdir -p data/genome
wget -O data/genome/Danio_rerio.GRCz11.dna_rm.toplevel.fa.gz ftp://ftp.ensembl.org/pub/release-109/fasta/danio_rerio/dna/Danio_rerio.GRCz11.dna_rm.toplevel.fa.gz
gunzip data/genome/Danio_rerio.GRCz11.dna_rm.toplevel.fa.gz
```
All quality-checked and trimmed paired-end reads are aligned to the zebrafish genome using HISAT2.
```bash 
bash scripts/mapping.sh
```
The script converts the resulting SAM files into sorted and indexed BAM files for downstream analysis.

## Transcript assembly (reference-guided)
Before running the assembly, the reference gene annotation must be downloaded.
For this analysis, the Ensembl GTF annotation was used:
```bash
wget -P data/genome \
ftp://ftp.ensembl.org/pub/release-109/gtf/danio_rerio/Danio_rerio.GRCz11.109.gtf.gz
gunzip data/genome/Danio_rerio.GRCz11.109.gtf.gz
```
StringTie reconstructs transcripts for each sample individually. All sample-level assemblies are then merged into a single, unified transcript annotation.
```bash
bash scripts/assembly.sh
```
The output of this step is a merged GTF file (`data/stringtie_guided/new_merged.gtf`) that combines all assemblies.

## Expression quantification

Gene and transcript expression levels are quantified using StringTie
```bash
bash scripts/quantification.sh
```
The merged transcript annotation (new_merged.gtf) is used as a fixed reference.
For each sample, StringTie is run on the corresponding sorted BAM file to estimate transcript and gene expression levels:

```bash
stringtie data/hisat2/<SRR>_sorted.bam \
    -e -B \
    -G data/stringtie_guided/new_merged.gtf \
    -o data/stringtie_quant/<SRR>_quant.gtf
```
## Differential expression analysis
Prepare count matrices
```python
python scripts/prepDE.py
```
The output results/gene_count_matrix.csv is then used in the notebook `notebooks/differential_expression.ipynb`for DE analysis.

DE analysis is carried out using DESeq2. 
After running DESeq2, we filter for genes with sufficient expression and significant differential expression:

```bash
# Filter for genes with baseMean > 10
res_filt = res_df[res_df["baseMean"] > 10]

# Significant DEGs: |log2FC| > 1 and padj < 0.05
de_genes_sig = res_filt[(res_filt["log2FoldChange"].abs() > 1) & (res_filt["padj"] < 0.05)]
```
To visualize the most significant DEGs, a clustered heatmap (`results/figures/top30_DEGs_heatmap.png`) is generated based on the top 30 genes sorted by p-value. This heatmap highlights patterns of gene expression across samples, making it easier to identify co-regulated genes or condition-specific signatures.

### Functional enrichment analysis
The DEGs are mapped to Ensembl gene IDs using `gprofiler`. Only genes with valid Ensembl IDs are retained for enrichment analysis. Only terms with a minimum number of genes (e.g., `intersection_size >= 10`) are shown, and the top 10 terms by significance are plotted using a bar plot (`results/figures/functional_enrichment_top10.png`).

The functional enrichment analysis of the DEGs highlighted biological processes such as metabolic pathways, RNA splicing, and protein catabolic process, with KEGG pathways like spliceosome being significantly enriched. These results are consistent with those reported in the original paper, where enrichment of RNA splicing, ribosome biogenesis, and protein catabolic process was observed among genes upregulated by cold.




