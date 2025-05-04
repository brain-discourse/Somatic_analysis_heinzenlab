#!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH -t 07-00:00:00
#SBATCH --mem=16g
#SBATCH -J somalier_qc
#SBATCH --output=somalier_qc_pipeline.out

module load vcftools/0.1.16


SOMALIER_DIR=/proj/heinzenlab/users/meethila1/somalier 
SOMALIER_BIN=$SOMALIER_DIR/somalier #somalier binary 
REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa
SITES_VCF=/proj/heinzenlab/users/meethila1/sites.hg38.vcf.gz
EXTRACT_DIR=$SOMALIER_DIR/extracted
PED_DIR=$SOMALIER_DIR/ped_files
LABELS_FILE=$EXTRACT_DIR/ancestry-labels-1kg.tsv
KG_SOMALIER=$EXTRACT_DIR/1kg-somalier/*.somalier

mkdir -p "$EXTRACT_DIR"
mkdir -p "$PED_DIR"

# ------------------ STEP 1: Extract .somalier files ------------------
echo "Running somalier extract"
while read -r GVCF; do
  ./somalier extract \
    -d "$EXTRACT_DIR" \
    --sites "$SITES_VCF" \
    -f "$REF" \
    "$GVCF"
done < gvcf_list.txt 


echo "somalier extract completed."

# ------------------ STEP 2: Create pedigree files using vcftools ------------------

echo "Generating PED files from VCFs"
while read -r GVCF; do
  BASE=$(basename "${GVCF%.g.vcf.gz}")
  vcftools --gzvcf "$GVCF" --plink --out "$PED_DIR/$BASE"
done < gvcf_list.txt

echo "Pedigree files generated."

# ------------------ STEP 3: Run relatedness checks ------------------

echo "Running relatedness analysis"
"$SOMALIER_BIN" relate \
  --ped "$PED_DIR"/*.ped \
  "$EXTRACT_DIR"/*.somalier > "$SOMALIER_DIR/somalier_relatedness_results.tsv"

echo "relatedness analysis complete."

# ------------------ STEP 4: Run ancestry checks ------------------

echo "Running ancestry analysis"
"$SOMALIER_BIN" ancestry \
  --labels "$LABELS_FILE" \
  $KG_SOMALIER \
  "$EXTRACT_DIR"/*.somalier > "$SOMALIER_DIR/somalier_ancestry_results.tsv"

echo "Ancestry inference done."

echo "Somalier QC pipeline done"

# NOTE1: gvcf_list.txt is a txt file containing a list of all gvcf paths for which quality checks need to be run 
# NOTE2: somalier generates a joint output for all gvcfs used in the analysis 
# Pkg src: https://github.com/brentp/somalier
