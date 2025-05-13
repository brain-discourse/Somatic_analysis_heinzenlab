# This script takes the merged site specific coverage calls- queries them against CCDS sites by locus- it then collapses each site by gene (hgnc symbol) and annotates them by gene length (genes with atleast 50% CCDS coverage )

library(data.table)
library(dplyr)
#library(Hmisc)
library(tidyr)
library(readr)
site_matrix <-read.table("/proj/heinzenlab/projects/somaticNov2020/coverage/final_filtered_merged_filtered.txt",header=T, sep="\t", stringsAsFactors=F)
CCDS_index<-read.table("/overflow/heinzenlab/meethila/genes_db/unique_CCDSgenes_l", header=T, sep="\t", stringsAsFactors=F)
#setDT(CCDS_index)
#setDT(site_matrix)

genes_matrix<-merge(site_matrix, CCDS_index, by= 'Locus')
setDT(genes_matrix)
genes_matrix[, `:=` (gene_length_new = .N), by = hgnc_symbol]
genes_matrix[, `:=` (gene_length = 100*gene_length_new/gene_length_OG), by = hgnc_symbol]

genes_matrix[, gene_length_50x := fifelse(gene_length < 50, "no", "yes")]

write_tsv(genes_matrix,"/overflow/heinzenlab/meethila/genes_db/genes_matrix1")


wont_merge<-anti_join(site_matrix, CCDS_index, by= 'Locus')
write_tsv(wont_merge,"/overflow/heinzenlab/meethila/genes_db/sites_that_wont_merge_transcripts1")

q()
