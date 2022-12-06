################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# date
#
# Description
#
################################################################################

## SET UP ######################################################################

# Load packages ----------------------------------------------------------------
library(here)
library(raster)
library(sf)
library(tidyverse)

# Load data --------------------------------------------------------------------
kelp_files <- list.files(
  path = here("data", "kelp", "processed", "area"),
  pattern = "tif",
  full.names = T) %>%
  stack()

## PROCESSING ##################################################################

# Find pixels with kelp in at least one quarter -----------------------------------
beginCluster()
kelp_grid <- sum(kelp_files > 0, na.rm = T)
endCluster()

# Extract center of these points -----------------------------------------------
kelp_pts <- kelp_grid %>%
  as.data.frame(xy = T) %>%
  drop_na() %>%
  st_as_sf(coords = c("x", "y"), crs = 4326) %>% 
  filter(layer > 0)

## EXPORT ######################################################################

# Export -----------------------------------------------------------------------
st_write(
  obj = kelp_pts,
  dsn = here("data", "kelp", "processed", "area", "pixels_with_kelp.gpkg"),
  delete_dsn = T
)
