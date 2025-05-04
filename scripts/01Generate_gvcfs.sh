#!/bin/bash

module add samtools/1.11
module add biobambam2/2.0.168
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.7.0


INPUT_DIR=/overflow/heinzenlab/UNCbams.fastq/exome
REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa
KNOWN_SITES1=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/resources-broad-hg38-v0-Homo_sapiens_assembly38.dbsnp138.vcf
KNOWN_SITES2=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/resources-broad-hg38-v0-Homo_sapiens_assembly38.known_indels.vcf.gz

for file in $(cat samples.txt); do
  SAMPLE_NAME=$file
  echo "Processing sample: $SAMPLE_NAME"
  
  BAM_DIR=$INPUT_DIR/$SAMPLE_NAME/bams
  BAM_INPUT=$BAM_DIR/${SAMPLE_NAME}.bwamem.sorted.marked.bam
  BQSR_TABLE=$BAM_DIR/${SAMPLE_NAME}.recal_data.table
  BAM_OUTPUT=$BAM_DIR/${SAMPLE_NAME}.bwamem.sorted.marked.analysisready.bam
  
  # ---------- STEP 1: BaseRecalibrator ----------
    # STEP 1: BaseRecalibrator
    jobid1=$(sbatch -t 2- -n 20 -N 1 -p general --mem=80g \
      --output=$INPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.bqsr.out -J bqsr_$SAMPLE_NAME \
      --wrap="gatk BaseRecalibrator \
        -I $BAM_INPUT \
        -R $REF \
        --known-sites $KNOWN_SITES1 \
        --known-sites $KNOWN_SITES2 \
        -O $BQSR_TABLE")
    echo "BaseRecalibrator JobID: $jobid1"
    jobid1=${jobid1##* }
  
  # ---------- STEP 2: ApplyBQSR ----------
  jobid2=$(sbatch -t 2- --dependency=afterok:$jobid1 --mem=80g -p general \
    -J applyBQSR --output=$INPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.applyBQSR.out \
    --wrap="gatk ApplyBQSR \
      -R $REF \
      -I $BAM_INPUT \
      --bqsr-recal-file $BQSR_TABLE \
      --create-output-bam-index true \
      -O $BAM_OUTPUT")
  echo "Submitted ApplyBQSR: $jobid2"
  jobid2=${jobid2##* }
  
  # ---------- STEP 3: HaplotypeCaller per Chr + Index ----------
  
  for CHR in {1..22}; do
    GVCF_OUTPUT=$BAM_DIR/${SAMPLE_NAME}_chr${CHR}.g.vcf.gz
    LOG_OUT=$INPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.haplotypecaller_chr${CHR}.out
  
    sbatch -t 1- --dependency=afterok:$jobid2 --mem=40g -p general \
      -J hc_${SAMPLE_NAME}_chr${CHR} --output=$LOG_OUT \
      --wrap="gatk --java-options '-Xmx32g' HaplotypeCaller \
        -R $REF \
        -I $BAM_OUTPUT \
        -O $GVCF_OUTPUT \
        --dbsnp $KNOWN_SITES1 \
        -ERC GVCF \
        -OVI true \
        -L chr${CHR} && \
      gatk IndexFeatureFile --input $GVCF_OUTPUT"
  done

done 
