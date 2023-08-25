#!/bin/bash
filename=$1
java -jar /nas/longleaf/apps/snpeff/4.3/snpEff/SnpSift.jar annotate /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/dbSnp/All_20180418.vcf.gz "$filename" | bgzip > $(basename "$filename" .ext).annotated

