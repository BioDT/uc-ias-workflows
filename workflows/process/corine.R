# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CORINE LAND COVER data / habitat
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
# ******************************************
# What's in this script:
# ******************************************
# 
# - Authors: Ahmed El-Gabbas [ahmed.el-gabbas@ufz.de]
# - Last tested / edited: 28.02.2024 (May 2003-Feb 2024)
# - This script takes c.a. 15 minutes to run on LUMI (150GB; single core)
#
# THIS IS V5 OF THIS SCRIPT
# 
# This script processes Corine land cover data (current version: CLC 2018; v.2020_20u1)
#
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# 
# https://land.copernicus.eu/en/products/corine-land-cover
# 
## |--> CORINE Land Cover is a vector map with a scale of 1:100 000, a minimum cartographic unit (MCU) of 25 ha and a geometric accuracy better than 100m. It maps homogeneous landscape patterns, i.e. more than 75% of the pattern has the characteristics of a given class from the nomenclature. This nomenclature is a 3-level hierarchical classification system and has 44 classes at the third and most detailed level (Table 1). In order to deal with areas smaller than 25ha a set of generalisation rules were defined. [https://land.copernicus.eu/eagle/files/eagle-related-projects/pt_clc-conversion-to-fao-lccs3_dec2010 ; not valid anymore!]
#
# Original format: tif file (also available as ESRI Geodatabase and SQLite Database) - 100 m resolution - EPSG:3035 - EEA39 countries
#
#
## |-->  More details on each class at different level can be seen here:
# https://land.copernicus.eu/content/corine-land-cover-nomenclature-guidelines/html/
# https://land.copernicus.eu/en/technical-library/clc-illustrated-nomenclature-guidelines/@@download/file
# https://clc.gios.gov.pl/index.php/component/content/article/9-gorne-menu/clc-informacje-ogolne/58-klasyfikacja-clc-2
#
#
# ## |--> Cross-walks: A land cover map, such as the CORINE land cover map, is not designed explicitly to explain the spatial distribution of biodiversity. I followed cross-walks to to convert Corine classes into meaningful EUNIS (v2019) habitat classification
# https://www.eea.europa.eu/ds_resolveuid/5d1040e74b2d46deb7c19eb9f08dadd4 
# https://www.eea.europa.eu/data-and-maps/figures/eunis-habitats-based-on-corine-land-cover/methodology.pdf/download
#
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# 
## |--> This script calculates:
# 
# This script version mainly use `exactextractr::exact_extract` function to:
#
## |-------> Calculate percent coverage (fraction) per grid cell
#
# Percentage (fraction) of CLC classes (at three levels) and custom cross-walks per grid cell (10 km; zonal statistics)
# e.g., for CLC level 1, it calculates % coverage per grid cell for each class of this level: 1. Artificial Surfaces; 2. Agricultural areas; 3. Forest and seminatural areas; 4. Wetlands; and 5. Water bodies
# In previous versions of the script, I used standard R tools for spatial analysis (e.g. using sf/raster/terra). To be able to process the high resolution CLC data, I used the following approach: 1) split CLC map into smaller chunks (saved to disk to temporary files); 2) each chunk was processed separately (on parallel) and saved to disk; 3) merge (mosaic)processed chunks together.
# This approach was tested on EVE and took c.a. 18 minutes to run (on parallel). However, upgrading the EVE system resulted in confusing results. [reading the CLC tif map causes swapping coordinates of sf objects; See https://github.com/r-spatial/sf/issues/2263#event-11194173606].
# `exactextractr` package (https://github.com/isciences/exactextractr) is much faster (even on a standard PC) and then splitting the data into chunks is not needed anymore.
# However, for the same reasons this does not work as expected on EVE. I then changed to use `exactextractr` instead on LUMI.
# It is possible to use custom functions in the `exact_extract` function; e.g. to directly calculate % coverage of each SynHab habitat type or other cross-walks. However, it seems that this is implemented in R (not as the provided functions which is implemented in C). I tested using custom functions on a subset of grid cells and this worked as expected; however, working on the European scale was not possible (even on parallel; tested on MSG and LUMI - Feb 2024).
# For calculations per custom cross-walks, I rasterized the results of `exact_extract` then calculated from the resulted raster stack the percentage coverage of each SynHab habitat type.
#
## |-------> estimate the most common class per grid cell
# In addition to percentage coverage of each class (at different CLC levels and using custom cross-walks), the most common class per grid cell is calculated.
# 
## |-------> Plotting % coverage at different levels of CLC and SynHab habitat type
#
## |-------> Prepare the reference grid cells to be used in the models
# 
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# 
# <<< Data source: >>>>
# 
# https://land.copernicus.eu/pan-european/corine-land-cover/clc2018
# citation: https://doi.org/10.2909/960998c1-1870-4e82-8051-6485205ebbac
# 
## |--> Spatial coverage:
# Albania, Austria, Belgium, Bosnia and Herzegovina, Bulgaria, Croatia, Cyprus, Czechia, Denmark, Estonia, Finland, France, Germany, Greece, Hungary, Iceland, Ireland, Italy, Kosovo, Latvia, Liechtenstein, Lithuania, Luxembourg, Malta, Montenegro, Netherlands, North Macedonia, Norway, Poland, Portugal, Romania, Serbia, Slovakia, Slovenia, Spain, Sweden, Switzerland, United Kingdom, Vatican City, San Marino, Andorra, Faroes, Gibraltar
# 
# Update 07/02/2024: Turkey is removed from the reference grid 
# 
## |--> Temporal reference:
# - Temporal extent: 2017-2018
# - Date of publication: Jun 14, 2019
# - Revision date: May 13, 2020 
# 
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# 
# The current version of CLC 2018 is "v.2020_20u1"
#
## |--> It is not possible to download CLC data using simple web-scrapping as it requires logging in to get access to temporary download link [available only for 23 hours]. <-- TK: This is not correct, the data can be downloaded using CLMS.
## |--> The data was downloaded manually as raster map at this path: "u2018_clc2018_v2020_20u1_raster100m.zip", then extracted to this path "u2018_clc2018_v2020_20u1_raster100m/"
# 
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕
# ↕░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░↕

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

