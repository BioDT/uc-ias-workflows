# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# This script processes the biogeographical regions data for the IASDT project.
# Author: Ahmed El-Gabbas
# Last update: 2025-03-17
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

options(nwarnings = 200) # increase the number of warnings to be reported

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

purrr::walk(
  c("dplyr", "terra", "purrr", "sf", "IASDT.R", "tibble", "fs", "rvest",
    "httr", "stringr", "tidyselect", "foreign"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# processing biogeographical regions data
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Ch1("Processing Biogeographical regions")

IASDT.R::BioReg_Process(
  # EnvFile = ".env"
)
