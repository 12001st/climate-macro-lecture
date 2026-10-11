# https://gadm.org/

library(ncdf4) # package for netcdf manipulation
library(terra) # an updated version of raster package  #library(raster)
library(sf) # package for geospatial analysis # library(rgdal)
library(scales) # scale function for visualization
library(ggplot2) # package for plotting
library(tidyterra) # "tidyverse" method and "ggplot2" helpers for "terra" objects
library(openxlsx) # package for exporting data to excel

rm(list = ls())

# Working directory: the r/ folder of this repository, e.g. setwd("path/to/climate-macro-lecture/r")

AFnc <- nc_open("data/spei01_africa.nc")
AFrast <- rast("data/spei01_africa.nc")

str(AFnc)
str(AFrast)

dim(AFnc)
dim(AFrast)

names(AFnc)
names(AFrast)

names(AFnc$dim)
names(AFnc$var)


# Get variable names
lon<-ncvar_get(AFnc, "lon")
lat<-ncvar_get(AFnc, "lat")
tmm<-ncvar_get(AFnc, "time", verbose = F)

head(lon)


# Import the location information for country 
ZAF_shp0 <- st_read(dsn = "data/gadm41_ZAF_shp", layer = "gadm41_ZAF_0")
ZAF_shp1 <- st_read(dsn = "data/gadm41_ZAF_shp", layer = "gadm41_ZAF_1")
ZAF_shp2 <- st_read(dsn = "data/gadm41_ZAF_shp", layer = "gadm41_ZAF_2")

print(ZAF_shp0)
print(ZAF_shp1)
ZAF_provnames <-ZAF_shp1$NAME_1
print(ZAF_provnames)


ZAF0 <- crop(AFrast, ZAF_shp0)
dim(ZAF0)

# Map at the provincial level
ggplot() +
  geom_spatraster(data = ZAF0[[432]]) + 
  geom_sf(data = ZAF_shp1, 
          fill = NA,           
          color = "black",     
          size = 0.7,          
          alpha = 0.7) +       
  scale_fill_gradient2(
    low = "red", 
    mid = "white", 
    high = "green"
  ) +
  labs(
    title = "SPEI Map 2016.12",
    fill = "SPEI Value"
  ) +
  theme_minimal()