source("alwaysLoad.R")


## ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Loading data ------
## ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Loading data")

# Avoid warning while reading CLC data
# see: https://stackoverflow.com/questions/78007307
# see: https://github.com/isciences/exactextractr/issues/103
terra::setGDALconfig("GTIFF_SRS_SOURCE", "EPSG")

### ||||||||||||||||||||||||||||||||||||||||||||
# Loading R packages
### ||||||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Loading additional packages")
IASDT.R::LoadPackages(
  exactextractr, smoothr, ggplot2, cowplot, foreign, viridis, gtools, units,
  grid, paletteer, tidyterra, rlang)

### ||||||||||||||||||||||||||||||||||||||||||||
# paths
### ||||||||||||||||||||||||||||||||||||||||||||

# Path of reference grid
IASDT.R::CatTime(" >>>>> Loading reference grid")
DirGrid <- "Data/Maps/Grid"
# loading reference grid as raster and sf
load(file.path(DirGrid, "Grid_10_sf.RData"))
load(file.path(DirGrid, "Grid_10_Raster.RData"))

### ||||||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Creating folders")
# CLC root folder
DirCLC <- "Data/Maps/CORINE_Land_Cover"
# folder for all processed files
DirSummary <- file.path(DirCLC, "Summary")
# sub-folders to store tif files (no masking to final reference grid)
DirSummary_Tif <- file.path(DirSummary, "Summary_Tif")
# sub-folders to store tif files (masked to final reference grid)
DirSummary_Tif_Crop <- file.path(DirSummary, "Summary_Tif_Crop")
# sub-folders to store output RData files
DirSummary_RData <- file.path(DirSummary, "Summary_RData")
# sub-folders to store maps
DirSummary_JPEG <- file.path(DirSummary, "Summary_JPEG")
DirSummary_JPEG_Free <- file.path(DirSummary_JPEG, "FreeLegend")

# Create folders when necessary
c(DirCLC, DirSummary, DirSummary_Tif, DirSummary_Tif_Crop, 
  DirSummary_RData, DirSummary_JPEG, DirSummary_JPEG_Free) %>% 
  purrr::walk(fs::dir_create)

# Path of the input CLC tif file
CLC_Tiff <- "u2018_clc2018_v2020_20u1_raster100m/DATA" %>% 
  file.path(DirCLC, ., "U2018_CLC2018_V2020_20u1.tif")

IASDT.R::CatTime(" >>>>> Country boundaries")
load("Data/Maps/Europe_Boundaries/Bound_sf_Eur.RData")

IASDT.R::CatTime(" >>>>> Loading cross-walk")
# description of CLC values and custom cross-walks
CrossWalk <- file.path(DirCLC, "CrossWalk.txt") %>% 
  readr::read_delim(show_col_types = FALSE) %>% 
  dplyr::select(-SynHab_desc)

rm(Grid_10_sf)

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Calculate fraction of each CLC class at each grid cell ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Calculate fraction of each CLC class at each grid cell")

IASDT.R::CatTime(" >>>>> Loading CLC tif file")
CLC_Rast <- terra::rast(CLC_Tiff)
terra::NAflag(CLC_Rast) <- 128

# Calculate fraction for each CLC value
IASDT.R::CatTime(" >>>>> running exact_extract function")
CLC_Fracs <- Grid_10_sf_s %>% 
  dplyr::mutate(
    exactextractr::exact_extract(
      x = CLC_Rast, y = ., fun = "frac",
      force_df = TRUE, default_value = 44, progress = FALSE))

