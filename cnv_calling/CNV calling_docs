#Panel of normals  - need to be sequenced using same technology 
###Generate region of interest summary for PON
#######BAM to ROI wrapper 
#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g

module load r/3.6.0
module load bedtools
module load snpeff

for filename in `cat /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/bam.list.txt`

do 
sbatch --time=100:00:00 --mem=8g --job-name unzip --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/gen.roi.sh $filename"

sleep 1
done
#here bam.list.txt looks like:
/overflow/heinzenlab/UNCbams.fastq/exome/erka123leuko/bams/erka123leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka17pbmc/bams/erka17pbmc.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka313leuko/bams/erka313leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka314leuko/bams/erka314leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/uth0020bl/bams/uth0020bl.bwamem.sorted.marked.bam

########Generate ROI 
#!/bin/bash
filename=$1

Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar-master/bam2roi.r -b "$filename"  -d /proj/heinzenlab/projects/somaticNov2020/analysisfiles/CCDShg18exons+2bp.GRCh38.p12.CCDSv22.bed -z >> bam2roi.log 2>&1


########Create PON
#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g


module load r/3.6.0
module load bedtools
module load snpeff

for f in *_roiSummary.txt ; do Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar-master/CNV_Radar_create_control.r --directory /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/  >> create_normal_cohort.log 2>&1 ; done

#Actual analysis on real samples 
######Generate ROI (same as above) 
######Annotate (wrapper script)
*gvcfs need to be generated to be able to annotate these files and utilize them for CNV calling 
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=140g

module load r/3.6.0
module load bedtools
module load snpeff/

for filename in `cat /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/vcf.list`
do 
sbatch --time=100:00:00 --mem=8g --job-name unzip --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/Agilent/annotate.sh $filename"
sleep 1
done

#########Annotate files 
#!/bin/bash
filename=$1
java -jar /nas/longleaf/apps/snpeff/4.3/snpEff/SnpSift.jar annotate /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/dbSnp/All_20180418.vcf.gz "$filename" | bgzip > $(basename "$filename" .ext).annotated


########CNV calling (once the annotation, PON, and roi files are ready, run this) 
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=320g
module load r/4.0.1
module load bedtools
module load snpeff/4.3

Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar.r -c /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/cnvradar_normal_cohort.RData -r /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304_ATTCCATA-TGCCTGGT_S1_sorted_roiSummary.txt -v /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304.g.vcf.gz.annotated  -G


#################to print output for specific chromosome 
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=100g

module load r/4.0.1
module load bedtools
module load snpeff/4.3


Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar.r -c /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/controls/agilent/cnvradar_normal_cohort.RData -r /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/Agilent/mcdbose365br.bwamem.sorted.marked_roiSummary.txt -v /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/Agilent/mcdbose365br.g.vcf.gz.annotated -G --printChrs 13

#################running at once 
run_cnvcalls.sh 
#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=320g
module load r/3.6.0
module load bedtools
module load snpeff

prj="/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/SJBT/samples"
CNVRadar="/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar.r"
PON="/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/SJBT/controls/cnvradar_normal_cohort.RData"

R="/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/SJBT/samples/roi_files.txt"
A="/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/SJBT/samples/annotated_files.txt"

SAMPLE_R=$(cat $R)
SAMPLE_A=$(cat $A)

Rscript $CNVRadar -c $PON -r $SAMPLE_R -v $SAMPLE_A -G --printChrs 1

################annot SV
annotate_cnv.sh 
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=40g
module load bedtools
module load vcftools
#module load bcftools
/proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/AnnotSV/AnnotSV/bin/AnnotSV -annotationMode both -includeCI 0 -SVinputFile GDN131BL.g.CNVRadar.tsv >& AnnotSV.log -outputFile ./GDN131BL.g.CNVRadar.out -svtBEDcol 5 -genomeBuild GRCh38


