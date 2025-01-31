# Load .Rprofile
source("/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/.Rprofile")

# increase the number of warnings to be reported
options(nwarnings = 200)

# activate renv
# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

# Load necessary packages
purrr::walk(
  c(
    "dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R",
    "Hmsc", "blockCV", "coda", "stringr", "qs2"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

# Model fitting path
Path_Model <- "datasets/processed/model_fitting"

# Model prefix - for directory name of the fitted models
Model_Prefix <- "IAS_Q_Hab"

# Habitat classes
HabClasses <- c("1", "2", "3", "4a", "4b", "10", "12a", "12b")

# Path for Hmsc installation
#Path_Hmsc <- "/pfs/lustrep4scratch/project_465000915/elgabbas/Hmsc_Simplified_OOM2"
Path_Hmsc <- normalizePath("/pfs/lustrep4scratch/project_465000915/elgabbas/Hmsc_Simplified_OOM2", winslash = "/")

# Bioclimatic variables to be used in the model
BioVars <- c("bio2", "bio4", "bio6", "bio8", "bio12", "bio15", "bio18")

# Which variables to be used as quadratic terms
QuadraticVars <- c("bio2", "bio4", "bio6", "bio8", "bio12", "bio15", "bio18")

# Distance between GPP knots - multiple values are allowed
GPP_Dists <- 130
# Prior info for Alphapw - 101 values between 40 and 1400 km
Alphapw <- list(Prior = NULL, Min = 40, Max = 1400, Samples = 101)
# minimnum and maximum number of latent factors
MinLF <- 1
MaxLF <- 4
# Number of MCMC chains
NChains <- 6
# thinning value - multiple values are allowed
thins <- 300
# Number of cores to be used
NCores <- 10
# whether to prepare SLURM scripts
PrepSLURM <- TRUE
# Memory per CPU for fitting models
MemPerCpu <- "200G"
# requested time for fitting models
Time <- "3-00:00:00"

# Prepare models for each habitat class
purrr::walk(
  .x = HabClasses,
  .f = ~{
    JobName <- paste0(Model_Prefix, .x)

    cat("\n")
    IASDT.R::CatSep(Rep = 1, Extra1 = 1, Extra2 = 0, Char = "*")
    IASDT.R::CatSep(Rep = 1, Extra1 = 1, Extra2 = 1, Char = "*")
    IASDT.R::CatTime(paste0("\t", JobName), Red = TRUE, Bold = TRUE, Time = FALSE)
    IASDT.R::CatSep(Rep = 1, Extra1 = 0, Extra2 = 1, Char = "*")
    IASDT.R::CatSep(Rep = 1, Extra1 = 0, Extra2 = 1, Char = "*")

    IASDT.R::Mod_Prep4HPC(
      Hab_Abb = .x,
      Path_Model = file.path(Path_Model, JobName),
      # MinEffortsSp = 100,
      # PresPerSpecies = 80,
      # EnvFile = ".env",
      # GPP = TRUE,
      GPP_Dists = GPP_Dists,
      # GPP_Save = TRUE
      # GPP_Plot = TRUE
      MinLF = MinLF,
      MaxLF = MaxLF,
      Alphapw = Alphapw,
      BioVars = BioVars,
      QuadraticVars = QuadraticVars,
      # EffortsAsPredictor = TRUE,
      # RoadRailAsPredictor = TRUE,
      # HabAsPredictor = TRUE,
      # NspPerGrid = 0,
      # ExcludeCult = TRUE,
      # CV_NFolds = 4,
      # CV_NGrids = 20,
      # CV_NR = 2,
      # CV_NC = 2,
      # CV_Plot = TRUE,
      # CV_SAC = FALSE,
      # PhyloTree = TRUE,
      # NoPhyloTree = FALSE,
      # SaveData = TRUE,
      # OverwriteRDS = TRUE,
      NCores = NCores,
      NChains = NChains,
      thin = thins,
      # samples = 1000
      # transientFactor = 500,
      # verbose = 200,
      # SkipFitted = TRUE,
      # NumArrayJobs = 210,
      # ModelCountry = NULL,
      # VerboseProgress = TRUE,
      # FromHPC = TRUE,
      PrepSLURM = PrepSLURM,
      MemPerCpu = MemPerCpu,
      Time = Time,
      JobName = paste0("Hab", .x),
      Path_Hmsc = Path_Hmsc,
      # CheckPython = FALSE,
      # ToJSON = FALSE,
      # Precision = 64
    )
  })

warnings()
