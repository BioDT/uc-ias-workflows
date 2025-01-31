options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))


## eLTER ------

IASDT.R::InfoChunk("Processing eLTER data", Date = TRUE, Extra2 = 1)

IASDT.R::elTER_Process(
	#FromHPC = TRUE, 
	#EnvFile = ".env", 
	#StartYear = 1981
)

warnings()