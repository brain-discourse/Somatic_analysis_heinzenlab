#!/bin/bash

module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk 
module load annovar/20200609

OUTPUT_DIR=/proj/heinzenlab/projects/somaticNov2020/WGS/brain_only
RAW_DIR=/overflow/heinzenlab/UNCbams.fastq/WGS

INPUT_FASTQ_BR_R1_L1=$1
INPUT_FASTQ_BR_R2_L1=$2
SAMPLE_NAME=$3

REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa

mkdir -p $RAW_DIR/$SAMPLE_NAME/bams/
mkdir -p $OUTPUT_DIR/$SAMPLE_NAME/mutect2/
mkdir -p $OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/

#BWAMEM ALIGNMENT STEP 

jobid1=$(sbatch -t 2- -n 20 -N 1 --output=/$RAW_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.bwamem.out --mem=80g -p general -J bwamem --wrap="bwa mem \
               -t 20 \
               -T 0 \
               -R '@RG\tID:${SAMPLE_NAME}\tPL:ILLUMINA\tSM:${SAMPLE_NAME}'  \
               $REF \
               $INPUT_FASTQ_BR_R1_L1 \
               $INPUT_FASTQ_BR_R2_L2 | samtools view -@ 8 -Shb - | samtools sort -@12 -n -o /$RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.bam - ")
