library(dplyr)
library(tidyverse)

robyn_object <- readRDS(paste0(robyn_api_project_path, "/api/allocator_output/robyn_object.RDS"))
df <- robyn_object[["listInit"]][["OutputCollect"]][["allPareto"]][["plotDataCollect"]]
df <- df$`5_143_6` ### load the model_id_needed

df1 <- df$plot1data
df2 <- df$plot2data
df3 <- df$plot3data
df4 <- df$plot4data
df5 <- df$plot5data
df6 <- df$plot6data


df1 <- as.data.frame(df1)
df2 <- as.data.frame(df2)
df3 <- as.data.frame(df3$dt_geometric)
df4_s <- as.data.frame(df4$dt_scurvePlot)
df4_e <- as.data.frame(df4$dt_scurvePlotMean)
df5 <- as.data.frame(df5$xDecompVecPlotMelted)
df6 <- df6$xDecompVecPlot

loess.data <- stats::loess(actual-predicted ~ predicted, data = df6, span = 0.75)
loess.predict <- predict(loess.data, se = T)
loess.df <- data.frame(fit = loess.predict$fit, se = loess.predict$se.fit, actual=df6$actual, act_pred=df6$actual-df6$predicted, predicted=df6$predicted)

write_csv(df1, file = paste0(robyn_api_project_path, "/data_plot/df1.csv"))
write_csv(df2, file = paste0(robyn_api_project_path, "/data_plot/df2.csv"))
write_csv(df3, file = paste0(robyn_api_project_path, "/data_plot/df3.csv"))
write_csv(df4_s, file = paste0(robyn_api_project_path, "/data_plot/df4_s.csv"))
write_csv(df4_e, file = paste0(robyn_api_project_path, "/data_plot/df4_e.csv"))
write_csv(df5, file = paste0(robyn_api_project_path, "/data_plot/df5.csv"))
write_csv(df6, file = paste0(robyn_api_project_path, "/data_plot/df6.csv"))
write_csv(loess.df, file = paste0(robyn_api_project_path, "/data_plot/df6_ci.csv"))


