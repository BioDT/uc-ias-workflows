options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "archive"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## river length ------

IASDT.R::InfoChunk("Processing river length", Date = TRUE, Extra2 = 1)

IASDT.R::River_Length(
  # EnvFile = ".env",
  # Cleanup = FALSE
)

warnings()
