#Create .somalier files from gvcfs (directory in which you run needs to have somaler software, also need fasta reference and sites.hg38.vcf.gz

for f in `cat gvcfz.txt`; do ./somalier extract -d extracted --sites /proj/heinzenlab/users/meethila1/sites.hg38.vcf.gz -f /proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa $f; done
