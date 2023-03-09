mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      tagList(
        uiOutput(ns("button_benchmark"))
      )
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        id = ns("tabs"),
        tabPanel(
          value = "tab2.1",
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
          value = "tab2.2",
          title = "2.2 Report",
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
  )
}

mod_bench_server <- function(id, ext) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
        agg_af = NULL,
        af_table = NULL,
        method = NULL,
        name = NULL,
        cas = NULL,
        fit = NULL,
        bench = NULL,
        gp_results = NULL,
        bench_display = NULL,
        raw = NULL,
        selected = NULL
      )

      w <- waiter_data("Running model for selected chemical ...")
      
      observeEvent(input$benchmark, {
        w$show()
        rv$raw <- ext$data
        rv$selected <- ext$selected
        rv$agg <- ext$aggregated
        
        rv$agg_af <- wqbench::wqb_af_variation(rv$agg)
        rv$agg_af <- wqbench::wqb_af_ecological(rv$agg_af)
        rv$agg_af <- wqbench::wqb_af_bc_species(rv$agg_af)
        
        rv$af_table <- tabulate_af(rv$agg_af)
        
        rv$method <- rv$agg_af$method[1]
        rv$name <- rv$agg_af$chemical_name[1]
        rv$cas <- rv$agg_af$test_cas[1]
        
        if (rv$method == "VF") {
          rv$fit <- NULL
          rv$bench <- wqbench::wqb_generate_vf(rv$agg_af)
          rv$gp_results <- wqbench::wqb_plot_vf(rv$agg_af)
        } else {
          fit <- wqbench:::wqb_generate_ssd_fit(rv$agg_af)
          rv$fit <- fit
          rv$bench <- wqbench::wqb_generate_ssd(rv$agg_af, rv$fit)
          rv$gp_results <- wqbench::wqb_plot_ssd(rv$agg_af, rv$fit)
        }
        
        w$hide()
      })
      
      # Tab 2.1
      output$button_benchmark <- renderUI({
        req(ext$chem, ext$aggregated)
        actionButton(ns("benchmark"), "Generate Benchmark")
      })
      
      output$text <- renderText({rv$name})
      output$ui_text <- renderUI({
        text_output(ns("text"))
      })

      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp_results
      })
      
      output$download_plot_results <- renderUI({
        req(rv$cas, rv$gp_results)
        download_button(ns("dl_plot_results"))
      })
      
      output$dl_plot_results <- downloadHandler(
        filename = function() {
          file_name_dl("plot-results", rv$cas, "png")
        },
        content = function(file) {
          ggplot2::ggsave(
            file,
            rv$gp_results,
            device = "png"
          )
        }
      )
      
      # Tab 2.2
      output$text_1 <- renderText({rv$name})
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })
      
      output$table_bench <- renderTable(rv$bench)
      output$ui_table_bench <- renderUI({
        tableOutput(ns("table_bench"))
      })

      output$table_af <- renderTable(rv$af_table)
      output$ui_table_af <- renderUI({
        tableOutput(ns("table_af"))
      })
      
      output$download_data_bench <- renderUI({
        req(rv$cas, rv$bench, rv$af_table)
        download_button(ns("dl_data_bench"))
      })
      
      output$dl_data_bench <- downloadHandler(
        filename = function() {
          file_name_dl("data-bench", rv$cas, "xlsx")
        },
        content = function(file) {
          sheets = list(
            chemical = data.frame(
              chemical_name = rv$name,
              cas_number = rv$cas
            ),
            benchmark = rv$bench,
            assessment_factor = rv$af_table
          )
          if (is.null(rv$bench)) {
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

