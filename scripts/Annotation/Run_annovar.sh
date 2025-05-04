#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g
#SBATCH -J annovar_annot
#SBATCH --output=full_annot_%j.out

module load gatk/4.1.7.0 
module add samtools/1.11
module load annovar/20200609



DIR=/proj/heinzenlab/users/meethila1/brain_only
HUMANDB=/proj/heinzenlab/users/meethila1/humandb
SAMPLES=$DIR/mutect_filtered_samplelist.txt #txt file containing all sample names for annotation

# BED files
BED1=hg38_CCDShg18exons+2bp.CCDSv22.bed
BED2=hg38_JEME_db_final.txt
BED3=hg38_links_db_final.txt

for SAMPLE in $(cat "$SAMPLES"); do

  VCF_INPUT="$DIR/${SAMPLE}_somatic_filtered.vcf"
  VCF_UID="$DIR/${SAMPLE}_somatic_filtered.UID"
  VCF_TABLE_OUT="$DIR/${SAMPLE}_somatic_filtered.vcf.table"
  AVINPUT="$DIR/${SAMPLE}_somatic_filtered.avinput"
  AVOUTPUT="$DIR/${SAMPLE}_somatic_filtered.annotated"

  # ------------------ STEP 1: Generate Unique Identifier ------------------
  bcftools annotate --set-id +'%CHROM:%POS:%REF:%FIRST_ALT' "$VCF_INPUT" > "$VCF_UID"
  
  # ------------------ STEP 2: VCF to table  ------------------
  
  gatk VariantsToTable -V "$VCF_UID" --show-filtered -O "$VCF_TABLE_OUT"
  
  # ------------------ STEP 3: Generate annovar input file  ------------------
  
  convert2annovar.pl -format vcf4 "$VCF_UID" -outfile "$AVINPUT" \
  -allsample -includeinfo -withfreq 
  
  # ------------------ STEP 4: Region based annotation  ------------------
  
  #for CCDS exons in refseq region plus 2 bps splicing 
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED1" -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.ccds"
  
  #for JEME regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED2" -buildver hg38 -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.jeme"
  
  #for LINCS regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED3" -buildver hg38 -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.lincs"

  echo "****Region based annotation  complete****" \

# ------------------ STEP 5: Filter based annotation  ------------------
  table_annovar.pl "$VCF_UID" "$HUMANDB" \
  -buildver hg38 -out "$AVOUTPUT" \
  -remove \
  -protocol refGene,cytoBand,gnomad211_exome,gnomad211_genome,gene4denovo201907,exac03,intervar_20180118,dbscsnv11,avsnp150,kaviar_20150923,dbnsfp41a,dbnsfp30a,revel,ljb26_all,regsnpintron,clinvar_20200316,kaplanis_v1,VKGL,cosmic92_coding,cosmic92_noncoding \
  -operation g,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f \
  -nastring . \
  -vcfinput \

# ------------------ STEP 5: Filter based annotation  ------------------
python /proj/heinzenlab/users/meethila1/scripts/merge_annotations.py \
  --vcf_table "$VCF_TABLE_OUT" \
  --multianno "$AVOUTPUT.hg38_multianno.txt" \
  --ccds "$DIR/${SAMPLE}_filtered.ccds" \
  --jeme "$DIR/${SAMPLE}_filtered.jeme" \
  --lincs "$DIR/${SAMPLE}_filtered.lincs" \
  --output "$DIR/${SAMPLE}_final_annotated_merged.tsv"
  
  echo "****Annotation complete****" 
done 

