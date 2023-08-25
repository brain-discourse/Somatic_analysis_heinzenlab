#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=320g
module load r/4.0.1
module load bedtools
module load snpeff/4.3

Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar.r -c /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/cnvradar_normal_cohort.RData -r /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304_ATTCCATA-TGCCTGGT_S1_sorted_roiSummary.txt -v /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304.g.vcf.gz.annotated  -G
