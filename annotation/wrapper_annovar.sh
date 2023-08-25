#!/bin/bash

for filename in /proj/heinzenlab/users/meethila1/brain_only/new_samples/*_filtered.vcf

do 

sbatch --time=100:00:00 --mem=40g --job-name NGS --wrap="sh /proj/heinzenlab/users/meethila1/brain_only/new_samples/loop_testing.sh $filename"
sleep 1
done
