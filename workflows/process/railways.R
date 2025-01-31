options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## Railways ------

IASDT.R::InfoChunk("Processing railway intensity", Date = TRUE, Extra2 = 1)

IASDT.R::Railway_Intensity(
	#FromHPC = TRUE, 
	#EnvFile = ".env", 
	NCores = 15, 
	#DeleteProcessed = TRUE
)

warnings()