# Nextflow DSL2 Variant Calling Pipeline

A production-style genomics pipeline built with Nextflow DSL2 and Docker containerisation, performing per-sample variant calling and cohort-level joint genotyping using GATK best practices.

---

## What This Pipeline Does

This pipeline takes aligned BAM files from multiple samples, indexes them, calls variants per sample in GVCF mode, and then performs joint genotyping across the cohort — producing a single multi-sample VCF ready for downstream filtering and analysis.

```
BAM files (samplesheet.csv)
        │
        ▼
SAMTOOLS_INDEX          → indexed BAM + .bai
        │
        ▼
GATK_HAPLOTYPECALLER    → per-sample GVCF (GVCF mode, -ERC GVCF)
        │
        ▼
GATK_JOINTGENOTYPING    → GenomicsDBImport → GenotypeGVCFs
        │
        ▼
cohort.joint.vcf        → cohort-level variant calls
```

---

## Tools & Containers

| Step | Tool | Container |
|------|------|-----------|
| BAM indexing | SAMtools 1.20 | `community.wave.seqera.io/library/samtools:1.20` |
| Per-sample variant calling | GATK 4.5.0 HaplotypeCaller | `community.wave.seqera.io/library/gatk4:4.5.0.0` |
| Joint genotyping | GATK 4.5.0 GenomicsDBImport + GenotypeGVCFs | `community.wave.seqera.io/library/gatk4:4.5.0.0` |

All containers are pulled automatically by Nextflow — no manual installation required.

---

## Project Structure

```
.
├── genomics.nf               # Main workflow
├── nextflow.config           # Configuration and profiles
├── samplesheet.csv           # Input sample list
├── modules/
│   ├── samtools_index.nf     # SAMTOOLS_INDEX process
│   ├── gatk_haplotypecaller.nf   # GATK_HAPLOTYPECALLER process
│   └── gatk_jointgenotyping.nf   # GATK_JOINTGENOTYPING process
├── data/
│   ├── reads_mother.bam
│   ├── reads_father.bam
│   └── reads_son.bam
├── ref/
│   ├── reference.fasta
│   ├── reference.fasta.fai
│   ├── reference.dict
│   └── intervals.bed
└── results/
    ├── bam/                  # Indexed BAM files
    ├── gvcf/                 # Per-sample GVCFs
    └── family_trio.joint.vcf # Final cohort VCF
```

---

## Input: Samplesheet

The pipeline accepts a CSV samplesheet with one sample per row:

```csv
sample_id,reads_bam
mother,data/reads_mother.bam
father,data/reads_father.bam
son,data/reads_son.bam
```

---

## How to Run

**Requirements:** Nextflow 23+, Docker

```bash
# Clone the repo
git clone https://github.com/Gayathrijonnalagadda/nextflow-variant-calling-pipeline
cd nextflow-variant-calling-pipeline

# Run with test profile
nextflow run genomics.nf -profile test

# Resume after a failed run
nextflow run genomics.nf -profile test -resume
```

---

## Key Nextflow Concepts Demonstrated

- **Modular DSL2 design** — each process in its own `.nf` file, imported via `include`
- **Tuple handling** — BAM and BAI passed together as a tuple between processes
- **Channel operators** — `splitCsv`, `map`, `collect` for multi-sample handling
- **GVCF mode** — per-sample calling with `-ERC GVCF` enabling scalable cohort analysis
- **Docker containerisation** — every process runs in an isolated, reproducible container
- **Output blocks** — structured result publishing to named directories
- **Config profiles** — `test` profile for local runs, extensible to HPC/cloud

---

## Pipeline Parameters

| Parameter | Description |
|-----------|-------------|
| `params.input` | Path to samplesheet CSV |
| `params.reference` | Reference genome FASTA |
| `params.reference_index` | Reference .fai index |
| `params.reference_dict` | Reference .dict file |
| `params.intervals` | Target intervals BED file |
| `params.cohort_name` | Base name for joint VCF output |

---

## Why Joint Genotyping?

Running HaplotypeCaller per-sample in GVCF mode and then combining with GenomicsDBImport + GenotypeGVCFs is GATK's recommended approach for cohort-scale variant calling. It allows each sample to be processed independently (parallelisable), while the joint genotyping step uses information across all samples simultaneously — improving sensitivity for rare variants and providing consistent genotype calls across the cohort.

---

## Learning Context

This pipeline was built as part of self-directed learning using the [Nextflow for Science — Genomics](https://training.nextflow.io) training module. It represents hands-on practice with Nextflow DSL2, Docker, and GATK best-practices variant calling workflows — skills I am actively developing alongside my Python-based bioinformatics project portfolio.

---

## Author

**Gayathri Jonnalagadda**
MSc Bioinformatics, University of Liverpool
[GitHub](https://github.com/Gayathrijonnalagadda) | [LinkedIn](https://www.linkedin.com/in/bi14025/)
