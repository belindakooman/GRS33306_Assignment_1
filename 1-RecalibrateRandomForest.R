# ------------------
# 1. Import packages
# ------------------

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
if( !("quantregForest" %in% installed.packages()[,1]) )
  install.packages("quantregForest")
library("quantregForest")

# ------------------
# 2. Import rasters
# ------------------

# List all rasters in the spatial-covariates folder.
list_of_rasters <- list.files(path="spatial-covariates", pattern="*.tif", full.names=TRUE)
# Separately import aspect.
rl_aspect <- raster(list_of_rasters[1])

# Calculate sine and cosine versions of the aspect raster layer.
rl_sin_asp <- sin(rl_aspect)
rl_cos_asp <- cos(rl_aspect)

# Combine all other layers into a multiraster stack.
rs_covariates <- stack(c(list_of_rasters[2:14], rl_sin_asp, rl_cos_asp))
# Update names of the sine and cosine layers.
names(rs_covariates)[14:15] <- c("sin_asp", "cos_asp")
# view the results.
plot(rs_covariates)

# Replace unwanted landuse categories with NA.
rs_covariates$landuse <- reclassify(rs_covariates$landuse, rcl = matrix(c(12, NA), nrow = 1))

# Read only the relevant attributes of the soil observations point data (X and Y coordinates plus true SOC contents).
df_SOC <- read.csv(file = "SOC_top_soil.csv", header = TRUE)[,c("X", "Y", "SOC")]

# ---------------------------
# 3. Performing model fitting
# ---------------------------

# Set a seed.
set.seed(150)
# Split the points into calibration and validation sets.
vn_rownumbers_validation <- sample(1:nrow(df_SOC), size = 250)
