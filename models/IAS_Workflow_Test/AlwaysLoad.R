
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Basic functions/scripts that need to be loaded in all R files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ******************************************
# What's in this script:
# ******************************************
# 
# - Authors: Ahmed El-Gabbas [ahmed.el-gabbas@ufz.de]
# - Last tested/edited: 30.05.2024
# 
# - This script is planned to be sourced at the beginning of each R script in this repository
# 
## |--> record starting time of sourcing any R script
## |--> Load `renv`
## |--> load important R packages and print the names of loaded packages
## |--> load environment variables from the `.env` file
## |--> detect the number of available cores
## |--> print the available objects resulting from sourcing this file
# 
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕
# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕

if (stringr::str_detect(sessioninfo::os_name(), "SUSE Linux")) {
  invisible(renv::load(quiet = TRUE))
}


IASDT.R::InfoChunk(paste0(crayon::bold("Sourcing `AlwaysLoad.R` file")))

# Starting time
.StartTime <- lubridate::now(tzone = "CET")

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# System information ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

.OS_Name <- sessioninfo::os_name()

cat(paste0(
  crayon::bold("System information "),
  crayon::bold("\n >> OS: "), .OS_Name,
  crayon::bold("\n >> Library path: "), paste0(.libPaths(), collapse = " && "),
  crayon::bold("\n >> R version: "), R.version.string,
  crayon::bold("\n >> R path: "), R.home(),
  crayon::bold("\n\nPlatform info \n")
))
print(sessioninfo::platform_info(), n = Inf)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Options / loading `renv` ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# loading renv / packages ----

suppressPackageStartupMessages({
  require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
  require(magrittr, quietly = TRUE, warn.conflicts = FALSE)
  require(IASDT.R, quietly = TRUE, warn.conflicts = FALSE)
  })

cat(paste0(crayon::bold("\nLoading renv\n")))

# do not use renv on the MSG windows server. Using it on the Y drive makes the session too slow, particularly when working on parallel
if (magrittr::not(stringr::str_detect(.OS_Name, "Windows Server "))) {
  renv::load(quiet = FALSE)
} else {
  cat("Working from MSG Windows server; renv was not loaded\n")
}

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Global options ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("\nSetting global options\n")))
options(stringsAsFactors = FALSE, renv.verbose = FALSE)
terra::setGDALconfig("GTIFF_SRS_SOURCE", "EPSG")

# reduce debug output from tensorflow
Sys.setenv(TF_CPP_MIN_LOG_LEVEL = 3)


if (stringr::str_detect(.OS_Name, "Linux")) {
  # Maximum allowed total size (in bytes) of global variables identified.
  # If set of +Inf, then the check for large globals is skipped. (Default: 500 * 1024 ^ 2 = 500 MiB)
  # avoid killing parallel jobs if the size of the global variables exceeds a certain value
  # https://search.r-project.org/CRAN/refmans/future/html/future.options.html
  options(future.globals.maxSize = 8000 * 1024^2)
}

# Save Session Info?
IASDT.R::AssignIfNotExist(.SaveSession, TRUE)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Loading packages ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("\nLoading packages")))

IASDT.R::LoadPackages(
  List = IASDT.R::cc(
    tidyverse, crayon, furrr, parallelly, future, fs, parallel, 
    raster, sf, snow, terra, IASDT.R, tidyselect), 
  Verbose = TRUE)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Environment variables ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("\nEnvironment variables\n")))

if (file.exists(".env"))  {
  readRenviron(".env")
  .EnvList <- readr::read_delim(
    file = ".env", delim = "=", col_names = c("Var", "Val"),
    col_types = "c")
  
  cat(".env file was found and read --- List of loaded environmental variables:\n")
  .EnvList$Var %>%
    paste0("  --> ", .) %>% 
    sort() %>% 
    purrr::walk(cat, sep = "\n")
  
} else {
  cat("  >> `.env` file does not exist. No environment variables were loaded\n")
}

# 
# if ((nrow(.EnvList) > 0) && .assignAllVars) {
#   cat("  >> Assigning environment variables to local variables:\n")
#   seq_len(nrow(.EnvList)) %>% 
#     purrr::map(
#       .f = ~{
#         assign(
#           x = .EnvList$Var[.x], value = .EnvList$Val[.x], 
#           envir = rlang::global_env())
#         IASDT.R::CatTime(paste0(" >>> ", .EnvList$Var[.x]))
#       })
# } else {
#   cat("  >> Environment variables was NOT assigned to variables\n")
#   if (nrow(.EnvList) > 1) {
#     cat(" Current list of environment variables:\n\n")
#     print(.EnvList, n = Inf)
#   }
# }
# 
# rm(.assignAllVars)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ****************************************************
# Number of cores to run in parallel -----
# ****************************************************

# `parallel::detectCores()` may give incorrect information on LUMI
# here I use `parallelly::availableCores()` instead
# Check: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/r/R/#known-restrictions

.NCores <- dplyr::case_when(
  # Windows server has >200 cores, only use a maximum of 30 cores
  stringr::str_detect(.OS_Name, "^Windows Server ") ~ min((parallelly::availableCores()), 30),
  # use all available cores when running on HPC
  stringr::str_detect(.OS_Name, "Linux") ~  min((parallelly::availableCores()), 50),
  .default = parallelly::availableCores() - 1)

# print the number of available/used cores; only once per session
paste0(
  crayon::bold("\nNumber of Cores: "), parallelly::availableCores(),
  " detected; ", .NCores, " to be used\n\n") %>% 
  cat()

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# options for purrr/furrr ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# options for purrr progress bar
.ProgrOptns <- list(
  type = "iterator", clear = TRUE,
  format = "{cli::pb_bar} {cli::pb_percent} [{cli::pb_elapsed}]")

.FurrrOpt <- furrr::furrr_options(seed = TRUE, scheduling = Inf)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Available objects ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

crayon::bold("Available objects in the global environment\n") %>% 
  cat()

globalenv() %>%
  ls(all.names = TRUE) %>%
  setdiff(".Random.seed") %>% 
  paste0("  >> ", ., collapse = "\n") %>% 
  cat()

cat("\n")

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Misc ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# 
## Names of loading packages ----
# IASDT.R::CatTime(paste0(crayon::bold("\nCurrently loaded packages")))
# print(sessioninfo::package_info(), n = Inf)

## conflicts ----
# conflicted::conflict_prefer("select", "dplyr", quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::select, .quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::filter, .quiet = TRUE)
