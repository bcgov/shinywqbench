mod_summary_ui <- function(id, label = "summary") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("Summary"),
      br(),
      br(),
      dl_button(ns("report"), label = "Generate PDF report"),
      br(),
      br(),
      dl_button(ns("data"), label = "Download data set"),
      br(),
      br()
    )
  )
}

mod_summary_server <- function(id, ext1, ext2) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      output$report <- downloadHandler(
        filename <-  "ecotox_report.pdf",
        content = function(file) {
          tempReport <- file.path(tempdir(), "summary-report.Rmd")
          file.copy(
            system.file("extdata/summary-report.Rmd", package = "shinywqbench"), 
            tempReport, overwrite = TRUE
          )
          params <- list(
            chem_name = ext2$name,
            method = ext2$method,
            benchmark = ext2$bench,
            af = ext2$af_table
          )
          rmarkdown::render(
            tempReport, 
            output_file = file,
            params = params,
            envir = new.env(parent = globalenv())
          )
        }
      )
      
      # add raw, aggregated, benchmark
      output$data <- downloadHandler(
        filename <-  "data-ouput.xlsx",
        content = function(file) {
          sheets <- list(
            data = ext1$data,
            aggregate_data = ext2$data,
            assessment_factor = ext2$af_table,
            benchmark = ext2$bench
          )
          if (is.null(ext2$af_table)) {
            sheets <- list(
              note = data.frame(x = "no data")
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )
      
    }
  )
}
