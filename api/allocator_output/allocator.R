### load object for API call
library(plumber)
library(dplyr)
library(Robyn)
set.seed(123)

## force multicore when using RStudio
Sys.setenv(R_FUTURE_FORK_ENABLE="true")
options(future.fork.enable = TRUE)
robyn_api_project_path <- Sys.getenv("ROBYN_API_PROJECT_PATH")

### environment path
robyn_object <- readRDS(paste0(robyn_api_project_path , "api/allocator_output/robyn_object.RDS"))
robyn_object$listInit$OutputCollect$plot_folder <- "~/robyn_charts/"

InputCollect <- robyn_object$listInit$InputCollect
OutputCollect<- robyn_object$listInit$OutputCollect
select_model <- robyn_object[["listInit"]][["OutputCollect"]][["allSolutions"]][2] # 5_143_6