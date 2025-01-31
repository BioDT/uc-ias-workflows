options(nwarnings = 200)

suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## CLC ------

IASDT.R::InfoChunk("Processing CLC data", Date = TRUE, Extra2 = 1)

IASDT.R::CLC_Process(
	#EnvFile = ".env", 
	#FromHPC = TRUE, 
	#MinLandPerc = 15,
	#PlotCLC = TRUE
)

warnings()