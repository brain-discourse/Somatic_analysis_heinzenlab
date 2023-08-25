#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=120g

module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.7.0

gatk --java-options "-Xmx40g -Xms40g -XX:ParallelGCThreads=4" GenotypeGVCFs \
 -R /proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa \
-V gendb:///proj/heinzenlab/projects/somaticNov2020/germline/genomics_workspace_chr2 \
 -G StandardAnnotation \
 -O /proj/heinzenlab/projects/somaticNov2020/germline/genotyped_chr2.vcf 
