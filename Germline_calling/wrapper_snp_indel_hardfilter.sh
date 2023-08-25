#!/bin/bash

for filename in /proj/heinzenlab/projects/somaticNov2020/germline/genotyped_vcfs/*.vcf

do 

sbatch --time=100:00:00 --mem=80g --job-name SNP --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/genotyped_vcfs/Hardfilter_SNPs $filename"
sleep 1
done
