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
            dl_group("raw", ns),
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
            dl_group("data_plot", ns),
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
            dl_group("aggregated", ns),
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
        aggregated = NULL,
        gp = NULL,
        name = NULL
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
    
        if (length(rv$chem_pick) == 0) {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          return(
            showModal(
              modalDialog(
                div("Please select a chemical to continue"),
                footer = modalButton("Got it")
              )
            )
          )
        }  
        
        if (rv$chem_pick == "") {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$gp <- NULL
          rv$name <- NULL
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
      })
      
      observeEvent(input$submit, label = "check_if_guideline_already_present", {
        req(rv$chem_check)
      guideline_present  <- cname |>
          dplyr::filter(cas_number == rv$chem_check) |>
          dplyr::select(present_in_bc_wqg) |>
          dplyr::pull()
      
      if (guideline_present) {
        rv$data <- NULL
        rv$aggregated <- NULL
        rv$gp <- NULL
        rv$name <- NULL
        return(
          showModal(
            modalDialog(
              div(
                paste(
                  cname$chemical_name[cname$cas_number == rv$chem_check], 
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
      
      observeEvent(rv$chem_check, {
        w$show()
        rv$data <- wqbench::wqb_filter_chemical(ecotox_data, rv$chem)
        rv$name <- unique(rv$data$chemical_name)
        rv$aggregated <- wqbench::wqb_aggregate(rv$data)
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
      
      output$dl_data_plot <- downloadHandler(
        filename = "data-plot.png",
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
      
      # Download buttons
      output$dl_raw <- downloadHandler(
        filename = function() {
          paste0(input$file_raw, ".csv")
        },
        content = function(file) {
          readr::write_csv(rv$data, file)
        }
      )
      
      output$dl_aggregated <- downloadHandler(
        filename = function() {
          paste0(input$file_raw, ".csv")
        },
        content = function(file) {
          readr::write_csv(rv$aggregated, file)
        }
      )
      
      return(rv)
    }
  )
}
