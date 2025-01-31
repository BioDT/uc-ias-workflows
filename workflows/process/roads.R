options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "archive"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## Roads ------

IASDT.R::InfoChunk("Processing road intensity", Date = TRUE, Extra2 = 1)

IASDT.R::Road_Intensity(
	#FromHPC = TRUE, 
	#EnvFile = ".env"
)

warnings()