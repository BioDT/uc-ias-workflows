options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = ".", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "writexl", "rgbif"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## GBIF ------

IASDT.R::InfoChunk("Processing GBIF data", Date = TRUE, Extra2 = 1)

IASDT.R::GBIF_Process(
	#FromHPC = TRUE,
	#EnvFile = ".env",
    Renviron = "/pfs/lustrep4/users/elgabbas/.Renviron",
    NCores = 40, 
    RequestData = TRUE,
    #DownloadData = TRUE,
    #SplitChunks = TRUE,
    #Overwrite = FALSE, 
    DeleteChunks = TRUE,
    #ChunkSize = 50000,
    #Boundaries = c(-30, 50, 25, 75),
    #StartYear = 1981
)

warnings()