#!/usr/bin/env bash                                                                                                                                         

#SBATCH --time=30:00:00
#SBATCH --output Logs/nonlinear_cluster_corCAR_randomBlocked%A_%a.log
#SBATCH --mem=60GB
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --qos=medium
#SBATCH --array=0-4

# setup #
module load r/3.5.1-foss-2018b

# subsets #
i=$SLURM_ARRAY_TASK_ID
subsets=(10 50 100 200 249)
acnNr=${subsets[$i]}

# run #
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/GrowthModels/nonlinear_cluster_corCAR_randomBlocked.r --subset $acnNr


