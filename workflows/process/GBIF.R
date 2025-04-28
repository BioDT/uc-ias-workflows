# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes GBIF data for the  invasive alien species digital 
# twin (BioDT project).
# Author: Ahmed El-Gabbas
# Last update: 2025-04-13
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed
# - change path to a valid .Renviron file containing GBIF credentials


# increase the number of warnings to be reported
options(nwarnings = 200)

# activate renv
renv_path <- "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/"
suppressWarnings(renv::load(project = renv_path, quiet = FALSE))

# Path of the .Renviron file
r_environ = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/.Renviron"

# load packages
purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf",
    "IASDT.R", "writexl", "rgbif", "rlang"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# Processing GBIF data
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

result <- rlang::try_fetch(
  {

    IASDT.R::info_chunk("Processing GBIF data", cat_date = TRUE, level = 1)

    IASDT.R::GBIF_process(
      # env_file = ".env",
      r_environ = r_environ,
      n_cores = 40L,
      # request = TRUE,
      # download = TRUE,
      # split_chunks = TRUE,
      # overwrite = FALSE,
      # delete_chunks = TRUE,
      # chunk_size = 50000L,
      # boundaries = c(-30, 50, 25, 75),
      # start_year = 1981L
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
