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

# Find nc files to read
files <- list.files(here::here("data", "sst", "raw"), pattern = ".nc", full.names = T)
new_files <-  stringr::str_replace(string = paste0(tools::file_path_sans_ext(files), ".tif"),
                                   pattern = "raw",
                                   replacement = "processed_annual") %>% 
  stringr::str_remove_all(pattern = "_monthly")

# Read them as a list of bricks
purrr::map(files, raster::brick) |>
  purrr::map(.f = ~calc(.x, mean, na.rm = T)) |>
  purrr::map(rotate) |>
  purrr::walk2(.y = new_files, .f = ~writeRaster(x = .x, filename = .y))


list.files(here::here("data", "sst", "processed_annual"), pattern = ".aux", full.names = T) |>
  purrr::walk(file.remove)


