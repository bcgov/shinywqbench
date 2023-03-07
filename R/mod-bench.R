mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)
  
  tagList(
    tabsetPanel(
      tabPanel(
        title = "2.1 Plot",
        well_panel(
          uiOutput(ns("download_plot_results")),
          br(),
          h3(uiOutput(ns("ui_text"))),
          br(),
          br(),
          uiOutput(ns("ui_plot"))
        )
      ),
      tabPanel(
        title = "2.2 Benchmark",
        well_panel(
          uiOutput(ns("download_data_bench")),
          br(),
          h3(uiOutput(ns("ui_text_1"))),
          br(),
          br(),
          uiOutput(ns("ui_table_bench")),
          uiOutput(ns("ui_table_af"))
        )
      )
    )
  )
}

mod_bench_server <- function(id, ext) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
        gp = NULL,
        bench_display = NULL
      )

      observe({
        if (is.null(ext$aggregated)) {
          ext$gp_results <- NULL
        }
      })

      # Tab 2.1
      output$text <- renderText({ext$name})
      output$ui_text <- renderUI({
        text_output(ns("text"))
      })

      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        ext$gp_results
      })
      
      output$download_plot_results <- renderUI({
        req(ext$chem, ext$gp_results)
        download_button(ns("dl_plot_results"))
      })
      
      output$dl_plot_results <- downloadHandler(
        filename = function() {
          file_name_dl("plot-results", ext$chem, "png")
        },
        content = function(file) {
          ggplot2::ggsave(
            file,
            ext$gp_results,
            device = "png"
          )
        }
      )
      
      # Tab 2.2
      output$text_1 <- renderText({ext$name})
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })
      
      output$table_bench <- renderTable(ext$bench)
      output$ui_table_bench <- renderUI({
        tableOutput(ns("table_bench"))
      })

      output$table_af <- renderTable(ext$af_table)
      output$ui_table_af <- renderUI({
        tableOutput(ns("table_af"))
      })
      
      output$download_data_bench <- renderUI({
        req(ext$chem, ext$bench, ext$af_table)
        download_button(ns("dl_data_bench"))
      })
      
      output$dl_data_bench <- downloadHandler(
        filename = function() {
          file_name_dl("data-bench", ext$chem, "xlsx")
        },
        content = function(file) {
          sheets = list(
            chemical = data.frame(
              chemical_name = ext$name,
              cas_number = ext$chem
            ),
            benchmark = ext$bench,
            assessment_factor = ext$af_table
          )
          if (is.null(ext$bench)) {
            sheets <- list(
              note = data.frame(x = "no chemical selected")
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )
      
      return(rv)
    }
  )
}

