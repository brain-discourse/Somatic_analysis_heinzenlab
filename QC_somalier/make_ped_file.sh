#make pedigree files (.ped) to check for relatedness , using module load vcftools 
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=4g
module load vcftools
# list4 contains path to all gvcfs
for f in `cat list4.txt`; do FILENAME=`basename ${f%.*}`; n=`basename ${FILENAME%.*}`; m=`basename ${n%.*}` ; vcftools --gzvcf ${f} --plink --out ${m}; done
