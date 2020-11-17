#!/usr/bin/env bash                                                                                                                                         

#SBATCH --time=02:00:00
#SBATCH --output Logs/nonlinear_bayesian_perID_cluster2.0_%A_%a.log
#SBATCH --mem=10GB
#SBATCH --cpus-per-task=8
#SBATCH --qos=short
#SBATCH --array=1-249

# setup #
ml build-env/f2020
ml r/3.6.0-foss-2019a

# parameters
i=$SLURM_ARRAY_TASK_ID

# run #
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/nonlinear_bayesian_perID_cluster2.0.R $i
Rscript --vanilla ${HOME}/GitRepos/16Vs6C/PlantGrowth/nonlinear_bayesian_perID_summary_cluster2.0.R $i


