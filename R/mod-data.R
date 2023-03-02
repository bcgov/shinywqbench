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
          dl_group("raw", ns),
          br(),
          br(),
          uiOutput(ns("ui_table_raw")) 
        ),
        tabPanel(
          title = "1.2 Plot",
          h2("Plotting Tab"),
          br(),
          br()
        ),
        tabPanel(
          title = "1.3 Aggregated Data per Species",
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
        data = NULL,
        chem = NULL
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
      })
      
      
      
      
      
      
      observe({
        print("input type")
        print(input$chem_type)
        
        print("cas_num")
        print(input$select_cas_num)
        
        print("chem_name")
        print(input$select_chem_name)  
        
        print("---------xxxx---------------xxxx-------------xxx---------")
        print(rv$chem)
    
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
