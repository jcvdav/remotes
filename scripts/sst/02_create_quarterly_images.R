################################################################################
# create_quarterly_images
################################################################################
# 
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# Sept 23, 2022
#
# The sst *.nc files downloaded from coast watch contain one 12 bands, one for
# each month of the year. This script does the following:
# - Reads each as a raster brick
# - Splits each year by quarters
# - Calculates the mean SST for the quarter, across the images that make it up
# - Rotate the image to have it in a -180 t0 180 longitudinal range
# - Re-samples it to a 0.1 * 0.1 degree grid
# - Exports a single *.tif file for each quarter
# - Cleans up the AUX files that are generated (I don't think we need them)
################################################################################

## SET UP ######################################################################

# Define a function that splits each year and calculates quarterly means -------
split_year <- function(b){
  ref <- raster(xmn = -130,
                xmx = -104,
                ymn = 21,
                ymx = 43,
                res = 0.01,
                crs = "EPSG:4326")
  
  f <- seq(1, raster::nbands(b), by = 3)
  
  quarter_means <- purrr::map(
    .x = f,
    .f = ~raster::calc(
      x = b[[.x:min(.x+2, raster::nbands(b))]],
      fun = mean, 
      na.rm = T),
    b = b)
  
  rotated_quarter_means <- purrr::map(
    .x = quarter_means,
    .f = raster::rotate
  )
  
  resampled_quarter_means <- purrr::map(
    .x = rotated_quarter_means,
    .f = ~raster::resample(x = .x, y = ref))
  
  filenames <- here::here(
    "data", "sst", "processed_quarterly",
    paste0(
      stringr::str_replace(basename(tools::file_path_sans_ext(b@file@name)), "monthly", "quarterly")
      , "_Q", 1:length(rotated_quarter_means), ".tif")
  )
  
  purrr::walk2(
    .x = resampled_quarter_means,
    .y = filenames,
    .f = ~raster::writeRaster(
      x = .x,
      filename = .y,
      format = "GTiff",
      overwrite = T))
}

## PROCESSING ##################################################################

# Find nc files to read
files <- list.files(here::here("data", "sst", "raw"), pattern = ".nc", full.names = T)

# Read them as a list of bricks
b <- purrr::map(files, raster::brick)

# Apply the function above to each brick on the list
purrr::walk(b, split_year)


# Delete AUX files
aux_files <- list.files(here::here("data", "sst", "processed_quarterly"), pattern = ".aux", full.names = T)
purrr::walk(aux_files, file.remove)

# SOME NOTES -------------------------------------------------------------------
# Not every year has 12 months.
# The following table shows that
d <- data.frame(file = basename(files),
           n_layers = purrr::map_dbl(b, raster::nlayers))

# Export the table
write.csv(x = d,
          file = here::here("data", "sst", "processed_quarterly", "months_per_quarter.csv"), row.names = F)

# END SCRIPT ###################################################################