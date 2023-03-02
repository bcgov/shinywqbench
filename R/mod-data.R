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
          wellPanel(
            dl_group("raw", ns),
            br(),
            br(),
            br(),
            br(),
            uiOutput(ns("ui_table_raw")),
            uiOutput(ns("ui_text"))
          )
        ),
        tabPanel(
          title = "1.2 Plot",
          h2("Plotting Tab"),
          br(),
          br()
        ),
        tabPanel(
          title = "1.3 Aggregated Data per Species",
          dl_group("aggregated", ns),
          br(),
          br(),
          uiOutput(ns("ui_table_aggregated"))
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
        aggregated = NULL
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
          cas_number <- cname |>
            dplyr::filter(chemical_name == input$select_chem_name) |>
            dplyr::select(cas_number) |>
            dplyr::pull()
          rv$chem <- cas_number
        } else {
          rv$chem <- input$select_cas_num
        }
        rv$data <- NULL
        rv$aggregated <- NULL
      })
      
      observeEvent(rv$chem, label = "check_if_guideline_already_present", {
      
        if (length(rv$chem) == 0) {
          output$text <- renderText({
            "Please select a chemical to proceed"
          })
          rv$data <- data.frame()
          return()
        }  
        
        if (rv$chem == "") {
          output$text <- renderText({
            "Please select a chemical to proceed"
          })
          rv$data <- data.frame()
          return()
        }  
        
        
        output$text <- renderText({
          ""
        })
        
      guideline_present  <- cname |>
          dplyr::filter(cas_number == rv$chem) |>
          dplyr::select(present_in_bc_wqg) |>
          dplyr::pull()
      
      if (guideline_present) {
        rv$data <- data.frame()
        output$text <- renderText({
          "Go to www. .ca and use the BC Water Quality Generator app"
        })
      } else {
        output$text <- renderText({
          ""
        })
        rv$data <- ecotox_data |>
          dplyr::filter(test_cas == rv$chem)
        
        output$table_raw <- DT::renderDT({
          data_table(rv$data)
        })
      }
      })
      
      output$ui_table_raw <- renderUI({
        table_output(ns("table_raw"))
      })
      
      output$ui_text <- renderUI({
        text_output(ns("text"))
      })
      
      
      # Tab 1.3 ----
      observeEvent(rv$chem, {
        if (length(rv$data) == 0) {
          return()
        }
        aggregated_data <- wqbench::wqb_aggregate(ecotox_data, rv$chem)
        rv$aggregated <- aggregated_data
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
