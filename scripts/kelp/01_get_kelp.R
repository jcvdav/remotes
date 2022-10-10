################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Processes 
#
# This script:
# - Loads landsat-derived kelp cover data (and NC file) and creates
# - Filters data from 2003 to present
# - Creates an individual tiff file for each quarter year
# - Aggregates the data from 0.001 to 0.01°
# - Export an individual tif file for each quarter-year
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(ncdf4)
library(raster)
library(stars)
library(tidyverse)

# Load data ----------------------------------------------------------------

# Load standard .01 grid
base_grid <- raster(here("data", "standard_grid.tif"))

# Load kelp NC file
kelp <- nc_open(
  filename = here(
    "data",
    "kelp",
    "raw",
    "LandsatKelpBiomass_2022_Q2_withmetadata.nc"),
  suppress_dimvals = F,
  write = F
  )

## PROCESSING ##################################################################

# Extract area values ----------------------------------------------------------
area <- ncvar_get(
  nc = kelp,
  varid = "area"
  )

# Extract lat and long values --------------------------------------------------

#Vector of latitudes
lat <- ncvar_get(
  nc = kelp,
  varid = "latitude"
)

#vector of longitudes
lon <- ncvar_get(
  nc = kelp,
  varid = "longitude"
)

# Tibble of coordinates
coords <- tibble(x = lon, y = lat)

# Extract time indicatiors -----------------------------------------------------
year <- ncvar_get(
  nc = kelp,
  varid = "year"
  )

quarter <- ncvar_get(
  nc = kelp,
  varid = "quarter"
)

# Create a vector of filenames -------------------------------------------------
# These will have the format: LandsatKelp_Quarterly_area_YYYY_QQ
names <-
  paste(
    "LandsatKelp_Quarterly_area",
    year[year >= 2003],
    quarter[year >= 2003],
    sep = "_"
  )

# Create a matrix of years we want, where each column is one quarter of data ---
kelp_extracted <- area[, year >= 2003]

# Create a raster brick of quarter-year kelp area ------------------------------
# For reasonns I don't undersantd, they report their data on a non-standard
# decimal degree grid, even though they are coming from LANDSAT data, which
# would have already included northings and eastings. So we'll have to make them
# match to our target 0.01-degree first. Within a given image, we'll sum all
# pixels.

# The following rasteriztion process will produce a raster brick of 78 images

k <- rasterize(x = coords,
               y = base_grid,
               field = kelp_extracted,
               fun = sum,
               na.rm = T)
names(k) <- names


## EXPORT ######################################################################
# Export all the rasters, one per quarter --------------------------------------
writeRaster(
  x = k,
  bylayer = T,
  filename = here::here(
    "data",
    "kelp",
    "processed",
    "area",
    paste0(names, ".tif")
  ),
  overwrite = T
)

# Clean-up the annoying AUX files that R started recently exporting ------------
list.files(here::here("data", "kelp", "processed", "area"),
           pattern = ".aux",
           full.names = T) |>
  purrr::walk(file.remove)

