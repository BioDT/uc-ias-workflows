# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes EASIN data for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-04-09
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# needed changes:
# - change path of the renv project
# - change path to `.env` file, if needed


tryCatch(
  {

    # increase the number of warnings to be reported
    options(nwarnings = 200)

    # activate renv
    suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

    # load packages
    purrr::walk(
      c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
      ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # Processing EASIN data
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    IASDT.R::info_chunk(
      "\tProcessing EASIN data",
      date = TRUE, lines_after = 1, bold = TRUE, red = TRUE)

    IASDT.R::EASIN_process(
      # extract_taxa = TRUE,
      # extract_data = TRUE,
      n_download_attempts = 20L,
      n_cores = 8L,
      # sleep_time = 10L,
      # n_search = 1000L,
      # env_file = ".env",
      # delete_chunks = TRUE,
      # start_year = 1981L,
      # plot = TRUE
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
    print(sessioninfo::session_info()$packages, n = Inf) n = Inf) n = Inf)

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
