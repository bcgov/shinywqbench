mod_data_ui <- function(id, label = "data") {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      tagList(
        radioButtons(
          ns("chem_type"),
          label = "Select chemical by",
          choices = c("name", "cas number"),
          selected = "name",
          inline = TRUE
        ),
        shinyjs::hidden(
          div(
            id = ns("div_name"),
            selectizeInput(
              ns("select_chem_name"), 
              label = "", 
              choices = NULL,
              selected = NULL
            ),
          )
        ),
        shinyjs::hidden(
          div(
            id = ns("div_cas"),
            selectizeInput(
              ns("select_cas_num"),
              label = "",
              choices = NULL,
              selected = NULL
            )
          )
        ) 
      ),
      actionButton(ns("submit"), "Run!"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "1.1 Data Selected",
          well_panel(
            uiOutput(ns("download_data")),
            br(),
            h3(uiOutput(ns("ui_text_1"))),
            br(),
            br(),
            uiOutput(ns("ui_table_raw"))
          )
        ),
        tabPanel(
          title = "1.2 Plot",
          well_panel(
            uiOutput(ns("download_plot")),
            br(),
            h3(uiOutput(ns("ui_text_2"))),
            br(),
            br(),
            uiOutput(ns("ui_plot"))
          )
        ),
        tabPanel(
          title = "1.3 Aggregated Data per Species",
          well_panel(
            uiOutput(ns("download_aggregated")),
            br(),
            h3(uiOutput(ns("ui_text_3"))),
            br(),
            br(),
            uiOutput(ns("ui_table_aggregated"))
          )
        ) 
      )
    )
  )
}