save(CLC_Fracs, file = file.path(DirSummary_RData, "CLC_Fracs.RData"))

IASDT.R::CatTime(" >>>>> Convert fractions to raster")
CLC_FracsR <- CLC_Fracs %>%
  tibble::tibble() %>% 
  sf::st_as_sf() %>% 
  sf::st_centroid() %>% 
  suppressWarnings() %>% 
  dplyr::select(-CellCode) %>%
  terra::vect() %>% 
  # convert to raster
  terra::rasterize(terra::rast(Grid_10_Raster), field = names(.)) %>% 
  "*"(100)
terra::crs(CLC_FracsR) <- "epsg:3035"

CLC_FracsR$frac_44 <- CLC_FracsR$frac_44 %>%
  terra::trim(value = 0) %>% 
  terra::extend(terra::rast(Grid_10_Raster), fill = 100)
CLC_FracsR$frac_48 <- NULL

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Calculate % coverage of different cross-walks per grid cell ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Calculate % coverage of different cross-walks per grid cell")

GetPerc <- function(Type = NULL) {
  
  IASDT.R::CatTime(paste0(" >>>>> >>>>> ", Type))
  OutObjName <- paste0("PercCov_", Type)
  
  Map <- CrossWalk %>% 
    dplyr::select(Value, tidyselect::all_of(Type)) %>%
    setNames(c("Fracs", "Class")) %>%
    dplyr::group_by(Class) %>% 
    dplyr::summarise(
      Fracs = paste0('CLC_FracsR[["frac_', Fracs, '"]]', collapse = " + ")) %>% 
    dplyr::slice(gtools::mixedorder(Class)) %>% 
    dplyr::mutate(
      Class = paste0(Type, "_", Class),
      Class = stringr::str_replace_all(Class, "\\.", ""),
      Class = stringr::str_trim(Class),
      HabPerc = purrr::map2(
        .x = Fracs, .y = Class, 
        .f = ~{
          rlang::parse_expr(.x) %>% 
            eval(envir = rlang::global_env()) %>% 
            setNames(.y)
        })) %>% 
    dplyr::pull(HabPerc) %>% 
    do.call(what = c) %>%
    raster::stack() %>% 
    terra::rast()
  
  terra::crs(Map) <- "epsg:3035"
  
  terra::writeRaster(
    Map, overwrite = TRUE, 
    filename = file.path(DirSummary_Tif, paste0("PercCov_", names(Map), ".tif")))
  
  assign(x = OutObjName, value = Map, envir = rlang::global_env())
  
  IASDT.R::SaveAs(
    InObj = terra::wrap(Map), OutObj = OutObjName, 
    OutPath = file.path(DirSummary_RData, paste0(OutObjName, ".RData")))
  
  return(invisible(NULL))
}

purrr::walk(c("SynHab", "CLC_L1", "CLC_L2", "CLC_L3", "EUNIS_2019"), GetPerc)

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Prepare reference grid --- Exclude areas from the study area ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Reference grid --- Exclude areas from the study area")

### |||||||||||||||||||||||||||||||||||||||
# Islands to exclude
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Islands to exclude")
Exclude_Islands <- list(
  melilla = c(2926000, 2944000, 1557000, 1574000),
  ceuta = c(3098000, 3219000, 1411000, 1493000),
  AtlanticIslands = c(342000, 2419000, 687000, 2990000)) %>% 
  purrr::map(
    .f = ~{
      .x %>% 
        raster::extent() %>% 
        as("SpatialPolygons") %>% 
        sf::st_as_sf()
    }) %>% 
  dplyr::bind_rows() %>% 
  sf::st_set_crs(3035)

## ||||||||||||||||||||||||||||||||||||||||
# Turkey --- boundaries
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Turkey --- boundaries")
TR <- "Data/Maps/Europe_Boundaries/Bound_sf_Eur.RData" %>% 
  IASDT.R::LoadAs() %>% 
  magrittr::extract2("Bound_sf_Eur_s") %>% 
  magrittr::extract2("L_01") %>% 
  dplyr::filter(CNTR_ID == "TR") %>% 
  dplyr::select(-CNTR_ID)

## ||||||||||||||||||||||||||||||||||||||||
# Turkey --- extent to exclude some left-over cells in the east of Turkey
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Turkey --- extent")
Extent_TR <- raster::extent(6604000, 7482000, 1707000, 2661000) %>% 
  as("SpatialPolygons") %>% 
  sf::st_as_sf() %>% 
  sf::st_set_crs(3035)

