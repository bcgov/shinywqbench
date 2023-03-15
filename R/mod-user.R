mod_about_ui <- function(id, label = "user") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("user"),
      br(),
      br(),
      br()
    )
  )
}

mod_user_server <- function(id) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
    }
  )
}