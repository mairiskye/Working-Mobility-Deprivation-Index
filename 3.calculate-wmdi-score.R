#This Script reads in indicator data and adds a new column
 #which shows the workforce mobility index 

#Read Data----------------------------

#initialize a new column to be populated using custom function
indicator_data <- read.csv("Clean Data/workforce_mobility_indicator_data.csv")%>%
  mutate(WMDI = NA)

# Function to calculate index-----------------------
  # Param: a df (1 obs. of 4 variables)
  # Param desc: the four columns of a given row of the 
  # dataframe which contain indicator values

workforce_mobility_index <- function(df_row) {

  values <- as.numeric(unlist(df_row))
  points <- 0
  #increment 'points' by attainment score
  if(is.na(values[1])) {
    return(NA)
  }
  else{
    
   if(values[1] < 5) {
     points <- points + 4
  } else if(values[1] >= 5 & values[1] < 5.5) {
    points <- points + 3
  } else if(values[1] >= 5.5 & values[1] < 6) {
    points <- points + 2
  } else if (values[1] >= 6){
    points <- points + 1
  }
  #add employment score to 'point'
  if(values[2] < 5) {
    points <- points + 1
  } else if(values[2] >= 5 & values[2] < 10) {
    points <- points + 2
  } else if(values[2] >= 10 & values[2] < 15) {
    points <- points + 3
  } else if (values[2] >= 15){
    points <- points + 4
  }
  #add income score
  if(values[3] < 5) {
    points <- points + 1
  } else if(values[3] >= 5 & values[3] < 10) {
    points <- points + 2
  } else if(values[3] >= 10 & values[3] < 15) {
    points <- points + 3
  } else if (values[3] >= 15){
    points <- points + 4
  }
  #add service accessibility score to 'points'
  if(values[4] >= 0 & values[4] < 25) {
    points <- points + 2
  } else if(values[4] >= 25 & values[4] < 50) {
    points <- points + 4
  } else if (values[4] >= 50){
    points <- points + 6
  }
  return(points)
  }
}

# Loop to populate index column based on row contents--------------------------
 
 for (i in 1:nrow(indicator_data)){
  row <- i
  wmdi_score <- workforce_mobility_index(indicator_data[row, 3:6])
  indicator_data$WMDI[row] <- wmdi_score 
}


#write.csv(indicator_data, file = "Clean Data/WMDI-for-all-IZ.csv", row.names = FALSE)