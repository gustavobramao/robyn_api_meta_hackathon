### function to run once model is build to get the decomposition drivers for the waterfall Robyn Plot

library(dplyr)
library(tidyverse)

get_all_decomp_drivers <- function() { 
  
  df <- OutputCollect[["xDecompVecCollect"]]
  
  trend = sum(df$trend)
  season = sum(df$season)
  holiday = sum(df$holiday)                 
  competitors = sum(df$competitor_sales_B)
  events = sum(df$events)
  tv = sum(df$tv_S)
  ooh = sum(df$ooh_S)
  print = sum(df$print_S)
  facebook = sum(df$facebook_S)
  search = sum(df$search_S)
  newsletter = sum(df$newsletter)
  baseline = sum(df$intercept)
  total_sales = sum(trend+season+holiday+competitors+events+tv+ooh+print+facebook+search+newsletter+baseline)
  drivers = rbind(trend, season, holiday, competitors, events, tv, ooh, print, facebook, search, newsletter, baseline, total_sales)
  write.csv(drivers, file = "~/Desktop/saas/Api/data/drivers.csv")
  
  
}

get_all_decomp_drivers()