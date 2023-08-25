#generate matrix for all samples covered >=80 CCDS 50x ( coveragematrix.r)
library(readr)
library(dplyr)
library(tidyr)
library(data.table)
#files <- list.files(path="/proj/heinzenlab/projects/somaticNov2020/coverage/coveragebybase.txt")
files<-list.files(c("/proj/heinzenlab/projects/somaticNov2020/coverage/COLE120BR/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/dukeepi3141br2/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/MCDGG19004BR/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UTH0031BR/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/MCDBOSE212BR/",
"/proj/heinzenlab/projects/somaticNov2020/coverage/UTH0031BR/"), pattern="coverage$", full.names = TRUE)
sites <- read.table(files[1], header=FALSE, sep=",")[,1]     # gene names
df    <- do.call(cbind,lapply(files,function(fn)read.table(fn,header=FALSE, sep=",")[,4]))
df    <- cbind(sites,df)
df<-as.data.frame(df)
write.table(df, "site_matrix_table.txt")
write_tsv(df, "site_matrix.txt")
q()
