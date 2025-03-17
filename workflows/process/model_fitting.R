# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script prepares model fitting data and commands for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-03-17
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

options(nwarnings = 500) # increase the number of warnings to be reported

Ch1 <- function(Text) {
  IASDT.R::InfoChunk(
    paste0("\t", Text), Rep = 2, Char = "=", CharReps = 60, Red = TRUE,
    Bold = TRUE, Time = FALSE)
}

on.exit(
  add = TRUE,
  expr = {
    IASDT.R::InfoChunk(
      "Session packages", Date = TRUE, Extra2 = 1, Bold = TRUE, Red = TRUE)
    print(sessioninfo::session_info()$packages)
    IASDT.R::InfoChunk(
      "Session info", Date = TRUE, Extra2 = 1, Bold = TRUE, Red = TRUE)
    print(sessioninfo::session_info()$platform)

    IASDT.R::InfoChunk(
      "Warnings", Date = TRUE, Extra2 = 1, Bold = TRUE, Red = TRUE)

    warnings()
  })

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# activate renv
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# load packages
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Load necessary packages
purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R",
    "Hmsc", "blockCV", "coda", "stringr", "qs2"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# Prepare model fitting data and commands
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Ch1("Prepare model fitting data and commands")

# _______________________________________________________________ ## 
# THE FOLLOWING ARGUMENTS ARE MORE LIKELY TO BE CHANGED IN EACH RUN
# _______________________________________________________________ ## 

# Model prefix - for directory name of the fitted models
Model_Prefix <- "IAS_TEST_Hab" # XXXXX
# Distance between GPP knots - multiple values are allowed
GPP_Dists = 120 # XXXXX
# thinning value - multiple values are allowed
thin = 200 # XXXXX
# Prior info for Alphapw - 101 values between 40 and 1400 km
Alphapw <- list(Prior = NULL, Min = 150, Max = 1500, Samples = 101) # XXXX

# _______________________________________________________________ ## 
# THE FOLLOWING ARGUMENTS ARE LESS LIKELY TO BE CHANGED IN EACH RUN
# _______________________________________________________________ ##

# Habitat classes
HabClasses <- c("1", "2", "3", "4a", "4b", "10", "12a", "12b")

# minimum and maximum number of latent factors
MinLF = 1
MaxLF = 4

# Bioclimatic variables to be used in the model
BioVars = c("bio3", "bio4", "bio11", "bio18", "bio19", "npp")
# Which variables to be used as quadratic terms
QuadraticVars = BioVars

# Number of cores to be used
NCores = 30
# Number of MCMC chains
NChains <- 4

# Path for Hmsc installation
Path_Hmsc = "/pfs/lustrep4/scratch/project_465000915/elgabbas/Hmsc_Simplified_OOM2"

# Memory per CPU for fitting models
MemPerCpu <- "200G"

# requested time for fitting models
Time <- "3-00:00:00"

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Prepare models for each habitat class
purrr::walk(
  .x = HabClasses,
  .f = ~{

    JobName <- paste0(Model_Prefix, .x)
    Ch1(JobName)

    IASDT.R::Mod_Prep4HPC(
      Hab_Abb = .x,
      DirName = JobName,
      # MinEffortsSp = 100L,
      # PresPerSpecies = 80L,
      # EnvFile = ".env",
      # GPP = TRUE,
      GPP_Dists = GPP_Dists,
      # GPP_Save = TRUE,
      # GPP_Plot = TRUE,
      MinLF = MinLF,
      MaxLF = MaxLF,
      Alphapw = Alphapw,
      BioVars = BioVars,
      QuadraticVars = QuadraticVars,
      # EffortsAsPredictor = TRUE,
      # RoadRailAsPredictor = TRUE,
      # HabAsPredictor = TRUE,
      # RiversAsPredictor = TRUE,
      # NspPerGrid = 0L,
      # ExcludeCult = TRUE,
      # ExcludeZeroHabitat = TRUE,
      # CV_NFolds = 4L,
      # CV_NGrids = 20L,
      # CV_NR = 2L,
      # CV_NC = 2L,
      # CV_Plot = TRUE,
      # CV_SAC = FALSE,
      # PhyloTree = TRUE,
      # NoPhyloTree = FALSE,
      # OverwriteRDS = TRUE,
      NCores = NCores,
      NChains = NChains,
      thin = thin,
      # samples = 1000L,
      # transientFactor = 500L,
      # verbose = 200L,
      # SkipFitted = TRUE,
      # NumArrayJobs = 210L,
      # ModelCountry = NULL,
      # VerboseProgress = TRUE,
      # PrepSLURM = TRUE,
      MemPerCpu = MemPerCpu,
      Time = Time,
      JobName = JobName,
      Path_Hmsc = Path_Hmsc,
      # CheckPython = FALSE,
      # ToJSON = FALSE,
      # Precision = 64L
    )
  })
