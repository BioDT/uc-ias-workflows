# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Chelsa data
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ******************************************
# What's in this script:
# ******************************************
# 
# - Ahmed El-Gabbas [ahmed.el-gabbas@ufz.de]
# - March 2023 / April 2024
# - - The script was tested on LUMI (01.04.2024; all 46 variables; 2116 tif files) as a SLURM job outside of the data workflow
# - - took c.a. 14 mins on LUMI (parallel using 50 cores / 150 GB requested memory) and 3 hours 10 mins when running sequentially
#
## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#
# - This script processes Chelsa data using `IASDT.R::Chelsa_Project()` function: 
# - - use Chelsa mask layer for land/sea grid cells before projection ('i.e. exclude marine grid cells before the calculation)
# - - project original Chelsa data (30 arc seconds ~ 1 km) into the reference grid (EPSG:3035; 10 km).
# - - mask to IASDT reference grid cell (only countries of interest; excluding grid cells with <15 % land).
# - - manually apply scale and offset information.
# - - Possibility to run sequentially or in parallel
#
## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#
# - - There are 46 potential Chelsa variables (listed below). The `IASDT.R::Chelsa_Project()` function was tested with all of these variables; however, we agreed (March 2024) only to consider a subset of the Bioclimatic variables (bio1-bio19) in the models.
# - - For each variable, there are 46 scenarios (current + 3 times * 5  climate models * 3 climate scenarios)
#
# - - Variables to consider (will be processed as NetCDF file at 46 time/model/CC scenarios). Only 6 bioclimatic variables will be used in the models (March 2024):
# ╔══════════╦═════════════════════════════════════════════════════════════════╗
# ║ bio1     ║ mean annual air temperature                                     ║
# ║ bio2     ║ mean diurnal air temperature range                              ║
# ║ bio3     ║ isothermality                                                   ║
# ║ bio4     ║ temperature seasonality                                         ║
# ║ bio5     ║ mean daily maximum air temperature of the warmest month         ║
# ║ bio6     ║ mean daily minimum air temperature of the coldest month         ║
# ║ bio7     ║ annual range of air temperature                                 ║
# ║ bio8     ║ mean daily mean air temperatures of the wettest quarter         ║
# ║ bio9     ║ mean daily mean air temperatures of the driest quarter          ║
# ║ bio10    ║ mean daily mean air temperatures of the warmest quarter         ║
# ║ bio11    ║ mean daily mean air temperatures of the coldest quarter         ║
# ║ bio12    ║ annual precipitation amount                                     ║
# ║ bio13    ║ precipitation amount of the wettest month                       ║
# ║ bio14    ║ precipitation amount of the driest month                        ║
# ║ bio15    ║ precipitation seasonality                                       ║
# ║ bio16    ║ mean monthly precipitation amount of the wettest quarter        ║
# ║ bio17    ║ mean monthly precipitation amount of the driest quarter         ║
# ║ bio18    ║ mean monthly precipitation amount of the warmest quarter        ║
# ║ bio19    ║ mean monthly precipitation amount of the coldest quarter        ║
# ╚══════════╩═════════════════════════════════════════════════════════════════╝
# - - Variables not processed
# ╔══════════╦═════════════════════════════════════════════════════════════════╗
# ║ gdgfgd0  ║ First growing degree day above 0°C                              ║
# ║ gdgfgd5  ║ First growing degree day above 5°C                              ║
# ║ gdgfgd10 ║ First growing degree day above 10°C                             ║
# ║ fcf      ║ Frost change frequency                                          ║
# ║ gdd0     ║ Growing degree days heat sum above 0°C                          ║
# ║ gdd5     ║ Growing degree days heat sum above 5°C                          ║
# ║ gdd10    ║ Growing degree days heat sum above 10°C                         ║
# ║ gddlgd0  ║ Last growing degree day above 0°C                               ║
# ║ gddlgd5  ║ Last growing degree day above 5°C                               ║
# ║ gddlgd10 ║ Last growing degree day above 10°C                              ║
# ║ gsl      ║ growing season length TREELIM                                   ║
# ║ gsp      ║ Accumulated precipitation amount on growing season days TREELIM ║
# ║ gst      ║ Mean temperature of the growing season TREELIM                  ║
# ║ lgd      ║ last day of the growing season TREELIM                          ║
# ║ fgd      ║ first day of the growing season TREELIM                         ║
# ║ ngd0     ║ Number of growing degree days                                   ║
# ║ ngd5     ║ Number of growing degree days                                   ║
# ║ ngd10    ║ Number of growing degree days                                   ║
# ║ kg0      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ kg1      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ kg2      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ kg3      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ kg4      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ kg5      ║ Köppen-Geiger climate classification [categorical]              ║
# ║ scd      ║ Snow cover days                                                 ║
# ║ swe      ║ Snow water equivalent                                           ║
# ║ npp      ║ Net primary productivity                                        ║
# ╚══════════╩═════════════════════════════════════════════════════════════════╝
#
## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#
# Initial inspecting of Chelsa data showed that there are 17 (BioClim+) variables having incomplete spatial coverage in Europe:
# ╔══════════╦═════════╦══════════╦══════════╦═════════╦══════════╗
# ║ fcf      ║ fgd     ║ gdd5     ║ gdd10    ║ gddlgd0 ║ gddlgd5  ║
# ║ gddlgd10 ║ gdgfgd0 ║ gdgfgd5  ║ gdgfgd10 ║ gsl     ║ gsp      ║
# ║ gst      ║ lgd     ║ ngd10    ║ ngd5     ║ swe     ║          ║
# ╚══════════╩═════════╩══════════╩══════════╩═════════╩══════════╝
# 
## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#
## |--> In the first version of the script I followed a long workflow: 
## |-->  -- download chelsa tif data, 
## |-->  -- crop to study area,
## |-->  -- split into smaller tiles,
## |-->  -- convert each tile to points,
## |-->  -- project points to EPSG:3035 using `raster` package, 
## |-->  -- rasterize points into a 10×10 km grid using the mean value (and possibly other functions) of points in each grid cell,
## |-->  -- mosaicing the tiles to a single layer per variable. 
## The main concern was that the `raster::projectRaster()` function supports only bilinear interpolation, in which only 4 original cell centroid points located close to the centroid of the new cell are used in the calculation of new values.
## This means that for Chelsa data, I extract a single value for each 10×10 km reference grid cell that represents the original ~100 grid cells. Therefore, the use of four points may not represent the mean value, particularly when the original data is heterogeneous over small distances.
#
## |--> I found that the subsequent terra package (`terra::project`) allows additional methods including cubic and cubicspline interpolation. Further, it allows for the same approach previously implemented: using `method = "average"` to calculate the mean of all non-NA contributing grid cells.
## Further, `terra` automatically considers the scale and offset values implemented by Chelsa, and then return values at the variable-specific unit (nevertheless this is not implemented; see below). see https://github.com/rspatial/terra/issues/1075. 
#
## |--> This script processed all tif files in the `Path_In` folder and processed them into NetCDF (and optionally also as tif) files in the `Path_Out` folder.
#
## |--> The current version of the `IASDT.R::Chelsa_Project()` function (March 2024) can process either pre-downloaded tif files or process files on the fly using the URL of the tif file (this saves disk space if the input files are not needed for further analyses).
## - Data from tif files are read as `raw`, which means that scale and offset are not read directly from the files; e.g. `terra::rast(..., raw = TRUE)`. The reason behind this is that some of the tif files (e.g. future scenarios for `npp`) lack scale and offset information, leading to a value mismatch between current and future climates. Scale and offset information were manually considered.
# - As Chelsa data also covers seas and oceans, the function uses the mask layer available at https://data.isimip.org/10.48364/ISIMIP.836809.3 to mask out (exclude) grid cells at the original resolution (30 arc seconds) that represent seas and oceans before projecting into the study area. Although grid cells with < 15% land (estimated from CLC maps) will be excluded anyway, I find it safer to use this mask layer before projection. Nevertheless, I found no substantial difference between using or not using the mask layer.
#
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
# <<< Data source: >>>>
#
# https://chelsa-climate.org/
# Original format: tif file - 30 arc seconds (~1 km) resolution - EPSG:326 (geographic coordinate system) - global - climatology (and other formats)
#
#
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
# <<< List of environment variables used in this script: >>>>
#
# DP_R_GridLandCrop
# DP_R_CHELSA_Parallel
# DP_R_CHELSA_NCores
# DP_R_CHELSA_InputPath
# DP_R_CHELSA_OutputPath
# DP_R_CHELSA_OutTif
# 
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕
# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# AlwaysLoad script -----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# This script is expected to be run at the beginning of any R script
# See the file content for more details. The main task here is to load essential packages, record starting time, the number of cores to be used, read environment variables, etc.
# source("workflows/process/alwaysLoad.R")
source("alwaysLoad.R")

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Environment variables -----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# Should the analyses be done in parallel
ProcessParallel <- as.logical(Sys.getenv("DP_R_CHELSA_Parallel"))
# e.g.: DP_R_CHELSA_Parallel=TRUE # [TRUE/FALSE should be all in capital letters]

