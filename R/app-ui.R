app_ui <- function() {
  tagList(
    css_styling(),
    navbarPage(
      title = "Screening Level Water Quality Guidelines for Emerging contaminants",
      selected = "1. Data Pull",
      tabPanel(
        title = "1. Data",
        mod_data_ui("mod_data_ui")
      )#,
      # tabPanel(
      #   title = "2. Guideline Selection",
      #   mod_data_processing_ui("mod_data_processing_ui")
      # ),
      # tabPanel(
      #   title = "3. Guideline Generation",
      #   mod_data_analysis_ui("mod_data_analysis_ui")
      # ),
      # tabPanel(
      #   title = "About",
      #   mod_about_ui("mod_about_ui")
      # )
    )
  )
}
