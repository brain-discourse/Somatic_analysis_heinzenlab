# This script prints genes with atleast 90% coverage 


#!/bin/bash
  #SBATCH -N 1
  #SBATCH -n 6
  #SBATCH -p general  
  #SBATCH --nice=30 
  #SBATCH -t 07-00:00:00
  #SBATCH --mem=4g

#awk -F "\t" 'NR==1; NR > 1{ if ($191 = yes) {print} }' genes_matrix > genes_matrix_filtered.txt

awk -F "\t" 'NR==1; NR > 1 { if($192 == "yes") { print } }' genes_matrix1 > genes_matrix_filtered.txt


# It then groups original gene length and new gene length (for sequenced samples with enough coverage)- and counts the number of genes w atleast 50% coverage 

library(data.table)
library(dplyr)
library(tidyr)
library(readr)
gene_matrix <-read.table("/overflow/heinzenlab/meethila/genes_db/genes_matrix_filtered.txt",header=T, sep="\t", stringsAsFactors=F)
gene_matrix<-gene_matrix%>%
group_by(hgnc_symbol,gene_length_new, gene_length_OG, gene_length)%>%
count()
write_tsv(gene_matrix,"/overflow/heinzenlab/meethila/genes_db/gene_count_50x")
q()
