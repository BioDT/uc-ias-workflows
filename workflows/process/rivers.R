# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes river length for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-04-09
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed
# - raw river data needs to be downloaded and copied to the respective directory

tryCatch(
  {

    # increase the number of warnings to be reported
    options(nwarnings = 200)

    # activate renv
    suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

    # load packages
    purrr::walk(
      c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "archive"),
      ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # Processing river length
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    IASDT.R::info_chunk(
      "\tProcessing river length",
      date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)

    IASDT.R::river_length(
      # env_file = ".env",
      # cleanup = FALSE
    )

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
