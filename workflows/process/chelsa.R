# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes the CHELSA data for the invasive alien species digital 
# twin (BioDT project).
# Author: Ahmed El-Gabbas
# Last update: 2025-04-13
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed
# - CHELSA tif files are already available on disk


# increase the number of warnings to be reported
options(nwarnings = 200)

# activate renv
renv_path <- "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/"
suppressWarnings(renv::load(project = renv_path, quiet = FALSE))

# load packages
purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr",
    "sf", "IASDT.R", "ncdf4", "rlang"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# processing CHELSA data
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

result <- rlang::try_fetch(
  {

    IASDT.R::info_chunk("Processing CHELSA data", cat_date = TRUE, level = 1)

    IASDT.R::CHELSA_process(
      # env_file = ".env",
      n_cores = 40,
      download = FALSE,
      # overwrite = FALSE,
      # download_attempts = 10,
      # sleep = 5,
      # other_variables = "npp",
      # download_n_cores = 4,
      # compression_level = 5,
      # overwrite_processed = FALSE
    )

  },

  warning = {

    Warnings <- warnings()
    if (length(Warnings) > 0) {
      IASDT.R::info_chunk("Warnings", cat_date = TRUE)
      print(Warnings)
    }

  },

  error = function(e) {

    # Handle errors and ensure proper output order
    IASDT.R::info_chunk("Error message", cat_date = TRUE)
    cat("Error:", conditionMessage(e), "\n\n")

    # Capture the traceback
    traceback <- rlang::trace_back()
    IASDT.R::info_chunk("Traceback", cat_date = TRUE)
    print(traceback)

    IASDT.R::info_chunk("Error", cat_date = TRUE)
    print(e)
  })

# Session information
IASDT.R::info_chunk("Session packages", cat_date = TRUE)
print(sessioninfo::session_info()$packages, n = Inf)

IASDT.R::info_chunk("Session info", cat_date = TRUE)
print(sessioninfo::session_info()$platform)
