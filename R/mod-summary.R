mod_summary_ui <- function(id, label = "summary") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("Summary"),
      br(),
      br(),
      br()
    )
  )
}

mod_summary_server <- function(id, ext) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
      )
      
     
      
    }
  )
}

