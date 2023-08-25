#######################################Filter both cases and controls individually for <50 reads in 90% of the samples (coverage_normalization.r)
library(data.table)
library(readr)
library(dplyr)
library(tidyverse)
library(tidyr)

#site_matrix_demo <- read_delim("/proj/heinzenlab/projects/somaticNov2020/coverage/site_matrix.txt", 
#    "\t", escape_double = FALSE, trim_ws = TRUE, 
#    skip = 1)
site_matrix_demo <-read.table("/proj/heinzenlab/projects/somaticNov2020/coverage/site_matrix.txt",header=T, sep="\t", stringsAsFactors=F, skip=1)
#cases_matrix<-site_matrix_demo %>%
 #    remove_rownames() %>%
  #   column_to_rownames(var = 'Locus')

cases_matrix_70x<-site_matrix_demo%>%
  select(Locus, Depth_for_COLE120BR ,   Depth_for_COLE122BR   ,   Depth_for_COLE131BR,   
Depth_for_COLE133BR  ,    Depth_for_COLE138BR    ,  Depth_for_COLE139BR,
Depth_for_COLE141BR   ,   Depth_for_COLE153BR     , Depth_for_COLE155BR,
Depth_for_COLE157BR    ,  Depth_for_COLE159BR      ,Depth_for_COLE160BR ,
Depth_for_dukeepi2213br , Depth_for_dukeepi2488br  ,Depth_for_dukeepi2645br, 
Depth_for_dukeepi2807br ,Depth_for_dukeepi2944br ,
 Depth_for_dukeepi3066br , 
,  Depth_for_UTH0018BR   ,   Depth_for_UTH0019BR     ,
Depth_for_uth0020br     , Depth_for_uth0021br    ,  Depth_for_UTH0023BR     ,
Depth_for_UTH0024BR      ,Depth_for_UTH0026BR     , Depth_for_UTH0027BR     ,
Depth_for_UTH0028BR)

cases_colnames<-c("Depth_for_COLE120BR"   ,   "Depth_for_COLE122BR"   ,   "Depth_for_COLE131BR",   
"Depth_for_COLE133BR"  ,    "Depth_for_COLE138BR"    ,  "Depth_for_COLE139BR",
"Depth_for_COLE141BR"   ,   "Depth_for_COLE153BR"     , "Depth_for_COLE155BR",
   ,   "Depth_for_uth0015br"  ,    "Depth_for_uth0016br"     ,
"Depth_for_uth0017br"    ,  "Depth_for_UTH0018BR"   ,   "Depth_for_UTH0019BR"     ,
 "Depth_for_uth0021br"    ,  "Depth_for_UTH0023BR"     ,
"Depth_for_UTH0024BR"      ,"Depth_for_UTH0026BR"     ,
"Depth_for_UTH0028BR")



is.na(cases_matrix_70x[cases_colnames]) <-  cases_matrix_70x[cases_colnames] < 50
cases_matrix_70x<-cases_matrix_70x[which(rowMeans(!is.na(cases_matrix_70x)) > 0.9), ]

write_tsv(cases_matrix_70x,"/proj/heinzenlab/projects/somaticNov2020/coverage/coverage_normalized_case_matrix_no_index")


library(data.table)
library(readr)
library(dplyr)
library(tidyverse)
library(tidyr)

site_matrix_demo <-read.table("/overflow/heinzenlab/dbgap-NABEC/coverage/site_matrix.txt",header=T, sep="\t", stringsAsFactors=F, skip=1)
#controls_matrix<-site_matrix_demo %>%
 #    remove_rownames() %>%
  #   column_to_rownames(var = 'Locus')
controls_matrix_70x<-site_matrix_demo%>%
  select(Locus, Depth_for_SH.00.38_combined  , 
  Depth_for_SH.01.31,         Depth_for_SH.01.37_combined  
,   Depth_for_SH.02.06_combined",
"Depth_for_1465_1024.pfc.bulk",
"Depth_for_4638_1024.pfc.bulk",
"Depth_for_4643_1024.pfc.bulk",
"Depth_for_UMB1024.pfc.1b12",
"Depth_for_UMB1474.pfc.1b123",
"Depth_for_UMB1499.pfc.1b1",
"Depth_for_UMB1712.pfc.1b12",

"Depth_for_UMB4548.pfc.1b1",
"Depth_for_UMB4672.pfc.1b12_200x",
"Depth_for_UMB4842.pfc.1b1",
"Depth_for_UMB5161.pfc.1b1",
"Depth_for_UMB5238.pfc.1b123",
"Depth_for_UMB5391.pfc.1b12",
"Depth_for_UMB818.pfc.1b1",
"Depth_for_UMB914.pfc.1b12")
is.na(controls_matrix_70x[controls_colnames]) <-  controls_matrix_70x[controls_colnames] < 50
controls_matrix_70x<-controls_matrix_70x[which(rowMeans(!is.na(controls_matrix_70x)) > 0.9), ]
write_tsv(controls_matrix_70x,"/overflow/heinzenlab/dbgap-NABEC/coverage/coverage_normalized_control_matrix_no_index")
q()
