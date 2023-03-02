mod_data_ui <- function(id, label = "data") {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      uiOutput(ns("ui_type"))
      # selectizeInput(
      #   ns("select_chem_name"), 
      #   label = "Chemical name", 
      #   choices = NULL,
      #   selected = NULL
      # )
      
      #,
      # selectizeInput(
      #   ns("select_cas_num"), 
      #   label = "Chemical cas number", 
      #   choices = NULL
      # )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "data-raw",
          dl_group("raw", ns),
          br(),
          br(),
          uiOutput(ns("ui_table_raw")) 
        ),
        tabPanel(
          title = "plot",
          h2("Plotting Tab"),
          br(),
          br()
        ),
        tabPanel(
          title = "data-aggregated",
          h2("Aggregated data"),
          br(),
          br()
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
        data = NULL
      )
      
      # Inputs ----
      
      ### Getting this to work will remove the warning that is outputted when
      ### app launches 
      # updateSelectizeInput(
      #   session = session,
      #   inputId = "select_chem_name", 
      #   choices = sort(cname$chemical_name),
      #   server = TRUE
      # )
      # 
      # updateSelectizeInput(
      #   session = session,
      #   inputId = "select_cas_num", 
      #   choices = sort(cname$cas_number),
      #   server = TRUE
      # )
      
      output$ui_type <- renderUI({
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
                "select_chem_name", 
                label = "", 
                choices = sort(cname$chemical_name),
                selected = NULL
              ),
            )
          ),
          shinyjs::hidden(
            div(
              id = ns("div_cas"),
              selectizeInput(
                "select_cas_num",
                label = "",
                choices = sort(cname$cas_number),
                selected = NULL
              )
            )
          ) 
        )
      })
      
      observe({
        req(input$chem_type)
        if (input$chem_type == "name") {
          show("div_name")
          hide("div_cas")
        } else {
          hide("div_name")
          show("div_cas")
        }
      })
      
      # output$ui_table_raw <- renderUI({
      #   table_output(ns("table_raw"))
      # })
      # 
      # output$table_raw <- DT::renderDT({
      #   data_table(rv$data)
      # })
      # 
      # observeEvent(input$chemical, {
      #   
      #   rv$data <- ecotox_data[ecotox_data$cname == input$chemical, ]
      #   
      # }, label = "filters data based on chemical input")
      # 
      # output$dl_raw <- downloadHandler(
      #   filename = function() {
      #     paste0(input$file_raw, ".csv")
      #   },
      #   content = function(file) {
      #     readr::write_csv(rv$data, file)
      #   }
      # )
      
      return(rv)
    }
  )
}
