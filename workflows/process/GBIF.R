# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes GBIF data for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-04-09
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed
# - change path to a valid .Renviron file containing GBIF credentials

tryCatch(
  {

    # Path of the .Renviron file
    r_environ = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/.Renviron"

    # increase the number of warnings to be reported
    options(nwarnings = 200)

    # activate renv
    suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

    # load packages
    purrr::walk(
      c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "writexl", "rgbif"),
      ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # Processing GBIF data
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    IASDT.R::info_chunk(
      "\tProcessing GBIF data", date = TRUE, bold = TRUE, red = TRUE)

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

  error = function(e) {

    # Error message if the script fails
    IASDT.R::info_chunk("Error message", date = TRUE, bold = TRUE, red = TRUE)
    print(paste("Error:", e$message))

  },

  finally = {

    # Session information
    IASDT.R::info_chunk(
      "Session packages", date = TRUE, bold = TRUE, red = TRUE)
    print(sessioninfo::session_info()$packages, n = Inf)

    IASDT.R::info_chunk("Session info", date = TRUE, bold = TRUE, red = TRUE)
    print(sessioninfo::session_info()$platform)

    # warnings
    Warnings <- warnings()
    if (length(Warnings) > 0) {
      IASDT.R::info_chunk("Warnings", date = TRUE, bold = TRUE, red = TRUE)
      print(Warnings)
    }

  })
