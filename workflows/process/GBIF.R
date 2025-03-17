options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "writexl", "rgbif"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## GBIF ------

IASDT.R::InfoChunk("Processing GBIF data", Date = TRUE, Extra2 = 1)

IASDT.R::GBIF_Process(
	# EnvFile = ".env",
  Renviron = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/.Renviron", # Need to read from .env file or set manually
  NCores = 40L, 
  # Request = TRUE,
  # Download = TRUE,
  # SplitChunks = TRUE,
  # Overwrite = FALSE, 
  # DeleteChunks = TRUE,
  # ChunkSize = 50000L,
  # Boundaries = c(-30, 50, 25, 75),
  # StartYear = 1981L
)

warnings()
