
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Basic functions/scripts that need to be loaded in all R files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ******************************************
# What's in this script:
# ******************************************
# 
# - Authors: Ahmed El-Gabbas
# - Last tested / edited: 14.02.2024
# 
# - This script is planned to be sourced at the beginning of each R script in this repository
# 
## |--> record starting time of sourcing any R script
## |--> Load `renv` and check/install for `IASDT.R` updates
## |--> load important R packages and print the names of loaded packages
## |--> load environment variables from `.env` file
## |--> detect the number of available cores
## |--> print the available objects resulted from sourcing this file
# 
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕
# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Loading `renv` and update `IASDT.R` ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk(paste0(crayon::bold("sourcing `AlwaysLoad.R` file")))

options(stringsAsFactors = FALSE, renv.verbose = FALSE)

# Save Session Info ?
IASDT.R::AssignIfNotExist(.SaveSession, TRUE)

# Starting time
IASDT.R::AssignIfNotExist(.StartTime, lubridate::now(tzone = "CET"))

# loading renv
renv::load(project="/pfs/lustrep3/users/khantaim/iasdt-workflows/iasdt-renv/", quiet = TRUE)

# Updating IASDT.R
# This can cause issue, and thus should be updated manually
# invisible(suppressWarnings(suppressMessages({
#   # update/reload IASDT.R
#   renv::update("IASDT.R", prompt = FALSE)
#   devtools::reload(pkgload::inst("IASDT.R"), quiet = FALSE)
# })))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Loading packages ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::CatTime(paste0(crayon::bold("\nLoading packages")))

require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(IASDT.R, quietly = TRUE, warn.conflicts = FALSE)

IASDT.R::cc(
  # future.apply
  magrittr, cli, crayon, data.table, furrr, glue, tictoc, dplyr,
  parallel, pbapply, purrr, raster, readr, readxl, rgbif, rlang, lubridate, 
  rvest, sf, snow, stringr, terra, tidyr, vroom, writexl, xml2) %>% 
  IASDT.R::LoadPackages(List = ., Verbose = FALSE)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# System information ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# # System information ----
# IASDT.R::CatTime(paste0(crayon::bold("\nSystem information")))
# print(sessioninfo::platform_info(), n = Inf)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Names of loading packages ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# IASDT.R::CatTime(paste0(crayon::bold("\nCurrently loaded packages")))
# sessioninfo::package_info() %>% 
#   print(n = Inf)

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# conflicts ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# declare "winners" of conflicts
# conflicted::conflict_prefer("select", "dplyr", quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::select, .quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::filter, .quiet = TRUE)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Environment variables ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("\nReading environment variables:\n")))
readRenviron(".env")

IASDT.R::AssignIfNotExist(.assignAllVars, FALSE)

.EnvVarList <- readr::read_delim(
  file = ".env", delim = " = ", col_names = FALSE, col_types = "c")

if ((nrow(.EnvVarList) > 0) && .assignAllVars) {
  .EnvVarList <- .EnvVarList %>% 
    setNames(c("Variable", "Value")) %>% 
    dplyr::mutate(Value = stringr::str_remove_all(Value, "^\\'|\\'$"))
  
  cat("   Assigning environment variables to local variables:\n")
  
  seq_len(nrow(.EnvVarList)) %>% 
    purrr::map(.f = ~{
      assign(
        x = .EnvVarList$Variable[.x], 
        value = .EnvVarList$Value[.x], envir = global_env())
      paste0(
        "   >> ", .EnvVarList$Variable[.x], 
        " <- ", .EnvVarList$Value[.x], "\n") %>% 
        cat()
    }) %>% 
    invisible()
} else {
  cat(" >>>> Environment variables was NOT assigned to variables\n")
  if (nrow(.EnvVarList) > 1) {
    cat(" Current list of environment variables:\n\n")
    print(.EnvVarList, n = Inf)
  }
}

rm(.assignAllVars)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ****************************************************
# Number of cores to run in parallel -----
# ****************************************************

.OS_Name <- sessioninfo::platform_info() %>% 
  magrittr::extract2("os")

# .NCores <- dplyr::case_when(
#   # windows server has >200 cores, only use a maximum of 30 cores
#   stringr::str_detect(.OS_Name, "^Windows Server ") ~ min((parallel::detectCores() - 1), 30),
#   # use all available cores when running on HPC
#   stringr::str_detect(.OS_Name, "Linux") ~ parallel::detectCores(),
#   .default = parallel::detectCores() - 1)

.NCores <- min(parallel::detectCores(), 50)

# print the number of available/used cores; only once per session
paste0(
  crayon::bold("\nNumber of cores: "), parallel::detectCores(),
  " detected; ", .NCores, " to be used") %>% 
  rlang::inform(.frequency = "always", .frequency_id = ".NCores")

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Available objects ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# IASDT.R::CatTime(crayon::bold("\nAvailable object names in the global environment"))
# 
# globalenv() %>% 
#   ls() %>% 
#   paste0("  >> ", ., collapse = "\n") %>% 
#   cat()
# 
# cat("\n")
# IASDT.R::CatSep(Rep = 2, Extra1 = 1, Extra2 = 1, Char = "|", CharReps = 60)
# 
# invisible(gc())

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# options for purrr progress bar ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

.ProgrOptns <- list(
  type = "iterator", clear = TRUE,
  format = "{cli::pb_bar} {cli::pb_percent} [{cli::pb_elapsed}]")
