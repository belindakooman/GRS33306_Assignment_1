# load necessary packages
if( !("raster" %in% installed.packages()[,1]) )
install.packages("raster")
library("raster")
if( !("rgdal" %in% installed.packages()[,1]) )
install.packages("rgdal")
library("rgdal")
if( !("mapview" %in% installed.packages()[,1]) )
install.packages("mapview")
library("mapview")
if( !("rpart" %in% installed.packages()[,1]) )
install.packages("rpart")
library("rpart")
if( !("randomForest" %in% installed.packages()[,1]) )
install.packages("randomForest")
library("randomForest")


# loading europe and the netherlands
rl_europe     <- raster("data/SOC_map_europe.tif")
plot(rl_europe)
rl_netherlands <- raster("data/SOC_map_NL.tif")

# projecting both (just in case) to EPSG
rl_europe_rp <- projectRaster(rl_europe, crs = CRS("+init=epsg:28992"))
rl_netherlands_rp <- projectRaster(rl_netherlands, crs = CRS("+init=epsg:28992"))

# Crop Europe raster with the boundaries of the Netherlands
rl_EU_rp_cr <- crop (rl_europe_rp, y = rl_netherlands_rp)

# Export raster
writeRaster(rl_EU_rp_cr, 'rl_europe.tif', overwrite = TRUE)
writeRaster(rl_netherlands_rp, 'rl_NL.tif', overwrite = TRUE)
