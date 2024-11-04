options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = ".", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## Sampling efforts ------

IASDT.R::InfoChunk(
	"Processing sampling efforts", Date = TRUE, Extra2 = 1)

IASDT.R::Efforts_Process(
	FromHPC = TRUE,
	# EnvFile = ".env",
	Renviron = "/pfs/lustrep4/users/elgabbas/.Renviron",
	RequestData = TRUE, # If this is true, the function took 9 hours using 30 cores
	#DownloadData = TRUE,
	NCores = 30,
	#StartYear = 1981,
	#Boundaries = c(-30, 50, 25, 75),
	#ChunkSize = 1e+05,
	#DeleteChunks = TRUE,
	#DeleteProcessed = TRUE
)

warnings()