#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g

module load gatk/4.1.7.0 
module add samtools/1.11
module load annovar/20200609



DIR=/proj/heinzenlab/users/meethila1/brain_only
HUMANDB=/proj/heinzenlab/users/meethila1/humandb
SAMPLES=/proj/heinzenlab/users/meethila1/brain_only/mutect_filtered_samplelist.txt #txt file containing all sample names for annotation

for file in $(cat "$SAMPLES"); do

# ------------------ STEP 1: Generate Unique Identifier ------------------
bcftools annotate --set-id +'%CHROM:%POS:%REF:%FIRST_ALT' $DIR/"$file"_somatic_filtered.vcf > $DIR/"$file"_somatic_filtered.UID

echo "UID generated" \

# ------------------ STEP 2: VCF to table  ------------------

gatk VariantsToTable -V $DIR/$file_somatic_filtered.UID \
--show-filtered \
-O $DIR/$file_somatic_filtered.vcf.table

echo "VCF file converted to table" \

# ------------------ STEP 3: Generate annovar input file  ------------------

convert2annovar.pl -format vcf4 $DIR/"$file"_somatic_filtered.UID -outfile $DIR/$DIR/"$file"_somatic_filtered.avinput \
-allsample \
-includeinfo \
-withfreq \

echo "annovar input ready to be annotated" \

# ------------------ STEP 4: Region based annotations  ------------------

#for CCDS exons in refseq region plus 2 bps splicing 
annotate_variation.pl $DIR/$DIR/"$file"_somatic_filtered.avinput $HUMANDB \
-bedfile hg38_CCDShg18exons+2bp.CCDSv22.bed \
-dbtype bed \
-regionanno \
-colsWanted all \
-out "$file"_somatic_filtered.bed \

#for JEME regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
annotate_variation.pl $DIR/$DIR/"$file"_somatic_filtered.avinput $HUMANDB \
-bedfile hg38_JEME_db_final.txt \
-buildver hg38 \
-dbtype bed \
-regionanno \
-colsWanted all \
-out "$file"_somatic_filtered.hg38_JEME_db.bed \

#for LINCS regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
annotate_variation.pl $DIR/$DIR/"$file"_somatic_filtered.avinput $HUMANDB \
-bedfile hg38_links_db_final.txt \
-buildver hg38 \
-dbtype bed \
-regionanno \
-colsWanted all \
-out "$file"_somatic_filtered.hg38_links_db.bed \

echo "****Region based annotation  complete****" \

done 

