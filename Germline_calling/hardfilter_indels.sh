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
module add picard
module add gatk/4.1.7.0

gatk --java-options "-Xmx40g -Xms40g"  SelectVariants -V joint_genotypye_output.vcf --select-type-to-include INDEL  -O joint_indel.vcf \

echo "Indel selected" \

gatk --java-options "-Xmx40g -Xms40g" VariantFiltration -V joint_indel.vcf --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filter-name "my_indel_filter" -O filtered_indels_2.vcf \

echo "done-success"
