source("/pfs/lustrep4/users/elgabbas/BioDT_IAS/.Rprofile")
options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = ".", quiet = TRUE))

purrr::walk(
  c("dplyr", "terra", "ggplot2", "furrr", "purrr", "sf", "IASDT.R", "ncdf4"),
  ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))


## CHELSA ------

IASDT.R::InfoChunk(
	"Processing CHELSA data", Date = TRUE, Extra2 = 1)

IASDT.R::CHELSA_Process(
	#FromHPC = TRUE,
	#EnvFile = ".env", 
	NCores = 40,
	Download = FALSE,
    #Overwrite = FALSE,
	#Download_Attempts = 10,
	#Sleep = 5,
    #BaseURL = "https://os.zhdk.cloud.switch.ch/envicloud/chelsa/chelsa_V2/GLOBAL/",
    #Download_NCores = 6,
	#CompressLevel = 5,
	#OverwriteProcessed = FALSE
)

warnings()
