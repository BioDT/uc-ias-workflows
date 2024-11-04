options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = ".", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## EASIN ------

IASDT.R::InfoChunk(
	"Processing EASIN data", Date = TRUE, Extra2 = 1)

IASDT.R::EASIN_Process(
	#ExtractTaxa = TRUE,
	#ExtractData = TRUE,
	NDownTries = 20,
	NCores = 8,
	#SleepTime = 10,
	#NSearch = 1000,
	#FromHPC = TRUE,
	#EnvFile = ".env",
	#DeleteChunks = TRUE,
	#StartYear = 1981,
	#Plot = TRUE
)

warnings()