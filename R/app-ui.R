app_ui <- function() {
  tagList(
    css_styling(),
    add_external_resources(), 
    shinyjs::useShinyjs(),
    waiter::useWaiter(),
    navbarPage(
      title = "Screening Level Water Quality Guidelines for Emerging contaminants",
      selected = "tab1",
      id = "navbarID",
      tabPanel(
        value = "tab1",
        title = "1. Data",
        mod_data_ui("mod_data_ui")
      ),
      tabPanel(
        value = "tab2",
        title = "2. Benchmark",
        mod_bench_ui("mod_bench_ui")
      ),
      tabPanel(
        value = "tab3",
        title = "3. Summary",
        mod_summary_ui("mod_summary_ui")
      ),
      tabPanel(
        value = "tab4",
        title = "About",
        mod_about_ui("mod_about_ui")
      ),
      tabPanel(
        value = "tab5",
        title = "User Guide",
        mod_user_ui("mod_user_ui")
      )
    )
  )
}
