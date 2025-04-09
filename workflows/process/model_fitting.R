# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script prepares model fitting data and commands for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-04-08
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed
# - change the path to Hmsc installation
# - change model prefix along with other needed model parameters

tryCatch(
  {

    # starting time
    .StartTime <- lubridate::now(tzone = "CET")

    # increase the number of warnings to be reported
    options(nwarnings = 500)

    # activate renv
    suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

    # load packages
    purrr::walk(
      c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R",
        "Hmsc", "blockCV", "coda", "stringr", "qs2"),
      ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))


    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # Prepare model fitting data and commands
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    IASDT.R::info_chunk(
      "\tPrepare model fitting data and commands",
      date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)

    # _______________________________________________________________ ##
    # THE FOLLOWING ARGUMENTS ARE MORE LIKELY TO BE CHANGED IN EACH RUN
    # _______________________________________________________________ ##

    # Model prefix - for directory name of the fitted models
    Model_Prefix <- "IAS_M22"
    # Distance between GPP knots - multiple values are allowed
    GPP_dists = 120
    # thinning value - multiple values are allowed
    thin = 200
    # Prior info for alphapw - 101 values between 40 and 1400 km
    alphapw <- list(Prior = NULL, Min = 150, Max = 1500, Samples = 101) # XXXX

    # _______________________________________________________________ ##
    # THE FOLLOWING ARGUMENTS ARE LESS LIKELY TO BE CHANGED IN EACH RUN
    # _______________________________________________________________ ##

    # Habitat types
    habitat_types <- c("1", "2", "3", "4a", "4b", "10", "12a", "12b")

    # minimum and maximum number of latent factors
    min_LF = 1
    max_LF = 4

    # Bioclimatic variables to be used in the model
    bio_variables = c("bio3", "bio4", "bio11", "bio18", "bio19", "npp")
    # Which variables to be used as quadratic terms
    quadratic_variables = bio_variables

    # Number of cores to be used
    n_cores = 30
    # Number of MCMC chains
    NChains <- 4

    # Path for Hmsc installation
    path_Hmsc = "/pfs/lustrep2/scratch/project_465001857/elgabbas/Hmsc_simplify_io"

    # Memory per CPU for fitting models
    memory_per_cpu <- "64G"

    # requested time for fitting models
    Time <- "3-00:00:00"

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    # Prepare models for each habitat class
    purrr::walk(
      .x = habitat_types,
      .f = ~{

        job_name <- paste0(Model_Prefix, .x)
        Ch1(job_name)

        IASDT.R::mod_prepare_HPC(
          hab_abb = .x,
          directory_name = job_name,
          # min_efforts_n_species = 100L,
          # n_pres_per_species = 80L,
          # env_file = ".env",
          # GPP = TRUE,
          GPP_dists = GPP_dists,
          # GPP_save = TRUE,
          # GPP_plot = TRUE,
          min_LF = min_LF,
          max_LF = max_LF,
          alphapw = alphapw,
          bio_variables = bio_variables,
          quadratic_variables = quadratic_variables,
          # efforts_as_predictor = TRUE,
          # road_rail_as_predictor = TRUE,
          # habitat_as_predictor = TRUE,
          # river_as_predictor = TRUE,
          # n_species_per_grid = 0L,
          # exclude_cultivated = TRUE,
          # exclude_0_habitat = TRUE,
          # CV_n_folds = 4L,
          # CV_n_grids = 20L,
          # CV_n_rows = 2L,
          # CV_n_columns = 2L,
          # CV_plot = TRUE,
          # CV_SAC = FALSE,
          # use_phylo_tree = TRUE,
          # no_phylo_tree = FALSE,
          # overwrite_rds = TRUE,
          n_cores = n_cores,
          MCMC_n_chains = NChains,
          MCMC_thin = thin,
          # MCMC_samples = 1000L,
          # MCMC_transient_factor = 500L,
          # MCMC_verbose = 200L,
          # skip_fitted = TRUE,
          # n_array_jobs = 210L,
          # model_country = NULL,
          # verbose_progress = TRUE,
          # SLURM_prepare = TRUE,
          memory_per_cpu = memory_per_cpu,
          job_runtime = Time,
          job_name = job_name,
          path_Hmsc = path_Hmsc,
          # check_python = FALSE,
          # to_JSON = FALSE,
          # precision = 64L
        )
      })

    IASDT.R::cat_diff(
      init_time = .StartTime, cat_info = TRUE,
      chunk_text = "Data preparation is finished",
      prefix = "Processing all modelling data took ", ... = "\n\n")
  },

  error = function(e) {

    # Error message if the script fails
    IASDT.R::info_chunk(
      "Error message", date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)
    print(paste("Error:", e$message))

  },

  finally = {

    # Session information
    IASDT.R::info_chunk(
      "Session packages", date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)
    print(sessioninfo::session_info()$packages, n = Inf)

    IASDT.R::info_chunk(
      "Session info", date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)
    print(sessioninfo::session_info()$platform)

    # warnings
    Warnings <- warnings()
    if (length(Warnings) > 0) {
      IASDT.R::info_chunk(
        "Warnings", date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)
      print(Warnings)
    }

  })