## ||||||||||||||||||||||||||||||||||||||||
# Combine areas to be excluded
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Combine areas to be excluded")
Exclude_Area <- Grid_10_sf_s %>% 
  dplyr::mutate(TR = as.integer(!sf::st_intersects(geometry, TR))) %>% 
  dplyr::filter(is.na(TR)) %>% 
  sf::st_union(Extent_TR) %>% 
  sf::st_union(Exclude_Islands) %>% 
  sf::st_union() %>% 
  smoothr::fill_holes(units::set_units(100000, km^2)) %>%
  terra::vect() %>% 
  terra::rasterize(terra::rast(Grid_10_Raster)) %>% 
  suppressWarnings()

## ||||||||||||||||||||||||||||||||||||||||
# Percentage of water habitats per grid cells
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Calculate the % of water per grid cell")
Grid_10_Land <- PercCov_CLC_L3 %>% 
  terra::unwrap() %>% 
  # select percent coverage for specific CLC classes [non-land habitats]
  magrittr::extract2(
    c("CLC_L3_423", "CLC_L3_511", "CLC_L3_512", 
      "CLC_L3_521", "CLC_L3_522", "CLC_L3_523")) %>% 
  # calculate the sum of these classes
  sum() %>% 
  setNames("Grid_10_Land")

## ||||||||||||||||||||||||||||||||||||||||
# Minimum % of land per grid cell to be used in the reference grid cell
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::AssignIfNotExist(MinLandPerc, 15)

## ||||||||||||||||||||||||||||||||||||||||
# Reference grid --- land only
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Reference grid --- land only")
Grid_10_Land[Exclude_Area == 1] <- NA
Grid_10_Land[Grid_10_Land > (100 - MinLandPerc)] <- NA
Grid_10_Land[!is.na(Grid_10_Land)] <- 1
terra::crs(Grid_10_Land) <- "epsg:3035"

## ||||||||||||||||||||||||||||||||||||||||
# Reference grid --- cropped
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Reference grid --- cropped")
Grid_10_Land_Crop <- terra::trim(Grid_10_Land) %>% 
  setNames("Grid_10_Land_Crop")
terra::crs(Grid_10_Land_Crop) <- "epsg:3035"

IASDT.R::CatTime(" >>>>> Reference grid --- sf object")
Grid_10_Land_sf <- Grid_10_Land %>% 
  terra::as.points() %>% 
  sf::st_as_sf() %>% 
  sf::st_join(x = Grid_10_sf_s, y = .) %>% 
  dplyr::filter(Grid_10_Land == 1) %>% 
  dplyr::select(-Grid_10_Land) %>% 
  suppressWarnings()

IASDT.R::CatTime(" >>>>> Reference grid --- sf object - cropped")
Grid_10_Land_Crop_sf <- Grid_10_Land_Crop %>% 
  terra::as.points() %>% 
  sf::st_as_sf() %>% 
  sf::st_join(x = Grid_10_sf_s, y = .) %>% 
  dplyr::filter(Grid_10_Land_Crop == 1) %>% 
  dplyr::select(-Grid_10_Land_Crop) %>% 
  suppressWarnings()

## ||||||||||||||||||||||||||||||||||||||||
# Save reference grid 
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Save reference grid --- RData")
Grid_10_Land <- terra::wrap(Grid_10_Land)
Grid_10_Land_Crop <- terra::wrap(Grid_10_Land_Crop)

save(Grid_10_Land, file = file.path(DirGrid, "Grid_10_Land.RData"))
save(Grid_10_Land_Crop, file = file.path(DirGrid, "Grid_10_Land_Crop.RData"))
save(Grid_10_Land_sf, file = file.path(DirGrid, "Grid_10_Land_sf.RData"))
save(Grid_10_Land_Crop_sf, file = file.path(DirGrid, "Grid_10_Land_Crop_sf.RData"))

## ||||||||||||||||||||||||||||||||||||||||
# Save calculated % coverage
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Save calculated % coverage")
CLC_FracsR <- terra::wrap(CLC_FracsR)
save(CLC_FracsR, file = file.path(DirSummary_RData, "CLC_FracsR.RData"))

## ||||||||||||||||||||||||||||||||||||||||
# Save reference grid - tif
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> Save reference grid --- tif")
terra::writeRaster(
  terra::unwrap(Grid_10_Land), overwrite = TRUE, 
  filename = file.path(DirGrid, "Grid_10_Land.tif"))
terra::writeRaster(
  terra::unwrap(Grid_10_Land_Crop), overwrite = TRUE, 
  filename = file.path(DirGrid, "Grid_10_Land_Crop.tif"))

## ||||||||||||||||||||||||||||||||||||||||
# Crop % coverage results
## ||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime("\nCrop % coverage results")

