#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g

module load r/3.6.0
module load bedtools
module load snpeff

for filename in `cat /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/bam.list.txt`

do 
sbatch --time=100:00:00 --mem=8g --job-name unzip --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/gen.roi.sh $filename"

sleep 1
done
