# Working-Mobility-Deprivation-Index
Expanding the Edinburgh and South Scotland City Region Deal Project to calculate a Scotland-wide Working Mobility Deprivation Index. 

This first script: (1.get_and_clean_data.R) reads in SIMD data which can be found here: 
https://www.gov.scot/publications/scottish-index-of-multiple-deprivation-2020v2-indicator-data/ 
This contains raw data for three of the four components which make up the WMDI: Employment, Income and Attainment as well as the population (working age and total) at DZ level. Employment and Income deprived numbers are summed to IZ level and rates are calculated using working age and total population respectively. Attainment data (which contains suppressed values (*) which are substituted with NAs and then aggregated to IZ level by taking an average of non-suppressed values. Note that there are some IZ areas for which all all DZ figures have been suppressed.
Access to Service data (the fourth component) can be obtained as a csv here:
https://statistics.gov.scot/slice?dataset=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fscottish-index-of-multiple-deprivation&http%3A%2F%2Fpurl.org%2Flinked-data%2Fcube%23measureType=http%3A%2F%2Fstatistics.gov.scot%2Fdef%2Fmeasure-properties%2Fvigintile&http%3A%2F%2Fstatistics.gov.scot%2Fdef%2Fdimension%2FsimdDomain=http%3A%2F%2Fstatistics.gov.scot%2Fdef%2Fconcept%2Fsimd-domain%2Faccess-to-services
It assigns DZs to vigintiles (20 ranked segments) of deprivation with regards to access to service deprivation. DZs within vigintile 1,2 & 3 (?check) fall within 15% most access deprived. This data is extracted and joined with the larger SIMD dataset (above) using DZ codes. Then the population within 15% most access deprived areas in each IZ can be calculated and from this the proportion who are access deprived within each IZ.

A second script (2.calculate_wmdi_score.R) adds a new WMDI score column to the dataset created by looping through each row and, for each one, passes the four component figures to a function (workforce_mobility_index()) which determines the final WMDI score according to the following points system:

Attainment: Under 5 = 4 points, from 5 to under 5.5 = 3 points, from 5.5 to under 6 = 2 points, over 6 point = 1 point.
15% access deprived: 0% = 0 points, less than 25% = 2 points, from 25% to under 50% = 4 points, from 50% = 6 points
Income deprived and Employment Deprived: less than 5% = 1 point, from 5% to under 10% = 2 points, from 10% to under 15% = 3 points, from 15% = 4 points