Crop_PercCov <- function(Type = NULL) {
  IASDT.R::CatTime(paste0(" >>>>> ", Type))
  Map <- Type %>%
    get(envir = rlang::global_env()) %>%
    terra::crop(terra::unwrap(Grid_10_Land_Crop)) %>%
    terra::mask(terra::unwrap(Grid_10_Land_Crop))
  
  terra::crs(Map) <- "epsg:3035"
  
  terra::writeRaster(
    x = Map, overwrite = TRUE, 
    filename = file.path(
      DirSummary_Tif_Crop, paste0("PercCov_", names(Map), ".tif")))
  
  Map <- terra::wrap(Map)
  OutObjName <- paste0(Type, "_Crop")
  assign(x = OutObjName, value = Map, envir = rlang::global_env())
  IASDT.R::SaveAs(
    InObj = Map, OutObj = OutObjName,
    OutPath = file.path(DirSummary_RData, paste0(OutObjName, ".RData")))
  
  return(invisible(NULL))
}

c("SynHab", "CLC_L1", "CLC_L2", "CLC_L3", "EUNIS_2019") %>%
  stringr::str_c("PercCov_", .) %>%
  purrr::walk(Crop_PercCov)

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Majority per grid cell ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Identify major CLC class per per grid cell")

IASDT.R::CatTime(" >>>>> Processing using exactextractr")

CLC_Majority <- Grid_10_sf_s %>%
  dplyr::mutate(
    Majority = exactextractr::exact_extract(
      x = CLC_Rast, y = ., fun = "majority", 
      default_value = 44, progress = FALSE)) %>% 
  dplyr::left_join(CrossWalk, by = dplyr::join_by(Majority == Value)) %>% 
  tibble::tibble() %>% 
  sf::st_as_sf()

save(CLC_Majority, file = file.path(DirSummary_RData, "CLC_Majority.RData"))

rm(CLC_Rast)

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

IASDT.R::CatTime(" >>>>> post-processing majority results")

ProcessMajority <- function(Type = NULL) {
  IASDT.R::CatTime(paste0("        >>>>> ", Type))
  OutObjName <- paste0("Majority_", Type)
  OutObjName_Cr <- paste0(OutObjName, "_Crop")
  
  Map <- CLC_Majority %>% 
    dplyr::filter(!is.na(Type)) %>% 
    dplyr::select(
      tidyselect::starts_with(Type), 
      -tidyselect::ends_with("_desc")) %>% 
    setNames(c("ID", "Label", "geometry")) %>% 
    dplyr::mutate(
      ID = paste0(ID, "_", Label),
      ID = stringr::str_replace_all(ID, "\\.|\\._", "_"), 
      ID = stringr::str_replace_all(ID, "__", "_"), 
      ID = stringr::str_replace_all(ID, "NA_NA+", NA_character_),
      Label = NULL) %>% 
    # https://stackoverflow.com/questions/43487773/
    dplyr::rename(!!OutObjName := ID) %>% 
    terra::rasterize(terra::unwrap(Grid_10_Land), field = OutObjName)
  
  NA_Flag <- Map %>%
    terra::levels() %>%
    magrittr::extract2(1) %>%
    dplyr::filter(is.na(get(OutObjName))) %>%
    dplyr::pull(1)
  terra::NAflag(Map) <- (NA_Flag)
  Map <- terra::droplevels(Map)
  
  MapLevels <- Map %>%
    terra::levels() %>%
    magrittr::extract2(1) 
  MapLevelsNew <- MapLevels %>% 
    dplyr::slice(gtools::mixedorder(.[, 2])) %>% 
    dplyr::mutate(ID = seq_len(dplyr::n()))
  MapLevelsM <- MapLevels %>% 
    dplyr::left_join(MapLevelsNew, by = names(MapLevels)[2]) %>% 
    dplyr::select(
      tidyselect::all_of(OutObjName), 
      tidyselect::everything())
  Map <- terra::classify(Map, MapLevelsM[, -1])
  levels(Map) <- list(MapLevelsNew)
  
  NAClasses <- c(
    "Marine_Marine habitats", "5_Water bodies", 
    "5_2_Marine waters", "5_2_3_Sea and ocean", "A_Marine habitats")
  VV <- MapLevelsNew %>% 
    setNames(c("ID", "Class")) %>% 
    dplyr::filter(Class %in% NAClasses) %>% 
    dplyr::pull(ID)
  
  Map <- terra:::classify(Map, cbind(NA, VV))
  levels(Map) <- list(MapLevelsNew)
  terra::crs(Map) <- "epsg:3035"
  
  terra::writeRaster(
    x = Map, overwrite = TRUE,
    filename = file.path(DirSummary_Tif, paste0(OutObjName, ".tif")))
  
  Map %>%
    terra::levels() %>%
    magrittr::extract2(1) %>% 
    dplyr::rename(VALUE = ID) %>% 
    foreign::write.dbf(
      file = file.path(DirSummary_Tif, paste0(OutObjName, ".tif.vat.dbf")),
      factor2char = TRUE, max_nchar = 254)
  
  IASDT.R::SaveAs(
    InObj = terra::wrap(Map), OutObj = OutObjName,
    OutPath = file.path(DirSummary_RData, paste0(OutObjName, ".RData")))
  
  ## ||||||||||||||||||||||||||||||||||||||||
  # CROPPING
  ## ||||||||||||||||||||||||||||||||||||||||
  
  Map_Cr <- Map %>% 
    terra::crop(terra::unwrap(Grid_10_Land_Crop)) %>%
    terra::mask(terra::unwrap(Grid_10_Land_Crop))
  terra::crs(Map_Cr) <- "epsg:3035"
  
  terra::writeRaster(
    x = Map_Cr, overwrite = TRUE,
    filename = file.path(DirSummary_Tif_Crop, paste0(OutObjName_Cr, ".tif")))
  
  Map_Cr %>%
    terra::levels() %>%
    magrittr::extract2(1) %>%
    dplyr::rename(VALUE = ID) %>%
    foreign::write.dbf(
      file = file.path(DirSummary_Tif_Crop, paste0(OutObjName_Cr, ".tif.vat.dbf")),
      factor2char = TRUE, max_nchar = 254)
  
  IASDT.R::SaveAs(
    InObj = terra::wrap(Map_Cr), OutObj = OutObjName_Cr,
    OutPath = file.path(DirSummary_RData, paste0(OutObjName_Cr, ".RData")))
  
  return(invisible(NULL))
}

