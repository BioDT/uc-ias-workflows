Before you start, please
- replace your version of the `AlwaysLoad.R` script with the provided version. Please also adjust for the path of the files in the three R files provided. Example: >>>> source("_Scripts/AlwaysLoad.R")
- Update `IASDT.R` R package. If you are using renv, please use e.g., `renv::update("IASDT.R", prompt = FALSE)`. loading the package using `require(IASDT.R)` should now report the version and last update date (which is yesterday). This was hard-coded in the package development and may be not recommended but I prefer to have it this way to ensure when was the last time the package was edited.
- Update `Hmsc` R package from GITHUB, using `devtools::install_github("hmsc-r/HMSC")`


1. Use `Model_DE_4Workflow_1.slurm` file to execute `Model_DE_4Workflow_1.R` for preparing input data. 

- Please make changes to the out and error paths in the SLURM file [also in all other SLURM files].
- The current models are done on a subfolder of the scratch folder `IAS_Workflow_Test/Model`.
- The model reads a pre-prepared file from this path "IAS_Workflow_Test/Model_Data". Later this will be not necessary and the input data should be prepared on the fly from the same function [`IASDT.R::Mod_Prep4HPC`].
- The current model is for forest habitat species in Germany. Only a single model is fitted, using 4 chains, 1000 samples, and thinning=5. This means four parallel model fittings will be done.
- The function `IASDT.R::Mod_Prep4HPC` prepares all necessary files for model fitting, including producing a SLURM job file for running the commands.
- All necessary bash commands for model fitting will be saved to `Commands_All.txt` file. If there are many models to be fitted (more than 210 jobs limit of parallel jobs per user for the small-g partition), the commands will be split to separate files and accordingly, different bash jobs that need to be executed.
- You need to have the following environment variables correctly configured. Please see my current .env file.
# DP_R_Mod_Path_Hmsc --- the location of the Hmsc-HPC module [currently in the Scratch folder]. Please use the provided path for now.
# DP_R_Mod_Path_Python --- the location of python. Please use the provided path for now
# IASDT_Proj_Number --- Project number
# DP_R_Mod_Path_GPU_Check --- Path to simple Python script to check the use of GPU. Please use the provided path for now.
# DP_R_Mod_Path_TaxaList --- Path to the folder that contains the `Species_List_ID.txt` file [attached]. Please use the folder path without trailing slash
# DP_R_Mod_Path_Grid ---- Path to the folder that contains `Grid_10_Land_Crop.RData` file. You already have this file from our work on CHELSA
# Path_LUMI_Scratch ---- Path of the scratch folder


2. After finishing with previous step, you need to fit the model(s) from the prepared SLURM file(s). The bash commands in the SLURM file read lines (each fitting a single model chain) from the following file /IAS_Workflow_Test/Model/Commands_All.txt as a batch job (parallel). Please use the following command
# sbatch "/pfs/lustrep4/scratch/project_465000915/IAS_Workflow_Test/Model/Bash_Fit.slurm"

3. After the previous step, you need to check if all models were finished. For this, you need to run
Model_DE_4Workflow_2.slurm / Model_DE_4Workflow_2.R [not necessary for this exercise] 
Please change the path of the environment variables

4. If there is failed models, we need to refit them. A separate commands/SLURM files will be created [not necessary for this exercise] 

5. Read fitted model files and merge chains to a single object. For this, you need to run
Model_DE_4Workflow_3.slurm / Model_DE_4Workflow_3.R
Please change the path of the environment variables