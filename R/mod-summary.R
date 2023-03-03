mod_summary_ui <- function(id, label = "summary") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("Summary"),
      br(),
      br(),
      br(),
      downloadButton(
        outputId = ns("report"),
        label = "Generate report"
      )
    )
  )
}

mod_summary_server <- function(id, ext) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
      )
      
      observe({
        print(ext$name)
        print(ext$method)
        print(ext$bench)
        print(ext$af_table)
      })
     
      
      output$report <- downloadHandler(
        filename <-  "ecotox_report.pdf",
        
        content = function(file) {
          
          tempReport <- file.path(tempdir(), "summary-report.Rmd")
          file.copy(
            system.file("extdata/summary-report.Rmd", package = "shinywqbench"), 
            tempReport, overwrite = TRUE
          )
          
          params <- list(
            chem_name = ext$name,
            method = ext$method,
            benchmark = ext$bench,
            af = ext$af_table
          )
          
          rmarkdown::render(
            tempReport, 
            output_file = file,
            params = params,
            envir = new.env(parent = globalenv())
          )
        }
      )
      
      
    }
  )
}


# output$dl_aggregated <- downloadHandler(
#   filename = function() {
#     paste0(input$file_raw, ".csv")
#   },
#   content = function(file) {
#     readr::write_csv(rv$aggregated, file)
#   }
# )