purrr::walk(c("SynHab", "CLC_L1", "CLC_L2", "CLC_L3", "EUNIS_2019"),
            ProcessMajority)

## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Plotting -----

IASDT.R::InfoChunk("Plotting")

PlotCorine <- function(CLC_Map, EU_Map = Bound_sf_Eur_s$L_10) {
  
  CLC_MapR <- get(CLC_Map, envir = rlang::global_env()) %>% 
    terra::unwrap()
  NCells <- terra::ncell(CLC_MapR)
  
  Labels <- stringr::str_remove_all(CLC_Map, "PercCov_|_Crop")
  ClassOrder <- stringr::str_remove_all(names(CLC_MapR), paste0(Labels, "_"))
  Labels <- CrossWalk %>% 
    dplyr::select(matches(paste0("^", Labels, "$|^", Labels, "_Label"))) %>% 
    dplyr::distinct() %>% 
    setNames(c("Level", "Label")) %>%
    dplyr::arrange(factor(Level, levels = ClassOrder)) %>% 
    dplyr::mutate(ID = seq_len(dplyr::n())) %>% 
    dplyr::select(ID, Level, Label)
  
  Prefix <- CLC_Map %>% 
    stringr::str_remove_all("PercCov_|_Crop") %>% 
    stringr::str_replace_all("CLC_", "CLC  ")
  
  FilePrefix <- CLC_Map %>% 
    stringr::str_remove_all("PercCov_|_Crop") %>% 
    stringr::str_replace_all("CLC_L", "CLC")
  
  IASDT.R::CatTime(paste0("\n >>>>> ", Prefix))
  
  # determine which layers will be plotted in each figure (4 columns * 2 rows) 
  split_vector <- CLC_MapR %>% 
    terra::nlyr() %>% 
    seq_len() %>% 
    {
      split(., ceiling(seq_along(.) / 8))
    }
  
  # Plotting boundaries 
  Xlim <- c(2600000, 6550000)
  Ylim <- c(1450000, 5420000)
  
  LastUpdate <- paste0("Last update: ", format(Sys.Date(), "%d %B %Y"))
  
  OutPath <- "Summary_PercCover_{FilePrefix}_{seq_len(length(split_vector))}.jpeg" %>% 
    stringr::str_glue() %>% 
    file.path(DirSummary_JPEG, .)
  
  MAPS <- seq_len(length(split_vector)) %>% 
    purrr::map(
      .f = ~{
        
        split_vector[[.x]] %>% 
          purrr::map(
            .f = function(YY) {
              
              CurrMap <- CLC_MapR[[YY]]
              
              IASDT.R::CatTime(paste0("        >>>>> ", Labels$Label[[YY]]))
              
              MapTitle <- Labels$Label[[YY]] %>%
                # split long title text into multiple lines when necessary
                stringi::stri_wrap(55) %>%
                stringr::str_c(collapse = "\n")
              
              if (stringr::str_detect(MapTitle, "\n", negate = TRUE)) {
                MapTitle <- paste0(MapTitle, "\n")
              }
              
              # create ggplot object for each layer
              CurrMapPlot <- ggplot2::ggplot() +
                tidyterra::geom_spatraster(data = CurrMap) +
                paletteer::scale_fill_paletteer_c(
                  na.value = "transparent", palette = "viridis::plasma", 
                  limits = c(0, 100)) +
                ggplot2::geom_sf(
                  EU_Map, mapping = ggplot2::aes(), color = "grey60", 
                  linewidth = 0.25, inherit.aes = TRUE, 
                  fill = scales::alpha("grey80", 0.2)) +
                ggplot2::scale_x_continuous(
                  expand = ggplot2::expansion(mult = c(0, 0)), limits = Xlim) +
                ggplot2::scale_y_continuous(
                  expand = ggplot2::expansion(mult = c(0, 0)), limits = Ylim) +
                ggplot2::theme_bw() +
                ggplot2::theme(
                  plot.margin = ggplot2::margin(0.05, 0, 0, 0, "cm"),
                  plot.title = ggplot2::element_text(
                    size = 7, color = "blue", hjust = 0, # face = "bold", hjust = 0.5,
                    margin = ggplot2::margin(2, 0, 2, 0)),
                  strip.text = ggplot2::element_text(size = 6, face = "bold"),
                  axis.text.x = ggplot2::element_text(size = 4),
                  axis.text.y = ggplot2::element_text(size = 4, hjust = 0.5, angle = 90),
                  axis.ticks = ggplot2::element_line(colour = "blue", linewidth = 0.25),
                  axis.ticks.length = grid::unit(0.04, "cm"),
                  panel.spacing = grid::unit(0.3, "lines"),
                  panel.grid.minor = ggplot2::element_line(linewidth = 0.125),
                  panel.grid.major = ggplot2::element_line(linewidth = 0.25),
                  panel.border = ggplot2::element_blank(),
                  legend.position = "none") +
                ggplot2::labs(title = MapTitle, fill = NULL)
              
              
              LevelTxt <- stringr::str_replace_all(Labels$Level[YY], "\\.", "_") %>% 
                stringr::str_remove("_$")
              
              TilePath <- "PercCover_{FilePrefix}_{LevelTxt}_{Labels$Label[YY]}.jpeg" %>% 
                stringr::str_glue() %>%
                stringr::str_replace_all("/", "_") %>%
                file.path(DirSummary_JPEG, .)
              
              Theme2 <- ggplot2::theme_minimal() + 
                ggplot2::theme(
                  plot.margin = ggplot2::margin(0.25, 0, 0, 0.05, "cm"),
                  plot.title = ggplot2::element_text(
                    size = 12, color = "blue", face = "bold", hjust = 0,
                    margin = ggplot2::margin(0, 0, 0, 0)),
                  axis.text.x = ggplot2::element_text(size = 8),
                  axis.text.y = ggplot2::element_text(size = 8, hjust = 0.5, angle = 90),
                  axis.ticks = ggplot2::element_line(colour = "blue", linewidth = 0.25),
                  axis.ticks.length = grid::unit(0.04, "cm"),
                  legend.box.margin = ggplot2::margin(0, 0, 0, 0),
                  legend.key.size = grid::unit(0.8, "cm"),
                  legend.key.width = grid::unit(0.6, "cm"),
                  legend.text = ggplot2::element_text(size = 8),
                  legend.box.background = ggplot2::element_rect(colour = "transparent"),
                  legend.background = ggplot2::element_rect(
                    colour = "transparent", fill = "transparent"),
                  plot.tag.position = c(0.99, 0.992),
                  plot.tag = ggplot2::element_text(colour = "grey", size = 7, hjust = 1))
              
              TitleLab <- "{FilePrefix} \U2014 {Labels$Level[YY]}.  {Labels$Label[[YY]]}" %>%
                stringr::str_glue() %>%
                as.character() %>%
                stringr::str_replace("CLC", "CLC \U2014 Level ") %>%
                stringr::str_replace(" - ", " \U2014 ") %>%
                stringr::str_replace("\\.\\.", ".") %>%
                stringi::stri_wrap(75) %>%
                stringr::str_c(collapse = "\n")
              if (stringr::str_detect(TitleLab, "\n", negate = TRUE)) {
                TitleLab <- paste0(TitleLab, "\n")
              }
              
              (ggplot2::ggplot() +
                  ggplot2::geom_sf(
                    EU_Map, mapping = ggplot2::aes(), 
                    color = "grey60", linewidth = 0.25, inherit.aes = TRUE, 
                    fill = scales::alpha("grey80", 0.4)) +
                  tidyterra::geom_spatraster(data = CurrMap) + 
                  ggplot2::geom_sf(
                    EU_Map, mapping = ggplot2::aes(), color = "grey60", 
                    linewidth = 0.25, inherit.aes = TRUE, fill = "transparent") + 
                  paletteer::scale_fill_paletteer_c(
                    na.value = "transparent", "viridis::plasma", limits = c(0, 100)) +
                  ggplot2::scale_x_continuous(
                    expand = ggplot2::expansion(mult = c(0, 0)), limits = Xlim) +
                  ggplot2::scale_y_continuous(
                    expand = ggplot2::expansion(mult = c(0, 0)), limits = Ylim) + 
                  ggplot2::labs(title = TitleLab, fill = NULL, tag = LastUpdate) + 
                  Theme2) %>% 
                ggplot2::ggsave(
                  filename = TilePath, width = 25, height = 23, units = "cm",
                  dpi = 600, create.dir = TRUE)
              
              
              TilePathFree <- "PercCover_{FilePrefix}_{Labels$Label[YY]}.jpeg" %>% 
                stringr::str_glue() %>% 
                stringr::str_replace_all("/", "_") %>% 
                file.path(DirSummary_JPEG_Free, .)
              
              (ggplot2::ggplot() +
                  ggplot2::geom_sf(
                    EU_Map, mapping = ggplot2::aes(), color = "grey60", linewidth = 0.25, 
                    inherit.aes = TRUE, fill = scales::alpha("grey80", 0.4)) +
                  tidyterra::geom_spatraster(data = CurrMap) + 
                  ggplot2::geom_sf(
                    EU_Map, mapping = ggplot2::aes(), color = "grey60", 
                    linewidth = 0.25, inherit.aes = TRUE, fill = "transparent") + 
                  paletteer::scale_fill_paletteer_c(
                    na.value = "transparent", palette = "viridis::plasma") +
                  ggplot2::scale_x_continuous(
                    expand = ggplot2::expansion(mult = c(0, 0)), limits = Xlim) +
                  ggplot2::scale_y_continuous(
                    expand = ggplot2::expansion(mult = c(0, 0)), limits = Ylim) + 
                  ggplot2::labs(title = TitleLab, fill = NULL, tag = LastUpdate) + 
                  Theme2) %>% 
                ggplot2::ggsave(
                  filename = TilePathFree, width = 25, height = 23, 
                  units = "cm", dpi = 600, create.dir = TRUE)
              
              return(CurrMapPlot)
            })
      })
  
  IASDT.R::CatTime(" >>>>>  >>>>> Multiple panels per file ")
  
  CommonLegend <- cowplot::get_legend(
    (ggplot2::ggplot() +
       tidyterra::geom_spatraster(
         data = terra::rast(CLC_MapR[[1]]), maxcell = NCells) +
       paletteer::scale_fill_paletteer_c(
         na.value = "transparent", palette = "viridis::plasma",
         limits = c(0, 100)) +
       ggplot2::theme(
         legend.box.margin = ggplot2::margin(0, 0, 0, 0),
         legend.key.size = grid::unit(0.4, "cm"),
         legend.key.width = grid::unit(0.4, "cm"),
         legend.text = ggplot2::element_text(size = 6),
         legend.background = ggplot2::element_rect(fill = "transparent")) + 
       ggplot2::labs(fill = NULL))
  ) %>% 
    suppressWarnings()
  
  # arrange map tiles together into figures (4 columns * 2 rows)
  seq_along(MAPS) %>% 
    purrr::walk(
      .f = ~{
        # main title of the figure - {("\U00D7")} prints the multiplication symbol
        MainTitle <- stringr::str_glue(
          "Percent coverage of {Prefix} per 10\u00D710 km grid cell") %>% 
          as.character()
        
        MainTitle <- cowplot::ggdraw() + 
          cowplot::draw_label(MainTitle, fontface = "bold", hjust = 0.5) +
          cowplot::draw_label(
            LastUpdate, fontface = "italic", color = "grey", x = 0.935, size = 3) + 
          ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))
        
        cowplot::plot_grid(plotlist = MAPS[[.x]], ncol = 4, nrow = 2) %>% 
          cowplot::plot_grid(CommonLegend, rel_widths = c(4, .2)) %>% 
          cowplot::plot_grid(MainTitle, ., ncol = 1, rel_heights = c(0.05, 1))  %>% 
          ggplot2::ggsave(
            filename = OutPath[.x], width = 28, height = 15, units = "cm",
            dpi = 600, create.dir = TRUE)
      })
  return(invisible(NULL))
}

c("PercCov_SynHab_Crop", "PercCov_CLC_L1_Crop", "PercCov_CLC_L2_Crop",
  "PercCov_CLC_L3_Crop", "PercCov_EUNIS_2019_Crop") %>% 
  purrr::walk(PlotCorine)

## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
## ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
# Session summary ----
# ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪

IASDT.R::InfoChunk("Session summary")

# if (.SaveSession) {
#   SessionObjs <- IASDT.R::SaveSession(Path = "Sessions/", Prefix = "CLC")
#   IASDT.R::SaveSessionInfo(
#     Path = "Sessions/", SessionObj = SessionObjs, Prefix = "CLC")
# }

lubridate::now(tzone = "CET") %>% 
  difftime(.StartTime, units = "mins") %>% 
  as.numeric() %>% 
  round(2) %>% 
  stringr::str_c("\nFinished in ", ., " minutes") %>%
  IASDT.R::CatTime(... = "\n")
