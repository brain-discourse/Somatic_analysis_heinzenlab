# Analysis of exome sequencing data – Heinzen Lab (2020–2021)

For this project whole exome sequencing data from individuals with malformations of cortical development were analyzed using mutect2 to detect potential pathogenic somatic variants. The data was generated using  genomic DNA surgically resected brain cortical tissues.

This repository contains workflows and scripts developed for the somatic analysis of whole exome sequencing (WES) data from individuals with malformations of cortical development (MCD).

## Project Overview

In this project, whole exome sequencing was performed on surgically resected brain cortical tissue from individuals with MCD. The primary goal was to identify known and/or novel pathogenic post-zygotic (somatic) and germline variants responsible for developmental cortical malformations.

### Key Analyses Included:
- **Quality control**
- **Somatic variant calling** using GATK Mutect2
- **Joint genotyping** and filtering of germline variants using GATK
- **Functional annotation** of variants using Annovar
- **Gene set enrichment analysis** on somatic variants detected in coverage normalized cases and control samples
- **Copy number variant (CNV) calling** using CNVradar

Due to privacy constraints, raw sequencing data are not included in this repository. However, scripts and pipeline steps are shared for reproducibility and adaptation.

## Citation

If you use or reference this work, please cite the following publication:

> Lai D, Gade M, Yang E, Koh HY, Lu J, Walley NM, Buckley AF, Sands TT, Akman CI, Mikati MA, McKhann GM, Goldman JE, Canoll P, Alexander AL, Park KL, Von Allmen GK, Rodziyevska O, Bhattacharjee MB, Lidov HGW, Vogel H, Grant GA, Porter BE, Poduri AH, Crino PB, Heinzen EL.  
> *Somatic variants in diverse genes lead to a spectrum of focal cortical malformations.*  
> Brain. 2022 Aug 27;145(8):2704–2720. doi: [10.1093/brain/awac117](https://doi.org/10.1093/brain/awac117). PMID: 35441233; PMCID: PMC9612793.