# Number of cores used to process Chelsa data in parallel
# The following will replace the default value stored in the `alwaysLoad.R` script
.NCores <- as.integer(Sys.getenv("DP_R_CHELSA_NCores"))
# e.g.: DP_R_CHELSA_NCores=40

# Input folders for tif files
# complete path of CHELSA data (*.tif) without trailing slash
Path_In <- Sys.getenv("DP_R_CHELSA_InputPath")
# e.g.: DP_R_CHELSA_InputPath="/pfs/lustrep4/scratch/project_465000915/IASDT_Model_Test/Data/Chelsa/Download"

# Path for output files
# Complete path without trailing slash
# Files on this path will be overwritten
Path_Out <- Sys.getenv("DP_R_CHELSA_OutputPath")
# e.g.: DP_R_CHELSA_OutputPath="/pfs/lustrep4/scratch/project_465000915/IASDT_Model_Test/Data/Chelsa/Out"

# Reference grid for masking projected maps
RefGrid <- Sys.getenv("DP_R_GridLandCrop")
# e.g.: DP_R_GridLandCrop="Data/Maps/Grid/Grid_10_Land_Crop.RData"

# Also export outputs as tif files (in addition to NetCDF)
ExportTif <- as.logical(Sys.getenv("DP_R_CHELSA_OutTif"))
# e.g.: DP_R_CHELSA_OutTif=TRUE # [TRUE/FALSE should be all in capital letters]

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Input data -----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

