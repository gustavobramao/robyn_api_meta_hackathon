library(plumber)

#########INITIAL_PATH_SET############
robyn_api_project_path <- Sys.getenv("ROBYN_API_PROJECT_PATH")
robyn_api_ip <- Sys.getenv("ROBYN_API_IP")
robyn_api_port <- as.integer(Sys.getenv("ROBYN_API_PORT"))

print(paste0("robyn_api_project_path is set to: ", robyn_api_project_path))
print(paste0("roby_api ip is set to: ", robyn_api_ip, " port is: ", robyn_api_port))

#########INITIAL_PATH_SET DONE############


r <- plumb(paste0(robyn_api_project_path, "api/allocator_output/simulator_controller.R"))

r$run(port=robyn_api_port, host=robyn_api_ip)
