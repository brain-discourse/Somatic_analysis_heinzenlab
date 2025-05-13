## Coverage normalization: 
The different scripts in this repository normalize cases and controls for coverage for gene set enrichment analysis of denovo variants using DNENRICH. This was done as follows:
 
 1. Select samples that have >=80% CCDS overall 50-fold coverage (calculated using GATK depth of coverage)
 2. Create a matrix of individual site level coverage for cases and controls separately
 3. Inspect the matrix at every site and only select sites where 90% of the samples have atleast 50 reads  (for cases and controls separately)
 4. Merge case and control matrices by site and only keep sites where 90% of the samples have atleast 50reads 
 5. Assign a CCDS transcript to each site based on position
 6. Assess how may transcripts are atleast 50% covered (26,972 out of 31,737 transcripts):the coverage is calculated by adding all the sites (length new) and comparing it to the actual length of the CCDS transcript
 7. Filter transcripts that are atleast 50% covered and collapse the number of reads at every transcript (taking the mean coverage of all the sites that are in that transcript)
 8. Merge with Gene-CCDS_NMID file to get genes that correspond to that transcript 
