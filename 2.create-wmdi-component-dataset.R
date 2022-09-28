library(dplyr)
library(readxl)
library(magrittr)
library(tidyverse)

#1. Read and Clean Data ---------------------------

#read in geography area codes to match DZ level data to IZ codes for aggregation
geo_codes <- read.csv("Raw Data/code_lookup.csv") %>%
  select(DataZone, IntZone, IntZoneName) %>%
  rename("Data_Zone" = DataZone)

#read in SIMD inidicator data and extract data/indicators pertaining to WMDI
simd_indicators <- readxl::read_xlsx("Raw Data/simd_2020.xlsx", sheet = 3) %>%
  select(Data_Zone:Employment_count, Attainment) %>%
  left_join(., geo_codes, by = "Data_Zone")

#replace suppressed data variable with NA and covert to numeric class (for later calculations)
simd_indicators$Attainment[simd_indicators$Attainment == "*"] <- NA
simd_indicators$Attainment <- as.numeric(simd_indicators$Attainment)

#2.  Aggregate to IZ level -----------------------------
iz_aggregate <- simd_indicators %>%
  select(Data_Zone, 
         IntZone,
         IntZoneName,
         Total_population, 
         Working_age_population, 
         Employment_count, 
         Income_count, 
         Attainment) %>%
  group_by(IntZone, IntZoneName) %>%
  summarise(Total_pop = sum(Total_population),
            Working_age_pop = sum(Working_age_population),
            Employment_count = sum(Employment_count),
            Income_count = sum(Income_count),
            Attainment = round(mean(Attainment, na.rm = TRUE),1))

iz_aggregate$Attainment[is.nan(iz_aggregate$Attainment)] <- NA

#3.  Add access deprivation indicator and calculate rates ----------

combined_indicators <- left_join(iz_aggregate, iz_service_access_data, by = "IntZone")

iz_rates <- combined_indicators %>%
  mutate(EmploymentRate = round(Employment_count/Working_age_pop*100,1),
         IncomeRate = round(Income_count/Total_pop*100,0),
         AccessDeprivedRate = round(access_deprived_pop/Total_pop*100,1))
  
WMDI_data <- iz_rates %>%
  select(IntZone,
         IntZoneName,
         Attainment,
         EmploymentRate,
         IncomeRate,
         AccessDeprivedRate
         )

write.csv(WMDI_data, file = "Clean Data/workforce_mobility_indicator_data.csv", row.names = FALSE)
