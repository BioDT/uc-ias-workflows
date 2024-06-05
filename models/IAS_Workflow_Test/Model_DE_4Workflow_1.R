renv::load(quiet = FALSE)
renv::update("IASDT.R", prompt = FALSE)

source("_Scripts/AlwaysLoad.R")

# Path to environment variables - Please change to the absolute path in your user folders or somewhere else
EnvFile <- "/pfs/lustrep4/users/elgabbas/BioDT_IAS/.env"

# Read environment variables
readRenviron(EnvFile)

# Path to the scratch folder
Path_Scratch <- Sys.getenv("Path_LUMI_Scratch")
# print(Path_Scratch)


# Set working directory to the scratch folder
setwd(Path_Scratch)
# print(getwd())


# Path to save all model outputs
Path_Model <- "IAS_Workflow_Test/Model"

# DP_R_Mod_Path_TaxaList
# Species_List_ID.txt
# DP_R_Mod_Path_Grid
# Grid_10_Land_Crop.RData

# DP_R_Mod_Path_Hmsc
# DP_R_Mod_Path_Python
# IASDT_Proj_Number
# DP_R_Mod_Path_GPU_Check
# DP_R_Mod_Path_TaxaList
# DP_R_Mod_Path_Grid
# Path_LUMI_Scratch


# Habitat type
Hab_Abb <- "1"
# GPP - Distance between knots
GPP_Dists <- 30
# Number of samples
Samples <- 1000
# How much thinning
Thins <- 5
# Number of chains
NChains <- 4
# Number of parallel processes
Npar <- 25
# prefix for the submitted jobs
Job_Prefix <- "DESW_"

IASDT.R::Mod_Prep4HPC(
  # habitat type 1
  Hab_Abb = Hab_Abb,
  # Location of the model data - Already provided
  Path_Data = "IAS_Workflow_Test/Model_Data", 
  # Path to save all model inputs/outputs
  Path_Model = Path_Model,
  # minimum of presence grid cells per species
  MinPresGrids = 50,
  # Path to the environment variables
  EnvFile = EnvFile,
  # do not prepare the data; load it from Path_Data path
  PrepareData = FALSE,
  # GPP - Distance between knots
  GPP_Dists = GPP_Dists,
  # GPP - Save knots
  GPP_Save = TRUE,
  # GPP - plot knots
  GPP_Plot = TRUE,
  # Use default predictors
  XVars = NULL,
  # Use phylogenetic trees
  PhyloTree = TRUE, NoPhyloTree = FALSE,
  # Number of parallel processes
  NParallel = Npar,
  # Number of chains
  nChains = NChains,
  # How much thinning
  thin = Thins,
  # Number of samples
  samples = Samples,
  # how many samples to ignores
  transientFactor = 300,
  # How often to verbose model outputs
  verbose = 1000,
  # Do not prepare data for previously fitted models
  SkipFitted = TRUE,
  # Maximum number of jobs per batch job - for small-g, we can not submit more than 210 jobs in the same batch job
  MaxJobCounts = 210,
  # Countries to fit the models to
  ModelCountry = "Germany",
  # Minimum number of presence grid cells in those countries
  MinPresPerCountry = 50, 
  # Show progress of this function
  VerboseProgress = FALSE,
  # working from LUMI 
  FromHPC = TRUE,
  # prepare slurm file
  PrepSLURM = TRUE,
  # Memory needed for each chain (i.e. for each submitted job)
  MemPerCpu = "100G", 
  # Time needed for each chain
  Time = "00:30:00",
  # The name of the submitted job(s)
  JobName = "WF_DE_Test",
  ToJSON = TRUE
)

# MemPerCpu | Time
# IASDT.R::Mod_SLURM(
#   Path_Model = Path_Model,
#   JobName = paste0(Job_Prefix, Hab_Abb), 
# )

# # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# FIT THE MODELS -------
# # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# sbatch "/pfs/lustrep4/scratch/project_465000915/IAS_Workflow_Test/Model/Bash_Fit.slurm"