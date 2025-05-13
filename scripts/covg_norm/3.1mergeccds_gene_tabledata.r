# this script takes ccds table, NMID_index - again selects ccds locus and gene names and lengths for normalization by CCDS regions

library(data.table)
library(dplyr)
library(tidyr)
library(readr)
CCDS_index<-read.table("/overflow/heinzenlab/meethila/genes_db/CCDS_index_transcript.txt",header=T, sep='\t', stringsAsFactors=F)

gene_index<-read.table("/overflow/heinzenlab/meethila/genes_db/NMID_index.txt",header=T, sep='\t', stringsAsFactors=F)

CCDS_index<-CCDS_index%>%
  select(Locus, V4)

CCDS_genefile<-merge(CCDS_index, gene_index, by='V4')

CCDS_genefile1<-CCDS_genefile%>%
  group_by(hgnc_symbol)%>%
  unique()


write_tsv(CCDS_genefile1, "/overflow/heinzenlab/meethila/genes_db/unique_CCDSgenes")
 
CCDS_genefile2<-CCDS_genefile1%>%
 mutate(gene_length_OG=n())

write_tsv(CCDS_genefile2, "/overflow/heinzenlab/meethila/genes_db/unique_CCDSgenes_l")
