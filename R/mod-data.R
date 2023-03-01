mod_data_ui <- function(id, label = "data") {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      uiOutput(ns("select_chemical"))
    ),
    mainPanel(
      tabPanel(
        title = "data",
        dl_group("raw", ns),
        br(),
        br(),
        uiOutput(ns("ui_table_raw")) 
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
        data = NULL
      )
      
      # Inputs ----
      output$select_chemical <- renderUI({
        selectInput(
          inputId = ns("chemical"), 
          label = "Chemical",
          choices = c("selenium", "aluminum", "lead"),
          selected = NULL,
          multiple = TRUE
        )
      })
      
      output$ui_table_raw <- renderUI({
        table_output(ns("table_raw"))
      })
      
      output$table_raw <- DT::renderDT({
        data_table(rv$data)
      })
      
      observeEvent(input$chemical, {
        
        rv$data <- ecotox_data[ecotox_data$cname == input$chemical, ]
        
      }, label = "filters data based on chemical input")
      
      output$dl_raw <- downloadHandler(
        filename = function() {
          paste0(input$file_raw, ".csv")
        },
        content = function(file) {
          readr::write_csv(rv$data, file)
        }
      )
      
      return(rv)
    }
  )
}