mod_data_server <- function(id) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
        data = NULL,
        chem = NULL,
        chem_pick = NULL,
        chem_check = NULL,
        aggregated = NULL,
        gp = NULL,
        name = NULL,
        af_table = NULL,
        method = NULL,
        bench = NULL,
        fit = NULL,
        gp_results = NULL
      )
      
      # Inputs ----
      updateSelectizeInput(
        session = session,
        inputId = "select_chem_name",
        choices = sort(cname$chemical_name),
        server = TRUE
      )

      updateSelectizeInput(
        session = session,
        inputId = "select_cas_num",
        choices = sort(cname$cas_number),
        server = TRUE
      )
    
      # Select chemical ----
      observeEvent(input$chem_type, {
        if (input$chem_type == "name") {
          show("div_name")
          hide("div_cas")
        } else {
          hide("div_name")
          show("div_cas")
        }
      })
  
      observeEvent(input$submit, label = "select_chemical", {
        if (input$chem_type == "name") {
          rv$chem_pick <- input$select_chem_name
        } else {
          rv$chem_pick <- input$select_cas_num
        }
    
        # clear inputs when chemical not picked
        if (length(rv$chem_pick) == 0) {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$af_table <- NULL
          rv$method <- NULL
          rv$bench <- NULL
          rv$fit <- NULL
          rv$gp_results <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div("Please select a chemical to continue"),
                footer = modalButton("Got it")
              )
            )
          )
        }  
        # clear inputs when chemical not picked
        if (rv$chem_pick == "") {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$af_table <- NULL
          rv$method <- NULL
          rv$bench <- NULL
          rv$fit <- NULL
          rv$gp_results <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div("Please select a chemical to continue"),
                footer = modalButton("Got it")
              )
            )
          )
        }
        
        if (input$chem_type == "name") {
          cas_number <- cname |>
            dplyr::filter(chemical_name == input$select_chem_name) |>
            dplyr::select(cas_number) |>
            dplyr::pull()
          rv$chem_check <- cas_number
        } else {
          rv$chem_check <- input$select_cas_num
        }
        
        guideline_present  <- cname |>
          dplyr::filter(cas_number == rv$chem_check) |>
          dplyr::select(present_in_bc_wqg) |>
          dplyr::pull()
        
        # when chemical already present in wqg
        if (guideline_present) {
          chem_msg <- rv$chem_check
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$af_table <- NULL
          rv$method <- NULL
          rv$bench <- NULL
          rv$fit <- NULL
          rv$gp_results <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div(
                  paste(
                    cname$chemical_name[cname$cas_number == chem_msg], 
                    "has a guideline present. To look up this guideline go to the"
                  ),
                  tags$a(
                    "Guideline Look-Up Table",
                    target = "_blank",
                    href = "https://bcgov-env.shinyapps.io/bc_wqg/"
                  )
                ),
                footer = modalButton("Got it")
              )
            )
          )
        } else {
          rv$chem <- rv$chem_check
        }
      })
      
      # Data ----
      w <- waiter_data()
      
      observeEvent(rv$chem, {
        w$show()
        rv$data <- wqbench::wqb_filter_chemical(ecotox_data, rv$chem)
        rv$data <- wqbench::wqb_benchmark_method(rv$data)
        rv$aggregated <- wqbench::wqb_aggregate(rv$data)
        rv$aggregated <- wqbench::wqb_af_variation(rv$aggregated)
        rv$aggregated <- wqbench::wqb_af_ecological(rv$aggregated)
        rv$aggregated <- wqbench::wqb_af_bc_species(rv$aggregated)
        
        rv$af_table <- tabulate_af(rv$aggregated)
        rv$name <- unique(rv$data$chemical_name)
        rv$method <- rv$aggregated$method[1]
        
        if (rv$method == "VF") {
          rv$fit <- NULL
          rv$bench <- wqbench::wqb_generate_vf(rv$aggregated)
          rv$gp_results <- wqbench::wqb_plot_vf(rv$aggregated)
        } else {
          fit <- wqbench:::wqb_generate_ssd_fit(rv$aggregated)
          rv$fit <- fit
          rv$bench <- wqbench::wqb_generate_ssd(rv$aggregated, rv$fit)
          rv$gp_results <- wqbench::wqb_plot_ssd(rv$aggregated, rv$fit)
        }
      
        w$hide()
      })
      
      # Tab 1.1 ----
      output$text_1 <- renderText({rv$name})
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })
      
      output$table_raw <- DT::renderDT({
        data_table(rv$data)
      })
      output$ui_table_raw <- renderUI({
        table_output(ns("table_raw"))
      })
      
      output$download_data <- renderUI({
        req(rv$chem, rv$data)
        download_button(ns("dl_raw"))
      })
      
      output$dl_raw <- downloadHandler(
        filename = function() {
          file_name_dl("data-raw", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$data)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- rv$data
          }
          readr::write_csv(data, file)
        }
      )
      # Tab 1.2 ----
      output$text_2 <- renderText({rv$name})
      output$ui_text_2 <- renderUI({
        text_output(ns("text_2"))
      })
      
      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp
      })
      
      observeEvent(rv$data, {
        if (length(rv$data) == 0) {
          return()
        }
        rv$gp <- wqbench::wqb_plot(rv$data)
      })
      
      output$download_plot <- renderUI({
        req(rv$chem, rv$gp)
        download_button(ns("dl_data_plot"))
      })
      
      output$dl_data_plot <- downloadHandler(
        filename = function() {
          file_name_dl("plot-data", rv$chem, "png")
        },
        content = function(file) {
          ggplot2::ggsave(
            file,
            rv$gp,
            device = "png"
          )
        }
      )
      # Tab 1.3 ----
      output$text_3 <- renderText({rv$name})
      output$ui_text_3 <- renderUI({
        text_output(ns("text_3"))
      })
      
      output$table_aggregated <- DT::renderDT({
        data_table(rv$aggregated)
      })
      
      output$ui_table_aggregated <- renderUI({
        table_output(ns("table_aggregated"))
      })
      
      output$download_aggregated <- renderUI({
        req(rv$chem, rv$aggregated)
        download_button(ns("dl_aggregated"))
      })
      
      output$dl_aggregated <- downloadHandler(
        filename = function() {
          file_name_dl("data-aggregaated", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$aggregated)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- rv$aggregated
          }
          readr::write_csv(data, file)
        }
      )
      
      return(rv)
    }
  )
}
