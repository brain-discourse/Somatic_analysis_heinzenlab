#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g


module load r/3.6.0
module load bedtools
module load snpeff

for f in *_roiSummary.txt ; do Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar-master/CNV_Radar_create_control.r --directory /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/  >> create_normal_cohort.log 2>&1 ; done
