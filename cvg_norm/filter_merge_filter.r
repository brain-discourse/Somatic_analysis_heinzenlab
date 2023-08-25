#####merge cases and controls matrix into one and then filter again for <50 reads in 90% of the samples (filter_merge_filter.r)

library(readr)
library(dplyr)
library(tidyr)
library(data.table)
#files <- list.files(path="/proj/heinzenlab/projects/somaticNov2020/coverage/coveragebybase.txt")
files<-list.files(c("/proj/heinzenlab/projects/somaticNov2020/coverage/UMB1474-pfc-1b123/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UMB1499-pfc-1b1/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UMB1712-pfc-1b12/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UMB4548-pfc-1b1/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UMB4672-pfc-1b12_200x/",
"/overflow/heinzenlab/dbgap-NABEC/coverage/UMARY-794_combined/",
"/overflow/heinzenlab/dbgap-NABEC/coverage/UMARY-914/"), pattern="coverage$", full.names = TRUE)
sites <- read.table(files[1], header=FALSE, sep=",")[,1]     # gene names
df    <- do.call(cbind,lapply(files,function(fn)read.table(fn,header=FALSE, sep=",")[,4]))
df    <- cbind(sites,df)
df<-as.data.frame(df)
write.table(df, "site_matrix_table.txt")
write_tsv(df, "site_matrix.txt")
q()
