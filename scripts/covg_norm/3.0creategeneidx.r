# This script takes ref gene sites and adds locus position so as to get gene info table to create an index file 

library(data.table)
library(dplyr)
library(tidyr)
library(readr)

gene_sites<-read.table("/overflow/heinzenlab/meethila/genes_db/hg38_refGene.txt",header=T, sep='\t', stringsAsFactors=F)

library(rlang)
unnest_dt <- function(tbl, col) {
  tbl <- as.data.table(tbl)
  col <- ensyms(col)
  clnms <- syms(setdiff(colnames(tbl), as.character(col)))
  tbl <- as.data.table(tbl)
  tbl <- eval(
    expr(tbl[, as.character(unlist(!!!col)), by = list(!!!clnms)])
  )
  colnames(tbl) <- c(as.character(clnms), as.character(col))
  tbl
}

genes_sites1<-gene_sites%>%
  select(V1,V2,V3,V5)%>%
  unique()%>%
        rowwise %>%
mutate(lists = list(as.character(seq(from = as.numeric(V2), to = as.numeric(V3)))))%>%
unnest_dt(lists) %>%
        select(position = lists,V1,V5)



genes_sites1$Locus<-paste(genes_sites1$V1, genes_sites1$position, sep=":")


genes_sites1<-genes_sites1%>%
 select(Locus,V5)



write_tsv(genes_sites1,"/overflow/heinzenlab/meethila/genes_db/genes_testing1")


setDT(genes_sites1)


genes_sites1[, `:=` (count = .N), by = V5]


write_tsv(genes_sites1,"/overflow/heinzenlab/meethila/genes_db/final_index_file")
q()
