options(nwarnings = 200)

# source("renv/activate.R")
suppressWarnings(renv::load(project = "/pfs/lustrep1/scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE))

purrr::walk(
    c("dplyr", "terra", "purrr", "sf", "IASDT.R", "tibble", "fs", "rvest", 
    "httr", "stringr", "tidyselect", "foreign"),
    ~ suppressWarnings(suppressMessages(require(.x, character.only = TRUE))))

## Railways ------

IASDT.R::InfoChunk("Processing Biogeographical regions", Date = TRUE, Extra2 = 1)

IASDT.R::BioReg_Process(
    # EnvFile = ".env"
    )

warnings()
