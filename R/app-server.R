app_server <- function(input, output, session) {
  
  data_raw <- mod_data_pull_server(
    "mod_data_pull_ui"
  )
  
  data_processed <- mod_data_processing_server(
    "mod_data_processing_ui",
    data_raw
  )
  
  mod_data_analysis_server(
    "mod_data_analysis_ui",
    data_processed
  )
  
  mod_about_server(
    "mod_about_ui"
  )
}