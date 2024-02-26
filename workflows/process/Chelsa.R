IASDT.R::SourceSilent("_Scripts/0_1_AlwaysLoad.R")

# Loading packages
IASDT.R::LoadPackages(
  dplyr, stringr, IASDT.R, terra, raster, snow, future, purrr, furrr, lubridate)

StatingTime <- lubridate::now(tzone = "CET")

# Should the analyses done on parallel
ProcessParallel <- FALSE

# Input/output folders for tif files
Path_In <- "Data/Chelsa/Tif_Input"
Path_Out <- "Data/Chelsa/Tif_Output"

# Reference grid to mask the output to
RefGrid <- "Data/Maps/Grid/Grid_10_Land_Crop.RData" %>% 
  IASDT.R::LoadAs() %>%
  terra::rast() %>% 
  terra::wrap()

# List of tif file to process
Chelsa_List <- Path_In %>% 
  list.files(pattern = ".tif$",  full.names = TRUE) %>% 
  tibble::tibble(Input = .) %>% 
  dplyr::mutate(Output = stringr::str_replace(Input, Path_In, Path_Out))


if (ProcessParallel) {
  
  IASDT.R::InfoChunk("Projecting CHELSA maps --- working on parallel")
  
  IASDT.R::CatTime("Preparing working on parallel")
  c1 <- snow::makeSOCKcluster(.NCores)
  future::plan(cluster, workers = c1, gc = TRUE)
  
  Chelsa_List %>% 
    dplyr::mutate(
      Process = furrr::future_map2(
        .x = Input, .y = Output, 
        .f = ~{
          IASDT.R::CatTime(basename(.x))
          IASDT.R::Chelsa_Project(
            InputFile = .x, OutFile = .y, 
            GridFile = terra::unwrap(RefGrid))
        },
        .progress = FALSE, .options = furrr::furrr_options(seed = TRUE))) %>% 
    invisible()  
  
} else {
  
  IASDT.R::InfoChunk("Projecting CHELSA maps --- working sequentially")
  
  Chelsa_List %>% 
    dplyr::mutate(
      Process = purrr::map2(
        .x = Input, .y = Output, 
        .f = ~{
          IASDT.R::CatTime(basename(.x))
          IASDT.R::Chelsa_Project(
            InputFile = .x, OutFile = .y, GridFile = terra::unwrap(RefGrid))
        },
        .progress = FALSE)) %>% 
    invisible()
}


lubridate::now(tzone = "CET") %>% 
  difftime(StatingTime, units = "mins") %>% 
  as.numeric() %>% 
  round(2) %>% 
  stringr::str_c("\nFinished in ", ., " minutes") %>%
  IASDT.R::CatTime(... = "\n")
