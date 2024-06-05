
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
# - Last tested/edited: 29.02.2024
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

require(IASDT.R, quietly = TRUE, warn.conflicts = FALSE)

IASDT.R::InfoChunk(paste0(crayon::bold("Sourcing `0_1_AlwaysLoad.R` file")))


# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Options / loading `renv` ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

options(
  stringsAsFactors = FALSE, renv.verbose = FALSE,
  # Maximum allowed total size (in bytes) of global variables identified.
  # If set of +Inf, then the check for large globals is skipped. (Default: 500 * 1024 ^ 2 = 500 MiB)
  # avoid killing parallel jobs if the size of the global variables exceeds a certain value
  # https://search.r-project.org/CRAN/refmans/future/html/future.options.html
  future.globals.maxSize = 8000 * 1024^2)
terra::setGDALconfig("GTIFF_SRS_SOURCE", "EPSG")

# Save Session Info?
IASDT.R::AssignIfNotExist(.SaveSession, TRUE)
# Starting time
IASDT.R::AssignIfNotExist(.StartTime, lubridate::now(tzone = "CET"))

# loading renv
#TODO: TK -- add project = "path/to/project" to avoid loading the wrong renv
invisible(renv::load(quiet = TRUE))

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Loading packages ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("Loading common-use packages\n")))

IASDT.R::LoadPackages(
  List = IASDT.R::cc(
    tidyverse, magrittr, crayon, furrr, parallelly, future, fs, parallel, 
    raster, sf, snow, terra, IASDT.R, tidyselect), 
  Verbose = FALSE)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Environment variables ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

cat(paste0(crayon::bold("Loading environment variables\n")))

if (file.exists(".env"))  {
  readRenviron(".env")
  cat("  >> `.env` file was found and read\n")
} else {
  cat("  >> `.env` file does not exist. No environment variables were loaded\n")
}

# .EnvList <- readr::read_delim(
#   file = ".env", delim = "=", col_names = c("Var", "Val"), 
#   col_types = "c")
# 
# cat("List of loaded environmental variables\n")
# .EnvList$Var %>% 
#   paste0("  --> ", .) %>% 
#   purrr::walk(cat, sep = "\n")
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

.OS_Name <- sessioninfo::os_name()

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
  crayon::bold("# Cores: "), parallelly::availableCores(),
  " detected; ", .NCores, " to be used\n") %>% 
  cat()

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# options for purrr progress bar ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

.ProgrOptns <- list(
  type = "iterator", clear = TRUE,
  format = "{cli::pb_bar} {cli::pb_percent} [{cli::pb_elapsed}]")

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
## System information ----
# IASDT.R::CatTime(paste0(crayon::bold("\nSystem information")))
# print(sessioninfo::platform_info(), n = Inf)

## Names of loading packages ----
# IASDT.R::CatTime(paste0(crayon::bold("\nCurrently loaded packages")))
# print(sessioninfo::package_info(), n = Inf)

## conflicts ----
# conflicted::conflict_prefer("select", "dplyr", quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::select, .quiet = TRUE)
# conflicted::conflicts_prefer(dplyr::filter, .quiet = TRUE)
