library(dplyr)
library(tidyverse)

### function to clean and aggregate for Robyn MMM plot 1 spend share vs effect share
df_final <- read.csv(file = "~/Desktop/saas/Api/data/df_mmm_raw.csv")
total_spend <- sum(df_final$total_spend)
total_effect <- sum(df_final$total_response)

### prepare small for loop
media_list <- df_final$rn
df_final <- as.data.frame(df_final)

spend_share <- list() 
effect_share <- list() 
roi <- list()

for (i in media_list){
  
  print(i)
  df <- df_final %>% filter(rn==i)
  print(df)
  spend_share[[i]] = (df$total_spend/total_spend)*100
  effect_share[[i]] = (df$total_response/total_effect)*100
  roi[[i]] = df$roi_total
  
}

#### transform list into a dataframe
spend_df <- data.frame(t(sapply(spend_share,c)))
effect_df <- data.frame(t(sapply(effect_share,c)))
roi_df <- data.frame(t(sapply(roi,c)))
df_mmm_plot1 <- rbind(spend_df,effect_df,roi_df)
rownames(df_mmm_plot1) <- c("spend_share","effect_share","roi")
df_transpose = t(df_mmm_plot1)
write.csv(df_transpose, "~/Desktop/saas/Api/data/df_mmm_plot1.csv")