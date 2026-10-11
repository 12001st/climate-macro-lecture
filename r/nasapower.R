install.packages(c("nasapower","openxlsx"))
library(nasapower)
library(openxlsx)

rm(list = ls())

# Working directory: the r/ folder of this repository, e.g. setwd("path/to/climate-macro-lecture/r")

# 특정 객체만 제거
#rm(data0, data_SA)

# 패턴으로 객체 제거
#rm(list = ls(pattern = "^data"))

# 현재 R 작업환경에 있는 모든 객체의 이름을 나열
#ls()


#########################
### 날씨데이터 억세스하기

seoul_re <- get_power(
  community = "re",
  lonlat = c(126.6, 37.3),
  pars = c("T2M", "TS", "T2M_RANGE", "T2M_MAX", "T2M_MIN", "PRECTOTCORR", "WS10M", "WS10M_MAX", "WS10M_MIN", "WS10M_RANGE", "WD10M"),
  dates = c("1981-01-01","2025-04-30"),
  temporal_api = "daily"
)

str(seoul_re) 
head(seoul_re) 
range(seoul_re$YEAR)
table(seoul_re$YEAR)
table(seoul_re$DOY)

write.xlsx(seoul_re,"data/seoul_re.xlsx")


busan_re <- get_power(
  community = "re",
  lonlat = c(129, 35.1),
  pars = c("T2M", "TS", "T2M_RANGE", "T2M_MAX", "T2M_MIN", "PRECTOTCORR", "WS10M", "WS10M_MAX", "WS10M_MIN", "WS10M_RANGE", "WD10M"),
  dates = c("1981-01-01","2025-04-30"),
  temporal_api = "daily"
)

write.xlsx(busan_re,"data/busan_re.xlsx")

#######################
### 패널데이터셋 만들기

library(dplyr)
library(tidyr)

# 도시별 데이터셋이 있다고 가정
Korea_re <- bind_rows(
  mutate(seoul_re, city = "Seoul"),
  mutate(busan_re, city = "Busan")
)

str(Korea_re) 
write.xlsx(Korea_re,"data/Korea_re.xlsx")


#######################
# https://power.larc.nasa.gov/
vignette("nasapower")

# 1. Example fetching daily data for a single point
# 2. Example fetching daily data for an area
# 3. Example fetching interannual data for an area
# 4. Example fetching climatology data

#######################

# 1. Example fetching daily data for a single point

daily_single_ag <- get_power(
  community = "ag",
  lonlat = c(151.81, -27.48),
  pars = c("RH2M", "T2M", "PRECTOTCORR"),
  dates = c("1985-01-01", "1985-01-31"),
  temporal_api = "daily"
)

head(daily_single_ag)


# 2. Example fetching daily data for an area

daily_region_ag <- get_power(
  community = "ag",
  lonlat = c(150.5, -28.5 , 153.5, -25.5),
  pars = c("RH2M", "T2M"),
  dates = c("1985-01-01", "1985-01-02"),
  temporal_api = "daily"
)

