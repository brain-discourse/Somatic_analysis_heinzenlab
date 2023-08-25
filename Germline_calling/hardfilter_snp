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

gatk --java-options "-Xmx40g -Xms40g"  SelectVariants -V genotyped_chr2.vcf  --select-type-to-include SNP -O joint_snps.vcf \

echo "SNPS selected" \

gatk --java-options "-Xmx40g -Xms40g" VariantFiltration -V joint_snps.vcf --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filter-name "my_snp_filter" -O filtered_snps_2.vcf \

echo "done-success"
