## Assignment week 1
## 18-2 2021
## Xinyoa Pan & Yneke van Iersel


#### Preparation of packages ####
if( !("raster" %in% installed.packages()[,1]) )
  install.packages("raster")
library("raster")

if( !("rgdal" %in% installed.packages()[,1]) )
  install.packages("rgdal")
library("rgdal")

if( !("mapview" %in% installed.packages()[,1]) )
  install.packages("mapview")
library("mapview")

if( !("corrplot" %in% installed.packages()[,1]) )
  install.packages("corrplot")
library("corrplot")

#### Prepare and merge the raster files #####
# Make sure to correctly set the working directory
## method 1: ajust and run the lines below (adjust to your prefered directory)
data_dir <- paste("C:/Users/lenovoa/Desktop/GRS/Week1/Pratical/Day3/data_day3/data/spatial-covariates")
setwd(data_dir)
## method 2: go to 'sesion' -> 'set working directory' -> 'to source file location'

## load the raster layers
rl_soc_0_5_nr1 <- raster("1_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr2 <- raster("2_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr3 <- raster("3_worldmap_SOC_0_5cm.tif")