# Ensure that the output path exists
fs::dir_create(Path_Out)

# Load reference grid to memory
RefGrid <- IASDT.R::LoadAs(RefGrid)

# List of tif file in the `Path_In` dir. All tif files in this dir will be processed
Chelsa_List <- Path_In %>% 
  list.files(pattern = ".tif$",  full.names = TRUE) %>% 
  tibble::tibble(Input = .) %>% 
  dplyr::mutate(Output = stringr::str_replace(Input, Path_In, Path_Out))

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Processing Chelsa data -----
# on parallel or sequentially
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

if (ProcessParallel) {
  
  # working on parallel ----
  IASDT.R::InfoChunk("Projecting CHELSA maps --- working on parallel")
  TimeStart <- lubridate::now(tzone = "CET")
  
  ## Preparing working on parallel ------
  IASDT.R::CatTime("Preparing working on parallel")
  c1 <- snow::makeSOCKcluster(.NCores)
  future::plan(future::cluster, workers = c1, gc = TRUE)
  
  ## Starting processing on parallel ----
  IASDT.R::CatTime("Processing CHELSA data on parallel")
  Chelsa_List %>% 
    dplyr::mutate(
      Process = furrr::future_map2(
        .x = Input, .y = Output, 
        .f = ~{
          IASDT.R::Chelsa_Project(
            InputFile = .x, OutFile = .y, 
            SaveTiff = ExportTif, GridFile = RefGrid)
          
          #  Garbage collection
          invisible(gc())
        },
        .progress = FALSE, .options = furrr::furrr_options(seed = TRUE))) %>% 
    invisible()
  
  ### Elapsed time ----
  IASDT.R::CatDiff(
    InitTime = TimeStart, Prefix = "   >>> Completed in ", CatInfo = FALSE)
  
} else {
  
  ## working sequentially ----
  IASDT.R::InfoChunk("Projecting CHELSA maps --- working sequentially")
  TimeStart <- lubridate::now(tzone = "CET")
  
  Chelsa_List %>% 
    dplyr::mutate(
      Process = purrr::map2(
        .x = Input, .y = Output, 
        .f = ~{
          # Print file name to console
          IASDT.R::CatTime(basename(.x))
          
          # work sequentially
          IASDT.R::Chelsa_Project(
            InputFile = .x, OutFile = .y, 
            SaveTiff = ExportTif, GridFile = RefGrid)
          
          # Garbage collection
          invisible(gc())
        }, .progress = FALSE)) %>% 
    invisible()
  
  ### Elapsed time -----
  IASDT.R::CatDiff(
    InitTime = TimeStart, Prefix = "   >>> Completed in ", CatInfo = FALSE)
}

# *************************************************************
# Print total elapsed time
# *************************************************************

IASDT.R::CatDiff(
  InitTime = .StartTime, Prefix = "Sourcing the file toke ", CatInfo = TRUE)
