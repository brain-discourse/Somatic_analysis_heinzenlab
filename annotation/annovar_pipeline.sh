#!/bin/bash
	
#for filename in /proj/heinzenlab/users/meethila1/script_testing/*_filtered.vcf
#generate UID (easy merging)
#do
filename=$1
module load samtools/1.9 
bcftools annotate --set-id +'%CHROM:%POS:%REF:%FIRST_ALT' "$filename" > $(basename "$filename" .ext).UID \ 
 echo "****UID generated****" \
 
#VCF to table 
module load gatk/4.1.7.0 
gatk VariantsToTable \
-V $(basename  "$filename" .ext).UID \
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
-O $(basename "$filename" .ext).table \
    
    echo "****VariantsToTable complete****" \ 
 #annovar input file 
module load annovar/20200609  
convert2annovar.pl -format vcf4 $(basename "$filename" .ext).UID -outfile $(basename "$filename" .ext).avinput \
-allsample \
-includeinfo \
-withfreq \

	echo "****annotation table ready for region based annotation****" \


module load annovar/20200609
annotate_variation.pl $(basename "$filename" .ext).avinput /proj/heinzenlab/users/meethila1/humandb/ \
-bedfile hg38_CCDShg18exons+2bp.CCDSv22.bed \
-dbtype bed \
-regionanno \
-colsWanted 4 \
-out $(basename "$filename" .ext).bed \

echo "****Region based annotation  complete****" \

##Select columns of interest

awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$10,$13}' $(basename "$filename" .ext).bed.hg18_bed > $(basename "$filename" .ext).bed \

##Convert to tsv

tr ' ' '\t' < $(basename "$filename" .ext).bed > $(basename "$filename" .ext).bed.temp && mv $(basename "$filename" .ext).bed.temp $(basename "$filename" .ext).bed \

 ##Add headers to bed file

sed -i '1i Bed_0	Bed_Name	Bed_Chr	Bed_Start	Bed_End	Bed_Ref	Bed_Alt	Bed_1	Bed_2	ID' $(basename "$filename" .ext).bed \

echo "****bed file ready****" \


#merging databases (vcf table and bed file)


#annotation tables
module load annovar/20200609 
table_annovar.pl $(basename  "$filename" .ext).UID /proj/heinzenlab/users/meethila1/humandb/ \
-buildver hg38 \
-out $(basename "$filename" .ext).annotated \
-remove \
-protocol refGene,cytoBand,gnomad211_exome,gnomad211_genome,gene4denovo201907,exac03,intervar_20180118,dbscsnv11,avsnp150,kaviar_20150923,dbnsfp41a,dbnsfp30a,revel,ljb26_all,regsnpintron,clinvar_20200316,kaplanis_v1,VKGL,cosmic92_coding,cosmic92_noncoding \
-operation g,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f \
-nastring . \
-vcfinput \

echo "****Annotation complete****" 

done
