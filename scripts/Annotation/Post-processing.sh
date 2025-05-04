#!/bin/bash
#SBATCH -N 1
#SBATCH -t 07-00:00:00
#SBATCH --mem=80g
#SBATCH -J post_process
#SBATCH --output=post_process_%j.out

module load r/3.6.0

# ---------- STEP 1: Add sample identifier ----------
echo "Add filename to each file"

for i in *_final_annotated_merged.tsv; do
  awk -v fname="$i" '{print fname "\t" $0}' "$i" > "$i.tmp" && mv "$i.tmp" "$i"
done

# ---------- STEP 2: Merge annotation files  ----------

echo "Merging files with identical headers"

 #get header from first file
  head -n 1 *_final_annotated_merged.tsv | head -n 1 > all_annotated_and_merged_final.txt

 #Append all files 

  for file in *_final_annotated_merged.tsv; do
    tail -n +2 "$file" >> all_annotated_and_merged_final.txt
  done

# ---------- STEP 3: Check line counts  ----------

echo "Checking line counts"

find . -name '*_final_annotated_merged.tsv' | xargs wc -l
wc -l all_annotated_and_merged_final.txt



