#!/bin/bash
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --account=project_465001588
#SBATCH --job-name=Model_WF
#SBATCH --output=/pfs/lustrep4/users/elgabbas/BioDT_IAS/Jobs/%x-%A-%a.out
#SBATCH --error=/pfs/lustrep4/users/elgabbas/BioDT_IAS/Jobs/%x-%A-%a.err
#SBATCH --time=00:15:00
#SBATCH --partition=standard-g
#SBATCH --mem=5G

export EBU_USER_PREFIX=/project/project_465001588/EasyBuild
module load LUMI/23.09 partition/L GDAL fontconfig FriBidi HarfBuzz git UDUNITS libsodium GSL libarchive/3.6.2-cpeGNU-23.09 R

Rscript --vanilla "Model_DE_4Workflow_2.R"
