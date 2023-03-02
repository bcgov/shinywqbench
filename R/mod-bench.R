mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      tagList(
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "2.1 Plot",
          wellPanel(
            br(),
            uiOutput(ns("ui_plot"))
          )
        ),
        tabPanel(
          title = "2.2 Benchmark",
          wellPanel(
            br(),
            br(),
            br()
          )
        )
      )
    )
  )
}

mod_bench_server <- function(id, ext) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      # Reactive Values ----
      rv <- reactiveValues(
        data = NULL
      )
      
      observe({
        print(ext$data)
      })
      
    }
  )
}

