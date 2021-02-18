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
if (!("corrplot" %in% installed.packages()[,1]))
  install.packages("corrplot")
library("corrplot")

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

# -----------------------------
# 3. Setting calibration points
# -----------------------------

# Set a seed.
set.seed(150)
# Take random row numbers for 90% of all points to serve as the calibration data.
vn_rownumbers_calibration <- sample(1:nrow(df_SOC), size = (nrow(df_SOC)*0.9))

# Assign these rows to calibration data.
df_SOC_val <- df_SOC[vn_rownumbers_calibration,]
# Assign the remaining rows to validation data.
df_SOC_cal <- df_SOC[-vn_rownumbers_calibration,]
# Remove the rownumbers to clean up the environment.
remove(vn_rownumbers_calibration)

# Convert the calibration points to a SpatialPointsDataframe.
spdf_observations <- df_SOC_cal
coordinates(spdf_observations) <- ~ X + Y
crs(spdf_observations) <- crs(rs_covariates)

# -------------------------------------------
# 4. Extracting data using calibration points
# -------------------------------------------

# Extract attributes from the rasterstack at calibration point locations.
mn_covariates <- extract(x = rs_covariates, y = spdf_observations)
# Add the real SOC values to the covariates into a single dataframe.
df_SOC_regmat <- cbind(df_SOC_cal, mn_covariates)
# Clean up.
remove(mn_covariates)

# Turn categorical attributes into factors to ensure the random forest can run with it.
df_SOC_regmat$landuse <- as.factor(df_SOC_regmat$landuse)
# Remove all rows that contain NA values to prevent incorrect results.
df_SOC_regmat <- df_SOC_regmat[complete.cases(df_SOC_regmat),]

# View the final calibration dataframe.
View(df_SOC_regmat)

# ----------------------------
# 5. Fit a random forest model
# ----------------------------

# Calculate a random forest model.
rf_SOC <- randomForest(x=df_SOC_regmat[4:18], y=df_SOC_regmat$SOC, importance = TRUE)
# Print some basic information about the model.
print(rf_SOC)

# Create predictions using this model.. This may take up to half a minute.
rf_predict <- predict(rs_covariates, model=rf_SOC, na.rm=TRUE)
# Plot the prediction.
plot(rf_predict)

# It only has 33.16% variance explained.. not a very nice result.

# ---------------------
# 6. Evaluating results
# ---------------------

# View the RMSEcal as a function of the amount of trees.
plot(sqrt(rf_SOC$mse),xlab = "trees", ylab = "RMSEcal")
grid()
# ..Alongside the R2cal as a function of the amount of trees.
plot(rf_SOC$rsq, xlab = "trees", ylab = "R2cal")
grid()
# It seems that around after 125 trees, additional trees do not add much value anymore. 
# However, they also don't decrease it, so there is no point in changing the number of trees.

# Create a correlation matrix to inspect correlation between predictors.
mn_correlations_covariates <- cor(df_SOC_regmat[-c(1:3, 6)])
# Print the rounded correlation values.
round(mn_correlations_covariates, digits = 2)
# View the correlation plot.
corrplot(mn_correlations_covariates)
# There is not a lot of overlap, so it doens't look like any predictors can be removed...

# View the contributions of each of the variables in the model.
rf_SOC[["importance"]]
# ..And also in a visual plot.
varImpPlot(rf_SOC)
# It appears that cos_asp, landuse and ndvi_summer do not add a lot of information.
# Try to improve the model by removing these..

# Calculate a new random forest model.
rf_SOC_reduced <- randomForest(x=df_SOC_regmat[c(4:5, 7, 9:17)], y=df_SOC_regmat$SOC, importance = TRUE)
# Print the details of this new model.
print(rf_SOC_reduced)

# Percentage variance explained has actually improved to 37.69%!

# Attempt a new prediction.
rf_predict_reduced <- predict(rs_covariates, model=rf_SOC, na.rm=TRUE)
# Plot the prediction.
plot(rf_predict_reduced)
