mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)
  
  tagList(
    tabsetPanel(
      tabPanel(
        title = "2.1 Plot",
        wellPanel(
          uiOutput(ns("ui_text")),
          br(),
          br(),
          br(),
          uiOutput(ns("ui_plot"))
        )
      ),
      tabPanel(
        title = "2.2 Benchmark",
        wellPanel(
          uiOutput(ns("ui_text_1")),
          br(),
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
        data = NULL,
        benchmark = NULL,
        af_table = NULL,
        fit = NULL,
        gp = NULL
      )

      observeEvent(ext$aggregated, {
        rv$name <- unique(ext$aggregated$chemical_name)
      })

      observeEvent(ext$aggregated, {
        data <- wqbench::wqb_benchmark_method(ext$aggregated)
        data <- wqbench::wqb_af_variation(data)
        data <- wqbench::wqb_af_ecological(data)
        data <- wqbench::wqb_af_bc_species(data)
        rv$data <- data
      })

      observeEvent(ext$aggregated, {
        method <- rv$data$method[1]
        rv$af_table <- tabulate_af(rv$data)
        method <- rv$data$method[1]
        if (method == "VF") {
          rv$bench <- wqbench::wqb_generate_vf(rv$data)
        } else {
          fit <- wqbench:::wqb_generate_ssd_fit(rv$data)
          rv$fit <- fit
          rv$bench <- wqbench::wqb_generate_ssd(rv$data, rv$fit)
        }
      })

      # Tab 2.1
      output$text <- renderText({rv$name})
      output$ui_text <- renderUI({
        text_output(ns("text"))
      })

      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp
      })

      observeEvent(ext$aggregated, {
        req(rv$bench)
        if (length(rv$data) == 0) {
          return()
        }
        method <- rv$data$method[1]
        if (method == "VF") {
          rv$gp <- wqbench::wqb_plot_vf(rv$data)
        } else {
          rv$gp <- wqbench::wqb_plot_ssd(rv$data, rv$fit)
        }
      })
      
      # Tab 2.2
      output$text_1 <- renderText({rv$name})
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })
      
      output$table_bench <- renderTable(rv$bench)
      output$ui_table_bench <- renderUI({
        wellPanel(tableOutput(ns("table_bench")))
      })

      output$table_af <- renderTable(rv$af_table)
      output$ui_table_af <- renderUI({
        wellPanel(tableOutput(ns("table_af")))
      })


    }
  )
}

