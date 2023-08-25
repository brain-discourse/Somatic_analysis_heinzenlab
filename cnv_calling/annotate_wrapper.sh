#gvcfs need to be generated to be able to annotate these files and utilize them for CNV calling 
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
