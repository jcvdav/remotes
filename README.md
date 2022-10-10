# remotes

Due to space limitations, no data are stored in this repo. Instead, the code needed to download and generate different data-sets is stored here. I am more than happy to share any and all of it with you.

So far, the documented and uploaded versions include scripts for two data-sets, described in the next sections.

## `scripts\kelp`

Contains a single script (`01_get_kelp.R`) that reads-in the NC file from the SB LTER group, and proceeds to create quarterly tif files at a 0.01-degree resolution

## `scripts\sst`

Contains three scripts:

- `01_get_sst.R`: Downloads monthly SST data from https://coastwatch.pfeg.noaa.gov/data.html

- `02_create_quarterly_images.R` reads in all these files, and generates quarterly images

- `03_create_annual_images.R` reads in all the raw files, and generates annual images

