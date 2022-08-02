library(dplyr)
library(readxl)
library(magrittr)
library(tidyverse)

#1. Get and Clean Data ==============================================

#read in SIMD 2020 data from csv and filter by access to services and vigintiles
access_vigintiles <- read.csv("data/simd_vigintiles.csv") %>%
  filter(SIMD.Domain == "Access To Services",
         Measurement == "Vigintile") %>%
  rename("Data_Zone" = FeatureCode,
         "Data_Zone_Name" = FeatureName,
         "Access_Deprived" = Value) %>%
  select(Data_Zone, Data_Zone_Name, Access_Deprived)

#read in SIMD inidicator data and extract data/indicators pertaining to WMDI
simd_indicators <- readxl::read_xlsx("data/simd_2020.xlsx", sheet = 3) %>%
  select(Data_Zone:Employment_count, Attainment)

#read in geography area codes to match DZ level data to IZ codes for aggregation
geo_codes <- read.csv("data/code_lookup.csv") %>%
  select(DataZone, IntZone) %>%
  rename("Data_Zone" = DataZone)

geo_names <- read.csv("data/code_lookup.csv") %>% 
  select(IntZone, IntZoneName, CPP)

#combine datasets
all_data <- left_join(access_vigintiles, simd_indicators, by = "Data_Zone")

#create new categorical column to determine which DZ fall into 15% most deprived in terms of access
#   to services (vigintiles 1,2,3 combined)
all_data$Access_Deprived <- if_else(all_data$Access_Deprived == 1 | all_data$Access_Deprived == 2 | all_data$Access_Deprived == 3,
                                      "access_deprived",
                                      "other")

#creates IZ geography code column
all_data <- left_join(all_data, geo_codes, by = "Data_Zone")

#replace suppressed data variable with NA to and covert to numeric class (for later calculations)
all_data$Attainment[all_data$Attainment == "*"] <- NA
all_data$Attainment <- as.numeric(all_data$Attainment)

#2.  Calculate population who are in 15% most access deprived areas at IZ level================

#use categorical access_deprived column to separate two population columns; 
#   population that are deprived in terms of access to services and population that is not 
service_access_data <- all_data %>%
  select(Data_Zone, IntZone, Access_Deprived, Total_population)%>%
  pivot_wider(names_from = Access_Deprived, values_from = Total_population)

#replae NAs introduced in above step with 0 (for DZ whose entire population falls into one of the two categories)
service_access_data[is.na(service_access_data)] <- 0

#aggregate 15% most access deprived populations to IZ level
iz_service_access_data <- service_access_data %>%
  group_by(IntZone) %>%
  summarise(access_deprived_pop = sum(access_deprived))
 
#3.  Aggregate other WMDI components to IZ level=================
iz_aggregate_other <- all_data %>%
  select(Data_Zone, 
         IntZone, 
         Total_population, 
         Working_age_population, 
         Employment_count, 
         Income_count, 
         Attainment) %>%
  group_by(IntZone) %>%
  summarise(Total_pop = sum(Total_population),
            Working_age_pop = sum(Working_age_population),
            Employment_count = sum(Employment_count),
            Income_count = sum(Income_count),
            Attainment = round(mean(Attainment, na.rm = TRUE),1))

#4.  Combine WMDI Components and calculate rates==========================

all_iz_data <- left_join(iz_aggregate_other, iz_service_access_data, by = "IntZone")

all_iz_rates <- all_iz_data %>%
  mutate(employment_rate = round(Employment_count/Working_age_pop*100,1),
         income_rate = round(Income_count/Total_pop*100,0),
         access_deprived_rate = round(access_deprived_pop/Total_pop*100,1))

WMDI_data <- left_join(all_iz_rates, geo_names, by = "IntZone") %>%
  select(c(1, 11, 12, 6, 8:10)) %>%
  distinct()
WMDI_data$Attainment[is.nan(WMDI_data$Attainment)] <- NA

write.csv(WMDI_data, file = "data/workforce_mobility_data.csv", row.names = FALSE)
