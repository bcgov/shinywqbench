app_server <- function(input, output, session) {
  
  data_output <- mod_data_server(
    "mod_data_ui"
  )
  
  bench_output <- mod_bench_server(
    "mod_bench_ui",
    data_output
  )

  mod_summary_server(
    "mod_summary_ui",
    bench_output
  )

  mod_about_server(
    "mod_about_ui"
  )
}