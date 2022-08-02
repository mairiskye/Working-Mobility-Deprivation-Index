#function to determine workforce mobility deprivation index for all IZs in Scotland
data <- read.csv("data/workforce_mobility_data.csv")%>%
  mutate(WMDI = NA)

workforce_mobility_index <- function(df_row) {
  values <- as.numeric(unlist(df_row))
  points <- 0
  #assign attainment points scoring
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
  #assign employment points
  if(values[2] < 5) {
    points <- points + 1
  } else if(values[2] >= 5 & values[2] < 10) {
    points <- points + 2
  } else if(values[2] >= 10 & values[2] < 15) {
    points <- points + 3
  } else if (values[2] >= 15){
    points <- points + 4
  }
  #assign income points
  if(values[3] < 5) {
    points <- points + 1
  } else if(values[3] >= 5 & values[3] < 10) {
    points <- points + 2
  } else if(values[3] >= 10 & values[3] < 15) {
    points <- points + 3
  } else if (values[3] >= 15){
    points <- points + 4
  }
  #assign service accessability points
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

for (i in 1:nrow(data)){
  row <- i
  index <- workforce_mobility_index(data[row, 4:7])
   data$WMDI[row] <- index
}


