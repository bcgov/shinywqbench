mod_about_ui <- function(id, label = "about") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("About"),
      br(),
      br(),
      br()
    )
  )
}

mod_about_server <- function(id) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
    }
  )
}
