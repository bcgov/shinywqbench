mod_user_ui <- function(id, label = "user") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h1("User Guide"),
      uiOutput(ns("ui_userguide")),
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
     
      output$ui_userguide <- renderUI({
        includeMarkdown(
          system.file(package = "shinywqbench", "extdata/user.md")
        )
      })
       
    }
  )
}