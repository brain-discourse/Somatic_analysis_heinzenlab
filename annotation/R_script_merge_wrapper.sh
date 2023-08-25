#!/bin/bash
	#SBATCH -N 1
	#SBATCH -n 6
	#SBATCH -p general
	#SBATCH --nice=30 
	#SBATCH -t 07-00:00:00
#SBATCH --mem=40g
module load r/4.0.1
R CMD BATCH --no-restore --no-save Rscript.r
