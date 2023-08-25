for filename in /proj/heinzenlab/users/meethila1/controls/*_filtered.vcf
do 
#prints only select cols from raw bed file 
awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$10,$13}' $(basename "$filename" .ext).bed.hg18_bed > $(basename "$filename" .ext).bed \
#trasnforms the bed file to a tsv file
tr ' ' '\t' < $(basename "$filename" .ext).bed > $(basename "$filename" .ext).bed.temp && mv $(basename "$filename" .ext).bed.temp $(basename "$filename" .ext).bed \
#adds header to the bed file 
sed -i '1i Bed_0	Bed_Name	Bed_Chr	Bed_Start	Bed_End	Bed_Ref	Bed_Alt	Bed_1	Bed_2	ID' $(basename "$filename" .ext).bed

done