echo $jobid1
jobid1=${jobid1##* }

#BIOBAM

jobid2=$(sbatch -t 2- --dependency=afterok:$jobid1 --mem=80g -p general -J biosortdup --output=/$RAW_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.biosortdup.out --wrap="bamsort \
	
SO=coordinate markduplicates=1 inputthreads=8 sortthreads=8 outputthreads=8 < $RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.bam > $RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.sorted.marked.bam " )
echo $jobid2
jobid2=${jobid2##* }



#SAMTOOLS INDEX

jobid3=$(sbatch -t 1- --dependency=afterok:$jobid2 --mem=40g -p general -J index.samtools --output=$RAW_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.samtools.index.out \
		--wrap="samtools index -b $RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.sorted.marked.bam" )
echo $jobid3
jobid3=${jobid3##* }



#MUTECT2 AND GATK VARIANT CALLING

tumor_bam=$RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.sorted.marked.bam

## 1. Generate OXOG metrics:

jobid4=$(sbatch -p general --nice=30 --dependency=afterok:$jobid3 -n 20 -N 1 --mem=50g -t 2-0 -J CollectSequencingArtifactMetrics --out $OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.Mutect2.out \
               --wrap="gatk CollectSequencingArtifactMetrics \
		-I $tumor_bam  \
		-O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/$SAMPLE_NAME -R $REF ") 
echo $jobid4
jobid4=${jobid4##* }


## 2. Mutect2:

jobid5=$(sbatch -p general --nice=30 --dependency=afterok:$jobid4 -n 20 -N 1 --mem=50g -t 4-0 -J mutect2 --out $OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.Mutect2.out \
		--wrap="gatk Mutect2 \
		-R $REF \
		-I $tumor_bam \
		-tumor $SAMPLE_NAME \
		--af-of-alleles-not-in-resource 0.00003125 \
		-pon /proj/heinzenlab/projects/somaticNov2020/analysisfiles/pon/af-only-gnomad.hg38.vcf.gz \
		--germline-resource /proj/heinzenlab/projects/somaticNov2020/analysisfiles/pon/af-only-gnomad.hg38.vcf.gz \
		--dont-use-soft-clipped-bases \
		--f1r2-tar-gz $OUTPUT_DIR/$SAMPLE_NAME/mutect2/f1r2_${SAMPLE_NAME}.tar.gz \
		-O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_unfiltered.vcf")
echo $jobid5
jobid5=${jobid5##* }
 

#NOTE: --annotate-with-num-discovered-alleles is not a valid option with version of GATK we have.

 
## 3. Learn Read Orientation Model 

jobid6=$(sbatch -p general --nice=30 -n 6 -N 1 --dependency=afterok:$jobid5 -J LearnReadOrientationModel.GATK --out $OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.LearnReadOrientationModel.out \
	--mem=50g -t 12:00:00 --wrap="gatk LearnReadOrientationModel \
	-I $OUTPUT_DIR/$SAMPLE_NAME/mutect2/f1r2_${SAMPLE_NAME}.tar.gz \
	-O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_read-orientation-model.tar.gz")
echo $jobid6
jobid6=${jobid6##* }

## 4. contamination table

jobid7=$(sbatch -p general --nice=30 --dependency=afterok:$jobid6 -J GetPileupSummaries --output=$OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.GetPileupSummaries.out \
        -n 6 -N 1 --mem=50g -t 05:00:00 --wrap="gatk GetPileupSummaries \
        -I $tumor_bam \
        -V /proj/heinzenlab/projects/somaticNov2020/analysisfiles/small_exac_common/small_exac_common_3.hg38.vcf.gz \
        -L /proj/heinzenlab/projects/somaticNov2020/analysisfiles/small_exac_common/small_exac_common_3.hg38.vcf.gz \
        -O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_getpileupsummaries.table")
echo $jobid7
jobid7=${jobid7##* }

jobid8=$(sbatch -p general --nice=30 -J CalculateContamination --output=$OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.CalculateContamination.out \
        --dependency=afterok:$jobid7 -n 6 -N 1 \
        --mem=50g -t 05:00:00 --wrap="gatk CalculateContamination \
        -I $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_getpileupsummaries.table \
        -tumor-segmentation $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_segments.table \
        -O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_calculatecontamination.table")
echo $jobid8
jobid8=${jobid8##* }


## 5. Filter Mutect2 Calls 

jobid9=$(sbatch -p general --nice=30 -J FilterMutectCalls --output=$OUTPUT_DIR/$SAMPLE_NAME/mutect2/out/gatk.FilterMutectCalls.out \
	--dependency=afterok:$jobid8 -n 6 -N 1 \
	--mem=50g -t 12:00:00 --wrap="gatk FilterMutectCalls \
	--reference $REF  \
	-V $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_unfiltered.vcf \
        --tumor-segmentation /$OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_segments.table \
        --contamination-table /$OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_calculatecontamination.table \
	--ob-priors $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_read-orientation-model.tar.gz \
	-O $OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_filtered.vcf")
echo $jobid9
jobid9=${jobid9##* }


INPUT_FILE=$OUTPUT_DIR/$SAMPLE_NAME/mutect2/${SAMPLE_NAME}_filtered.vcf

#generate UID 
jobid10=$(sbatch -t 2- -n 20 -N 1 --dependency=afterok:$jobid9 --output=$OUTPUT_DIR/UID.out --mem=5g -p general -J UID --wrap="bcftools annotate --set-id +'%CHROM:%POS:%REF:%FIRST_ALT' $INPUT_FILE > $OUTPUT_DIR/${SAMPLE_NAME}_filtered.UID")
echo $jobid10
jobid10=${jobid10##* }

#VCF to table 
jobid11=$(sbatch -t 2- -n 20 -N 1 --dependency=afterok:$jobid10 --output=$OUTPUT_DIR/varianttotable.out --mem=5g -p general -J vartotable --wrap="gatk VariantsToTable \
-V $OUTPUT_DIR/${SAMPLE_NAME}_filtered.UID \
-F CHROM \
-F POS \
-F ID \
-F REF \
-F ALT \
-F QUAL \
-F FILTER \
-F AS_FilterStatus \
-F ECNT \
-F DP \
-F AS_SB_TABLE \
-F GERMQ \
-F MBQ \
-F MFRL \
-F MMQ \
-F MPOS \
-F NALOD \
-F NLOD \
-F PON \
-F POPAF \
-F ROQ \
-F RPA \
-F RU \
-F STR \
-F STRQ \
-F TLOD \
-GF GT \
-GF AD \
-GF AF \
-GF DP \
-GF F1R2 \
-GF F2R1 \
-GF PGT \
-GF PID \
-GF PS \
-GF SB \
--show-filtered \
-O $OUTPUT_DIR/${SAMPLE_NAME}_filtered.table")
echo $jobid11
jobid11=${jobid11##* }

#annovar input file
jobid12=$(sbatch -t 2- -n 20 -N 1 --dependency=afterok:$jobid11 --output=$OUTPUT_DIR/convert2annovar.out --mem=5g -p general -J convert2annovar --wrap="convert2annovar.pl -format vcf4 $OUTPUT_DIR/${SAMPLE_NAME}_filtered.UID -outfile $OUTPUT_DIR/${SAMPLE_NAME}_filtered.avinput -allsample -includeinfo -withfreq")
echo $jobid12
jobid12=${jobid12##* }

#annotation tables
jobid13=$(sbatch -t 2- -n 20 -N 1 --dependency=afterok:$jobid12 --output=/proj/heinzenlab/projects/somaticNov2020/exome/brain_only/$SAMPLE_NAME/mutect2/annotables.out --mem=40g -p general -J annotables --wrap="table_annovar.pl $OUTPUT_DIR/${SAMPLE_NAME}_filtered.UID /proj/heinzenlab/projects/somaticNov2020/analysisfiles/humandb/ \
-buildver hg38 \
-out $OUTPUT_DIR/${SAMPLE_NAME}_filtered.annotated \
-remove \
-protocol refGene,cytoBand,gnomad211_exome,gnomad211_genome,gene4denovo201907,exac03,intervar_20180118,dbscsnv11,avsnp150,kaviar_20150923,dbnsfp41a,dbnsfp30a,revel,ljb26_all,regsnpintron,clinvar_20200316,kaplanis_v1,VKGL,cosmic92_coding,cosmic92_noncoding \
-operation g,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f \
-nastring . \
        -vcfinput")
echo $jobid13
jobid13=${jobid13##* }

##enhancerregions
jobid14=$(sbatch -t 2- -n 20 -N 1 --dependency=afterok:$jobid13 --output=/proj/heinzenlab/projects/somaticNov2020/exome/brain_only/$SAMPLE_NAME/mutect2/enhancer.out --mem=40g -p general -J enhancer --wrap="module load annovar/20200609
table_annovar.pl $OUTPUT_DIR/${SAMPLE_NAME}_filtered.UID  /proj/heinzenlab/projects/somaticNov2020/analysisfiles/humandb/ \
-buildver hg38 \
-out $OUTPUT_DIR/${SAMPLE_NAME}_filtered.enhancer \
-remove \
-protocol JEME_db_final,links_db_final \
-bedfile hg38_links_db_final.bed \
-operation f,f \
-nastring . \
-vcfinput")
echo $jobid14
jobid14=${jobid14##* }


##replace annotable table , with |
sed 's/,/|/g' $OUTPUT_DIR/${SAMPLE_NAME}_filtered.table > $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.table \

wait

##add sample name to annotable
awk '{print "'${SAMPLE_NAME}'\t"$0}' $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.table > $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.table \

wait

##remove decoy chr from annotable
awk 'NR==FNR {a[$1]++; next} $2 in a' /proj/heinzenlab/projects/somaticNov2020/analysisfiles/chrlist $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.table > $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.nodecoy.table \

wait

##remove other info column from multianno file
sed 's/\([ \t]\+[^ \t]*\)\{7\}$//' $OUTPUT_DIR/${SAMPLE_NAME}_filtered.annotated.hg38_multianno.txt > $OUTPUT_DIR/${SAMPLE_NAME}_filtered.annotated.hg38_multianno.selected.txt \

wait

merge multianno and annotable
perl -e ' $col1=3; $col2=-1; ($f1,$f2)=@ARGV; open(F2,$f2); while (<F2>) { s/\r?\n//; @F=split /\t/, $_; $line2{$F[$col2]} .= "$_\n" }; $count2 = $.; open(F1,$f1); while (<F1>) { s/\r?\n//; @F=split /\t/, $_; $x = $line2{$F[$col1]}; if ($x) { $num_changes = ($x =~ s/^/$_\t/gm); print $x; $merged += $num_changes } } warn "\nJoining $f1 column $col1 with $f2 column $col2\n$f1: $. lines\n$f2: $count2 lines\nMerged file: $merged lines\n"; ' $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.nodecoy.table $OUTPUT_DIR/${SAMPLE_NAME}_filtered.annotated.hg38_multianno.selected.txt > $OUTPUT_DIR/${SAMPLE_NAME}_mutect2annotated.tab \

wait

##remove last 6 columns from merged annotation table
sed 's/\([ \t]\+[^ \t]*\)\{6\}$//' $OUTPUT_DIR/${SAMPLE_NAME}_mutect2annotated.tab > $OUTPUT_DIR/${SAMPLE_NAME}_mutect2annotatedFINAL.tab

wait

##Add headers to merged annotation table
sed -i '1i SAMPLE_ID    CHROM   POS     ID      REF     ALT     QUAL    FILTER  AS_FilterStatus ECNT    DP      AS_SB_TABLE     GERMQ   MBQ     MFRL    MMQ     MPOS    NALOD   NLOD    PON     POPAF   ROQ     RPA     RU      STR     STRQ    TLOD    GT      AD      AF      DP      F1R2    F2R1    PGT     PID     PS      SB      Chr     Start   End     Ref     Alt     Func.refGene    Gene.refGene    GeneDetail.refGene      ExonicFunc.refGene      AAChange.refGene        cytoBand        gnomad_exome_AF gnomad_exome_AF_popmax  gnomad_exome_AF_male    gnomad_exome_AF_female  gnomad_exome_AF_raw     gnomad_exome_AF_afr     gnomad_exome_AF_sas     gnomad_exome_AF_amr     gnomad_exome_AF_eas     gnomad_exome_AF_nfe     gnomad_exome_AF_fin     gnomad_exome_AF_asj     gnomad_exome_AF_oth     gnomad_exome_non_topmed_AF_popmax       gnomad_exome_non_neuro_AF_popmax        gnomad_exome_non_cancer_AF_popmax       gnomad_exome_controls_AF_popmax gnomad_genome_AF        gnomad_genome_AF_popmax gnomad_genome_AF_male   gnomad_genome_AF_female gnomad_genome_AF_raw    gnomad_genome_AF_afr    gnomad_genome_AF_sas    gnomad_genome_AF_amr    gnomad_genome_AF_eas    gnomad_genome_AF_nfe    gnomad_genome_AF_fin    gnomad_genome_AF_asj    gnomad_genome_AF_oth    gnomad_genome_non_topmed_AF_popmax      gnomad_genome_non_neuro_AF_popmax       gnomad_genome_non_cancer_AF_popmax      gnomad_genome_controls_AF_popmax        gene4denovo_DN_ID       gene4denovo_Patient_ID  gene4denovo_Phenotype   gene4denovo_Platform    gene4denovo_Study       gene4denovo_Pubmed_ID   ExAC_ALL        ExAC_AFR        ExAC_AMR        ExAC_EAS        ExAC_FIN        ExAC_NFE        ExAC_OTH        ExAC_SAS        InterVar_automated      Intervar_PVS1   Intervar_PS1    Intervar_PS2    Intervar_PS3    Intervar_PS4    Intervar_PM1    Intervar_PM2    Intervar_PM3    Intervar_PM4    Intervar_PM5    Intervar_PM6    Intervar_PP1    Intervar_PP2    Intervar_PP3    Intervar_PP4    Intervar_PP5    Intervar_BA1    Intervar_BS1    Intervar_BS2    Intervar_BS3    Intervar_BS4    Intervar_BP1    Intervar_BP2    Intervar_BP3    Intervar_BP4    Intervar_BP5    Intervar_BP6    Intervar_BP7    dbscSNV_ADA_SCORE       dbscSNV_RF_SCORE        avsnp150        Kaviar_AF       Kaviar_AC       Kaviar_AN       DamagePredCount SIFT_pred       SIFT4G_pred     Polyphen2_HDIV_pred     Polyphen2_HVAR_pred     LRT_pred        MutationTaster_pred     MutationAssessor_pred   FATHMM_pred     PROVEAN_pred    VEST4_score     MetaSVM_pred    MetaLR_pred     M-CAP_pred      REVEL_score     MutPred_score   MVP_score       MPC_score       PrimateAI_pred  DEOGEN2_pred    BayesDel_addAF_pred     BayesDel_noAF_pred      ClinPred_pred   LIST-S2_pred    CADD_raw        CADD_phred      DANN_score      fathmm-MKL_coding_pred  fathmm-XF_coding_pred   Eigen-raw_coding        Eigen-phred_coding      Eigen-PC-raw_coding     Eigen-PC-phred_coding   GenoCanyon_score        integrated_fitCons_score        GM12878_fitCons_score   H1-hESC_fitCons_score   HUVEC_fitCons_score     LINSIGHT        GERP++_NR       GERP++_RS       phyloP100way_vertebrate phyloP30way_mammalian   phyloP17way_primate     phastCons100way_vertebrate      phastCons30way_mammalian        phastCons17way_primate  bStatistic      Interpro_domain GTEx_V8_gene    GTEx_V8_tissue  SIFT_score      SIFT_pred       Polyphen2_HDIV_score    Polyphen2_HDIV_pred     Polyphen2_HVAR_score    Polyphen2_HVAR_pred     LRT_score       LRT_pred        MutationTaster_score    MutationTaster_pred     MutationAssessor_score  MutationAssessor_pred   FATHMM_score    FATHMM_pred     PROVEAN_score   PROVEAN_pred    VEST3_score     CADD_raw        CADD_phred      DANN_score      fathmm-MKL_coding_score fathmm-MKL_coding_pred  MetaSVM_score   MetaSVM_pred    MetaLR_score    MetaLR_pred     integrated_fitCons_score        integrated_confidence_value     GERP++_RS       phyloP7way_vertebrate   phyloP20way_mammalian   phastCons7way_vertebrate        phastCons20way_mammalian        SiPhy_29way_logOdds     REVEL   SIFT_score      SIFT_pred       Polyphen2_HDIV_score    Polyphen2_HDIV_pred     Polyphen2_HVAR_score    Polyphen2_HVAR_pred     LRT_score       LRT_pred        MutationTaster_score    MutationTaster_pred     MutationAssessor_score  MutationAssessor_pred   FATHMM_score    FATHMM_pred     RadialSVM_score RadialSVM_pred  LR_score        LR_pred VEST3_score     CADD_raw        CADD_phred      GERP++_RS       phyloP46way_placental   phyloP100way_vertebrate SiPhy_29way_logOdds     regsnp_fpr      regsnp_disease  regsnp_splicing_site    CLNALLELEID     CLNDN   CLNDISDB        CLNREVSTAT      CLNSIG  Kaplanis_consequence    Kaplanis_symbol Kaplanis_study  Kaplanis_altprop_child  Kaplanis_hgnc_id        Kaplanis_id     Kaplanis_pos    Kaplanis_Start_hg37     Kaplanis_End_hg37       IDVKGL_c_notation       VKGL_label      VKGL_p_notation VKGL_transcript VKGL_hgvs       VKGL_gene       VKGL_classification     VKGL_support    VKGL_extra      cosmic92_coding cosmic92_noncoding' $OUTPUT_DIR/${SAMPLE_NAME}_mutect2annotatedFINAL.tab

wait

##remove temp files
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered.table \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered.avinput \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.table \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.nodecoy.table \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered_nocomma.name.table \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_mutect2annotated.tab \
##rm $OUTPUT_DIR/${SAMPLE_NAME}_filtered.annotated.hg38_multianno.selected.txt 

exit
