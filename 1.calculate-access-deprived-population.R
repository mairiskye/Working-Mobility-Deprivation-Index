#calculating population in 15% most deprived areas in terms 
  #of access to services (at IZ level)

#READ AND PREPARE DATA -------------------------------

  #extract access to services DZ vigintiles from file
access_vigintiles_dz <- read.csv("data/simd_vigintiles.csv") %>%
  filter(SIMD.Domain == "Access To Services",
         Measurement == "Vigintile") %>%
  rename("Data_Zone" = FeatureCode,
         "Data_Zone_Name" = FeatureName,
         "Access_Deprived" = Value) %>%
  select(Data_Zone, Data_Zone_Name, Access_Deprived) %>%
  left_join(., geo_codes, by = "Data_Zone")
 
  #extract SIMD 2020 Total Population figures
dz_pop <- readxl::read_xlsx("data/simd_2020.xlsx", sheet = 3) %>%
  select(Data_Zone, Total_population)

#read in geography code look up (for DZ to IZ match)
geo_codes <- read.csv("data/code_lookup.csv") %>%
  select(DataZone, IntZone) %>%
  rename("Data_Zone" = DataZone)

#CALCULATE ACCESS DEPRIVED POP -------------------------

#create categorical column to identify whether a zone is
  #among 15% most deprived (in vigintile 1,2, or 3)
  # or not.
service_access_data <- left_join(access_vigintiles_dz, dz_pop, by = "Data_Zone") %>%
  mutate(AccessCategory = if_else(Access_Deprived == 1 | Access_Deprived == 2 | Access_Deprived == 3,
                                  "most_deprived",
                                  "other"))

#pull population totals into one of two columns depending on 
  #whether 'AccessCategory' is 'most_deprived' or 'other'.
  #This allows aggregation of population which is in 
  #deprived area to IZ level.
service_access_data_wide <- service_access_data %>%
  pivot_wider(names_from = AccessCategory, values_from = Total_population)

#convert NAs introduced in pivot to 0 to allow aggregation
service_access_data_wide[is.na(service_access_data_wide)] <- 0

#aggregate population within access deprived areas.
#Note some IZs do not contain DZ which are within 15%
# considered deprived areas.
iz_service_access_data <- service_access_data_wide %>%
  group_by(IntZone) %>%
  summarise(access_deprived_pop = sum(most_deprived))
