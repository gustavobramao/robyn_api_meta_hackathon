#* @apiTitle Robyn Hackaton infraprice.io team
#* @apiDescription Api build from Robyn Object to get all the data plots in csv
#* @get robyn_endpoint_spend_share_effect_share

robyn_endpoint_spend_share_effect_share <- function(res) {
  mydata <- read.csv("data_plot/df1.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}

#* @get /robyn_endpoit_waterfall_decomposition
robyn_endpoit_waterfall_decomposition <- function(res) {
  mydata <- read.csv("data_plot/df2.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}



#* @get /robyn_endpoit_Adstock_rate
robyn_endpoit_Adstock_rate <- function(res) {
  mydata <- read.csv("data_plot/df3.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}



#* @get /robyn_endpoit_Response_curves
robyn_endpoit_Response_curves <- function(res) {
  mydata <- read.csv("data_plot/df4_e.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}



#* @get /robyn_endpoit_mean_spends_channel
robyn_endpoit_mean_spends_channel <- function(res) {
  mydata <- read.csv("data_plot/df4_s.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}





#* @get /robyn_endpoit_Fitted_actual
robyn_endpoit_Fitted_actual <- function(res) {
  mydata <- read.csv("data_plot/df5.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}



#* @get /robyn_endpoit_diagonostic
robyn_endpoit_diagonostic <- function(res) {
  mydata <- read.csv("data_plot/df6.csv")
  print('mydata')
  print(mydata)
  con <- textConnection("val","w")
  print(paste0('con: ', con))
  write.csv(x = mydata, con, row.names = FALSE)
  close(con)
  
  print('res and res.body')
  print(res);  
  res$body <- paste(val, collapse="\n")
  print(res$body)
  return(res)
}