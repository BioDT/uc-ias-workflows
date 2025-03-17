options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
	c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
	~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## EASIN ------

IASDT.R::InfoChunk(
	"Processing EASIN data", Date = TRUE, Extra2 = 1)

IASDT.R::EASIN_Process(
	# ExtractTaxa = TRUE,
	# ExtractData = TRUE,
	NDownTries = 20L,
	NCores = 8L,
	# SleepTime = 10L,
	# NSearch = 1000L,
	# EnvFile = ".env",
	# DeleteChunks = TRUE,
	# StartYear = 1981L,
	# Plot = TRUE
)

warnings()
