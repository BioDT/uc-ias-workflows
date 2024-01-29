renv::restore(project="/users/khantaim/iasdt-workflows/iasdt-renv")

# ****************************************************
# ****************************************************

require(dplyr, quietly = TRUE)

# ****************************************************
# ****************************************************

# LoadPackages ----
# © Ahmed El-Gabbas - May 2023 

LoadPackages <- function(Package) {
  PG <- rlang::quo_name(rlang::enquo(Package))
  suppressWarnings(suppressMessages(library(PG, character.only = TRUE)))
  
  Ver <- eval(parse(text = glue::glue('packageVersion("{PG}")')))
  cat(glue::glue(">>> {PG} - v {Ver}\n\n"))
  
  return(invisible(NULL))  
}

# ****************************************************
# ****************************************************

# catSep ----
# © Ahmed El-Gabbas - May 2023

catSep <- function(
    Rep = 1, Extra1 = 0, Extra2 = 0, Char = "-", CharReps = 50) {
  if (Extra1 > 0) {
    replicate(n = Extra1, expr = cat("\n"))
  }
  S <- c(rep(Char, CharReps)) %>% paste0(collapse = "")
  replicate(n = Rep, expr = cat(S, sep = "\n"))
  if (Extra2 > 0) {
    replicate(n = Extra2, expr = cat("\n"))
  }
  return(invisible(NULL))
}

# ****************************************************
# ****************************************************

# LoadAs ----
# © Ahmed El-Gabbas - February 2023 

LoadAs <- function(File = NA) {
  InFile0 <- load(File)
  if (length(InFile0) == 1) {
    OutFile <- get(paste0(InFile0))
  } else {
    OutFile <- lapply(InFile0, function(x) {
      get(paste0(x))
    })
    names(OutFile) <- InFile0
  }
  return(OutFile)
}

# ****************************************************
# ****************************************************

# CatTime ----
# © Ahmed El-Gabbas - May 2023 

# Text: the text to print
# NLines: number of empty lines after the printing; default: 1
CatTime <- function(Text, NLines = 1, ...) {
  cat(paste0(Text, " - ", format(Sys.time(), "%X")), ...)
  cat(rep("\n", NLines), ...)
}

# ****************************************************
# ****************************************************

LogFile <- "./data/logs/CHELSA_log.txt"
sink(LogFile)


catSep(Rep = 2, Extra1 = 0, Extra2 = 0)
Now <- format(Sys.time(), "%e %b %Y - %H:%M:%S")
cat(glue::glue("projecting CHELSA to ESPG 3035 - {Now}"))
catSep(Rep = 2, Extra1 = 1, Extra2 = 1)

# ****************************************************
# ****************************************************

CatTime("Loading packages")

LoadPackages(dplyr)
LoadPackages(raster)
LoadPackages(terra)
LoadPackages(stringr)
LoadPackages(parallel)
LoadPackages(purrr)
LoadPackages(glue)
LoadPackages(tictoc)

cat("\n")

# require(dplyr)
# require(raster)
# require(terra)
# require(stringr)
# require(parallel)
# require(purrr)
# require(glue)
# require(tictoc)
# require(rlang)

# ****************************************************
# ****************************************************

# InputPath --- Path for input tif files (all tiff files in the folder will be processed)
# OutPath --- Path for output tif files
# NCores --- Number of cores to be used in projection; default: NULL means detect available cores
# GridFile --- Path for the reference grid 

ProjectChelsa <- function(
  InputPath, OutPath, NCores = NULL,
  GridFile = "Grid_10_Raster.RData") {
  
  tictoc::tic()
  
  if(is.null(NCores)) {
    NCores <- parallel::detectCores() - 1
  }
  
  catSep(Rep = 1, Extra1 = 0, Extra2 = 1)
  CatTime(glue::glue("Processing CHELSA data using {NCores} Cores"))
  
  # reference grid layer
  CatTime("- Loading gird file")
  Grid_10_Rast <- LoadAs(GridFile) %>% 
    terra::rast()
  
  # List of input and output files
  InputFiles <- list.files(path = InputPath, pattern = ".tif$", full.names = TRUE)
  OutFiles <- stringr::str_replace(
    string = InputFiles, pattern = InputPath, replacement = OutPath)
  
  # Progressing files
  CatTime("- Progressing files")
  purrr::map2(
    .x = InputFiles, .y = OutFiles, 
    .f = ~{
      CatTime(glue::glue("     --> {basename(.x)}"))
      
      Rstr <- .x %>% 
        # read tif file as terra rast object
        terra::rast() %>% 
        # project to reference grid
        terra::project(
          Grid_10_Rast, method = "average", threads = NCores) %>%
        # convert back to raster object
        raster::raster()
      
      # Ensure that the object is located in memory, not reading from temporary file
      # This is not necessary as we save the file as .tif file not .RData
      if (raster::fromDisk(Rstr)) {
        Rstr <- raster::readAll(Rstr)
      }
      
      # Write file to disk
      terra::writeRaster(
        x = terra::rast(Rstr), filename = .y, overwrite = TRUE)
    }) %>% 
    # do not print the output
    invisible()
  
  catSep(Rep = 1, Extra1 = 1, Extra2 = 0)
  
  # Check if all files were processed successfully
  if(all(file.exists(OutFiles))) {
    CatTime(glue::glue("\n\nAll CHELSA files ({length(OutFiles)} files) were processed successfully"))
  } else {
    Missing <- basename(OutFiles[!file.exists(OutFiles)])
    CatTime(glue::glue("\n{length(Missing)} files were not processed"))
    cat(glue::glue("  >>> {Missing}"), sep = "\n")
  }
  
  tictoc::toc()
  cat("\n")
  
  return(NULL)
}

# ****************************************************
# ****************************************************

ProjectChelsa(
  InputPath = "/users/khantaim/iasdt-workflows/datasets/raw/chelsa/", 
  OutPath = "/users/khantaim/iasdt-workflows/datasets/interim/chelsa/",
  NCores = NULL, 
  GridFile = "/users/khantaim/iasdt-workflows/references/Grid_10_Raster.RData") %>%
  invisible()

catSep(Rep = 2, Extra1 = 0, Extra2 = 0)

sink()
