mod_about_ui <- function(id, label = "about") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h1("About"),
      uiOutput(ns("ui_about")),
      uiOutput(ns("ui_text_1")),
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
      
      output$ui_about <- renderUI({
        includeMarkdown(
          system.file(package = "shinywqbench", "extdata/about.md")
        )
      })
      
      output$text_1 <- renderText({
        paste(
          "wqbench version:", as.character(packageVersion("wqbench")),"<br/>", 
          "shinywgbench version:", as.character(packageVersion("shinywqbench"))
        )
      })
      output$ui_text_1 <- renderUI({
        htmlOutput(ns("text_1"))
      })
      
    }
  )
}
