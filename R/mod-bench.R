mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)
  
  tagList(
    tabsetPanel(
      tabPanel(
        title = "2.1 Plot",
        well_panel(
          h3(uiOutput(ns("ui_text"))),
          br(),
          dl_group("data_plot", ns),
          br(),
          br(),
          br(),
          uiOutput(ns("ui_plot"))
        )
      ),
      tabPanel(
        title = "2.2 Benchmark",
        well_panel(
          h3(uiOutput(ns("ui_text_1"))),
          br(),
          dl_group("data", ns),
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
        name = NULL,
        bench = NULL,
        af_table = NULL,
        fit = NULL,
        gp = NULL,
        method = NULL
      )

      observe({
        if (is.null(ext$aggregated)) {
          rv$dat <- NULL
          rv$name <- NULL
          rv$bench <- NULL
          rv$af_table <- NULL
          rv$fit <- NULL
          rv$gp <- NULL
          rv$method <- NULL
        }
      })
      
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
        rv$af_table <- tabulate_af(rv$data)
        rv$method <- rv$data$method[1]
        if (rv$method == "VF") {
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
      
      output$dl_data_plot <- downloadHandler(
        filename = "results-plot.png",
        content = function(file) {
          ggplot2::ggsave(
            file,
            rv$gp,
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
        wellPanel(tableOutput(ns("table_bench")))
      })

      output$table_af <- renderTable(rv$af_table)
      output$ui_table_af <- renderUI({
        wellPanel(tableOutput(ns("table_af")))
      })

      output$dl_data <- downloadHandler(
        filename <-  "benchmark-ouput.xlsx",
        content = function(file) {
          sheets = list(
            benchmark = rv$bench,
            assessment_factor = rv$af_table
          )
          if (is.null(rv$bench)) {
            sheets <- list(
              note = data.frame(x = "no data")
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )
      
      return(rv)
    }
  )
}

