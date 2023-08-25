#!/bin/bash

filename=$1

module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard
module add gatk/4.1.7.0

gatk --java-options "-Xmx40g -Xms40g"  SelectVariants -V "$filename" --select-type-to-include INDEL -O $(basename "$filename" .ext).temp \

echo "Indels selected" \

gatk --java-options "-Xmx40g -Xms40g" VariantFiltration -V $(basename "$filename" .ext).temp --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filter-name "my_indel_filter" -O $(basename "$filename" .ext).indel \

echo "done-success"
