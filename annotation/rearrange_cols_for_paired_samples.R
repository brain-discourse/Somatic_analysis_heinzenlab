library(readr)
library(dplyr)
library(tidyverse)


#data_path <- "/proj/heinzenlab/users/meethila1/brain_only/brain_only_annotated/merged_tables/"
samples=c("dukeepi3208","dukeepi3066","dukeepi2944","dukeepi3164","dukeepi3208","dukeepi3925","dukeepi5203","erka16","mcdgg14028","mcdgg15020","mcdgg15022","mcdgg16011","uth0001","uth0002","uth0005")
for (f in samples) {
my_csv=paste("/proj/heinzenlab/users/meethila1/brain_blood/brain_blood_annotated/merged_tables/scripts/",f,"_paired.txt", sep="")
Outfile=paste("/proj/heinzenlab/users/meethila1/brain_blood/brain_blood_annotated/merged_tables/scripts/", f, "_edited.txt", sep="")
file_read <- read_tsv(my_csv)
edited_csv<-file_read[ ,c(1:362,373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 383:391)]
write_tsv(edited_csv, Outfile)
}
q()
