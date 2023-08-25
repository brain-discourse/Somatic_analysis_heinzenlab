#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=130g

module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.7.0

gatk --java-options "-Xmx60g -Xms60g" GenomicsDBImport --genomicsdb-workspace-path /proj/heinzenlab/projects/somaticNov2020/germline/genomics_workspace_chr2  --batch-size 50 --sample-name-map /proj/heinzenlab/projects/somaticNov2020/germline/sample_map.map -R /proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa --consolidate true --reader-threads 5 -L chr2

####Example sample map file 
#fcde191bl	/overflow/heinzenlab/UNCbams.fastq/exome/fcde191bl/bams/fcde191bl.g.vcf.gz
#fcde191br	/overflow/heinzenlab/UNCbams.fastq/exome/fcde191br/bams/fcde191br.g.vcf.gz
#COLE122BR	/overflow/heinzenlab/UNCbams.fastq/exome/COLE122BR/bams/COLE122BR.g.vcf.gz
#COLE133BR	/overflow/heinzenlab/UNCbams.fastq/exome/COLE133BR/bams/COLE133BR.g.vcf.gz
