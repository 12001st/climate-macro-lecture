# https://spei.csic.es/index.html
# https://www.uea.ac.uk/groups-and-centres/climatic-research-unit
# https://catalogue.ceda.ac.uk/

install.packages(c("ncdf4","terra","sf","scales","ggplot2","tidyterra","openxlsx"))

#library(ncdf4) # package for netcdf manipulation
library(terra) # an updated version of raster package  #library(raster)
library(sf) # package for geospatial analysis
library(scales) # scale function for visualization
library(ggplot2) # package for plotting
library(tidyterra) # "tidyverse" method and "ggplot2" helpers for "terra" objects
library(openxlsx) # package for exporting data to excel

rm(list = ls())

# Working directory: the r/ folder of this repository, e.g. setwd("path/to/climate-macro-lecture/r")

#spei01af <- nc_open("data/spei01_africa.nc")
spei01af <- rast("data/spei01_africa.nc")

# raster의 기본구조확인
str(spei01af)
class(spei01af)
print(spei01af)
dim(spei01af)
names(spei01af)

# 특정 시점의 SPEI 데이터 추출 (예: 첫 번째 시점)
spei_slice <- spei01af[[432]]  # 첫 번째 시간 슬라이스


# 기본 plot
plot(spei_slice)

# ggplot2를 이용한 고급 시각화
ggplot() +
  geom_spatraster(data = spei_slice) +
  scale_fill_gradient2(
    low = "red", 
    mid = "white", 
    high = "green"
  ) +
  labs(
    title = "SPEI Map at Specific Time (2016.12)",
    fill = "SPEI Value"
  ) +
  theme_minimal()

df <- as.data.frame(spei01af, xy = TRUE)
df <- as.data.frame(spei01af[[421:432]], xy = TRUE)
head(df)
write.csv(df, "data/spei01af.csv", row.names = FALSE)

# 지정한 지역범위로 데이터 불러오기
region_extent <- ext(c(15, 25, -35, -25))
spei01_region_southaf <- crop(spei01af, region_extent)
region_slice <- spei01_region_southaf[[432]]
plot(region_slice)

region_df <- as.data.frame(spei01_region_southaf, xy = TRUE)
head(region_df)
write.csv(region_df, "data/spei01_region_southaf.csv", row.names = FALSE)

# 시간정보 수동 생성
start_date <- as.Date("1981-01-01")
date_values <- seq.Date(start_date, by = "month", length.out = nlyr(spei01af))
names(spei01af) <- format(date_values, "%Y-%m")
names(spei01af)

names(spei01_region_southaf) <- format(date_values, "%Y-%m")
names(spei01_region_southaf)

region_df <- as.data.frame(spei01_region_southaf, xy = TRUE)
write.csv(region_df, "data/spei01_region_southaf.csv", row.names = FALSE)
