################################################################################
# get_sst
################################################################################
# 
# Juan Carlos Villaseñor-Derbez
# juancvd@stanford.edu
# Sept 23, 2022
#
# Downloads netCDF files with ~1km degree resolution
# of Sea Surface Temperature
#
# MODIS Aqua West Coast - SST
# High-Resolution (0.0125°/1.25km)
# Temporal coverage 2002-Now
# Geographic extenct: US West Coast
#
# Moderate Resolution Imaging Spectroradiometer (MODIS)
# NOAA CoastWatch provides SST data from NASA's Aqua Spacecraft. Measurements
# are gathered by the Moderate Resolution Imaging Spectroradiometer (MODIS)
# carried aboard the spacecraft.
# 
# More info at: https://coastwatch.pfeg.noaa.gov/data.html
################################################################################

# Years for which I want data
yrs <- 2003:2021

# Iterate across years
for (yr in yrs) {
  
  # Build URL
  url <- paste0(
    "https://coastwatch.pfeg.noaa.gov/erddap/griddap/erdMWsstdmday.nc?sst%5B(",
    yr,
    "-01-16T12:00:00Z):1:(",
    yr,
    "-12-16T12:00:00Z)%5D%5B(0.0):1:(0.0)%5D%5B(22.0):1:(43)%5D%5B(230):1:(255.0)%5D"
  )
  
  # Build filename when exported
  filename <- paste0("erdMWsst_monthly_", yr, ".nc")
  destfile <- here::here("data", "sst", "raw", filename)
  
  if(!file.exists(destfile)) {
    download.file(
      url = url,
      destfile = destfile
    )
  }
}


