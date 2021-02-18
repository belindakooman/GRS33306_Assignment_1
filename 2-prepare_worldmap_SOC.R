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


# Load the raster layers
rl_soc_0_5_nr1 <- raster("1_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr2 <- raster("2_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr3 <- raster("3_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr4 <- raster("4_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr5 <- raster("5_worldmap_SOC_0_5cm.tif")
rl_soc_0_5_nr6 <- raster("6_worldmap_SOC_0_5cm.tif")

rl_soc_5_15_nr1 <- raster("1_worldmap_SOC_5_15cm.tif")
rl_soc_5_15_nr2 <- raster("2_worldmap_SOC_5_15cm.tif")
rl_soc_5_15_nr3 <- raster("3_worldmap_SOC_5_15cm.tif")
rl_soc_5_15_nr4 <- raster("4_worldmap_SOC_5_15cm.tif")
rl_soc_5_15_nr5 <- raster("5_worldmap_SOC_5_15cm.tif")
rl_soc_5_15_nr6 <- raster("6_worldmap_SOC_5_15cm.tif")

rl_soc_15_30_nr1 <- raster("1_worldmap_SOC_15_30cm.tif")
rl_soc_15_30_nr2 <- raster("2_worldmap_SOC_15_30cm.tif")
rl_soc_15_30_nr3 <- raster("3_worldmap_SOC_15_30cm.tif")
rl_soc_15_30_nr4 <- raster("4_worldmap_SOC_15_30cm.tif")
rl_soc_15_30_nr5 <- raster("5_worldmap_SOC_15_30cm.tif")
rl_soc_15_30_nr6 <- raster("6_worldmap_SOC_15_30cm.tif")



## merge the raster layers per depth (so 1 rasterlayer for 0-5 cm, 5-15 and 15-30 cm)
# added the tolerance to enable to merge the layers without a big overlap
rl_soc_0_5cm <- raster::merge(rl_soc_0_5_nr1, 
                              rl_soc_0_5_nr2, 
                              rl_soc_0_5_nr3,
                              rl_soc_0_5_nr4,
                              rl_soc_0_5_nr5,
                              rl_soc_0_5_nr6,
                              tolerance=0.5)

rl_soc_5_15cm <- raster::merge(rl_soc_5_15_nr1, 
                              rl_soc_5_15_nr2, 
                              rl_soc_5_15_nr3,
                              rl_soc_5_15_nr4,
                              rl_soc_5_15_nr5,
                              rl_soc_5_15_nr6,
                              tolerance=0.5)


rl_soc_15_30cm <- raster::merge(rl_soc_15_30_nr1, 
                               rl_soc_15_30_nr2, 
                               rl_soc_15_30_nr3,
                               rl_soc_15_30_nr4,
                               rl_soc_15_30_nr5,
                               rl_soc_15_30_nr6,
                               tolerance=0.5)




# check and plot the layers
plot(rl_soc_0_5cm)
plot(rl_soc_5_15cm)
plot(rl_soc_15_30cm)

# Clean working directory
remove(rl_soc_0_5_nr1, 
       rl_soc_0_5_nr2, 
       rl_soc_0_5_nr3,
       rl_soc_0_5_nr4,
       rl_soc_0_5_nr5,
       rl_soc_0_5_nr6,
       rl_soc_5_15_nr1, 
       rl_soc_5_15_nr2, 
       rl_soc_5_15_nr3,
       rl_soc_5_15_nr4,
       rl_soc_5_15_nr5,
       rl_soc_5_15_nr6,
       rl_soc_15_30_nr1, 
       rl_soc_15_30_nr2, 
       rl_soc_15_30_nr3,
       rl_soc_15_30_nr4,
       rl_soc_15_30_nr5,
       rl_soc_15_30_nr6)


#### Merge the depth layers and export ####
# adds up the SOC data from every layer
rl_SOC_total_weighted = (((rl_soc_0_5cm*5) + (rl_soc_5_15cm*10) + (rl_soc_15_30cm*15))/30)


## Crop the raster layer to the NL boundaries
# download the boundaries of NL
sp_df_NL <- getData(name    = 'GADM', 
                          country = 'NLD', 
                          level   = 0)


# Create a cropped raster layer based on the boundaries of the NL
rl_SOC_total_weighted_crop <- crop(x = rl_SOC_total_weighted, y = sp_df_NL)

# check differneces of crop
plot(rl_SOC_total_weighted)
plot(rl_SOC_total_weighted_crop)




# Export the SOC map of source (worldmap soil grid)
writeRaster(rl_SOC_total_weighted_crop, 'SOC_worldmap.tif', overwrite=TRUE)
