setwd(Sys.getenv("ROBYN_API_PROJECT_PATH"))

Sys.setenv("ROBYN_API_PROJECT_PATH"="/Users/cto/webapps/personal/infra_price/robyn_api/")
robyn_api_project_path <- Sys.getenv("ROBYN_API_PROJECT_PATH")

print(paste0("robyn_api_project_path is set to: ", robyn_api_project_path))
