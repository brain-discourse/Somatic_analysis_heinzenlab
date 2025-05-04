#! /usr/bin/env Rscript
library(readr)
library(dplyr)
library(tidyr)
library(fs)
library(stringr)
data_path <- "/proj/heinzenlab/users/meethila1/brain_only"

#sample list
samples <- c("1465_1024-pfc-bulk","4643_1024-pfc-bulk","UMB1024-pfc-1b12",
             "UMB1474-pfc-1b123","UMB1499-pfc-1b1","UMB1712-pfc-1b12",
             "UMB4548-pfc-1b1","UMB5161-pfc-1b1","UMB5238-pfc-1b123",
             "UMB5391-pfc-1b12","UMB818-pfc-1b1","UMB914-pfc-1b12")

# Merging files 
for (f in samples) {
  cat("Processing:", f, "\n")
  Infile_table <- file.path(data_path, paste0(f, "_somatic_filtered.vcf.table"))
  Infile_annotated <- file.path(data_path, paste0(f, "_somatic_filtered.annotated.hg38_multianno.txt"))
  ccds <- file.path(data_path, paste0(f, "_filtered.ccds.hg38_bed"))
  jeme <- file.path(data_path, paste0(f, "_filtered.jeme.hg38_bed"))
  lincs <- file.path(data_path, paste0(f, "_filtered.lincs.hg38_bed"))
  Outfile <- file.path(data_path, paste0(f, "_final_annotated_output.txt"))

  Macro1 <- read_tsv(Infile_table, show_col_types = FALSE)
  Macro2 <- read_tsv(Infile_annotated, show_col_types = FALSE)

  bed_list <- list(
      read_tsv(ccds, show_col_types = FALSE),
      read_tsv(jeme, show_col_types = FALSE),
      read_tsv(lincs, show_col_types = FALSE)
    )

    bed_list <- lapply(bed_list, function(df) {
        df %>%
          dplyr::select(1, 2, 3, 4, 5, 6, 7, 8, 10, 13) %>%
          dplyr::rename(Bed_0 = 1, Bed_annotation = 2, Bed_Chr = 3, Bed_Start = 4, Bed_End = 5,
                        Bed_Ref = 6, Bed_Alt = 7, Bed_1 = 8, Bed_2 = 9, ID = 10)
    })

    bed_merged <- bind_rows(bed_list)

    vcf_bed_merged <- left_join(Macro1, bed_merged, by = "ID")

# Adding additional data 

  ddg2p <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_DDG2P_15_11_2020.txt", show_col_types = FALSE)
  lof_metrics <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_gnomad_lof_metrics.txt", show_col_types = FALSE)
  lof_tool <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_LoFtool_scores.txt", show_col_types = FALSE)

  annout1 <- left_join(Macro2, lof_tool, by = "Gene.refGene")
  annout2 <- left_join(annout1, ddg2p, by = "Gene.refGene")
  annout3 <- left_join(annout2, lof_metrics, by = "Gene.refGene")

  annout3 <- annout3 %>%
    rename(ID = `Otherinfo6`)  # should match UID in annotation file
  
  final_out <- left_join(annout3, vcf_bed_merged, by = "ID")

write_tsv(final_out, Outfile)
  cat("Output saved to:", Outfile, "\n\n")
}
