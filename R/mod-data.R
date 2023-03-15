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
      actionButton(ns("run"), "Run"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "1.1 Raw Data",
          well_panel(
            inline(uiOutput(ns("download_raw"))),
            inline(uiOutput(ns("button_select"))),
            br(),
            h3(uiOutput(ns("ui_text_1"))),
            br(),
            br(),
            uiOutput(ns("ui_table_selected"))
          )
        ),
        tabPanel(
          title = "1.2 Plot",
          well_panel(
            uiOutput(ns("download_plot")),
            br(),
            h3(uiOutput(ns("ui_text_3"))),
            br(),
            br(),
            uiOutput(ns("ui_plot"))
          )
        ),
        tabPanel(
          title = "1.3 Aggregate Data",
          well_panel(
            uiOutput(ns("download_aggregated")),
            br(),
            h3(uiOutput(ns("ui_text_4"))),
            br(),
            br(),
            uiOutput(ns("ui_table_aggregated"))
          )
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
        chem_pick = NULL,
        chem_check = NULL,
        aggregated = NULL,
        selected = NULL,
        gp = NULL,
        name = NULL
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
    
      # Select chemical ----
      observeEvent(input$chem_type, {
        if (input$chem_type == "name") {
          show("div_name")
          hide("div_cas")
        } else {
          hide("div_name")
          show("div_cas")
        }
      })
      
      # Data ----
      w <- waiter_data()
  
      observeEvent(input$run, label = "select_chemical", {
        if (input$chem_type == "name") {
          rv$chem_pick <- input$select_chem_name
        } else {
          rv$chem_pick <- input$select_cas_num
        }
    
        # clear inputs when chemical not picked
        if (length(rv$chem_pick) == 0) {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$selected <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div("Please select a chemical to continue"),
                footer = modalButton("Got it")
              )
            )
          )
        }  
        # clear inputs when chemical not picked
        if (rv$chem_pick == "") {
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$selected <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div("Please select a chemical to continue"),
                footer = modalButton("Got it")
              )
            )
          )
        }
        
        if (input$chem_type == "name") {
          cas_number <- cname |>
            dplyr::filter(chemical_name == input$select_chem_name) |>
            dplyr::select(cas_number) |>
            dplyr::pull()
          rv$chem_check <- cas_number
        } else {
          rv$chem_check <- input$select_cas_num
        }
        
        guideline_present  <- cname |>
          dplyr::filter(cas_number == rv$chem_check) |>
          dplyr::select(present_in_bc_wqg) |>
          dplyr::pull()
        
        # when chemical already present in wqg
        if (guideline_present) {
          chem_msg <- rv$chem_check
          rv$data <- NULL
          rv$aggregated <- NULL
          rv$selected <- NULL
          rv$gp <- NULL
          rv$name <- NULL
          rv$chem_check <- NULL
          rv$chem <- NULL
          rv$chem_pick <- NULL
          return(
            showModal(
              modalDialog(
                div(
                  paste(
                    cname$chemical_name[cname$cas_number == chem_msg], 
                    "has a guideline present. To look up this guideline go to the"
                  ),
                  tags$a(
                    "Guideline Look-Up Table",
                    target = "_blank",
                    href = "https://bcgov-env.shinyapps.io/bc_wqg/"
                  )
                ),
                footer = modalButton("Got it")
              )
            )
          )
        } else {
          rv$chem <- rv$chem_check
        }
        
        w$show()
        rv$data <- wqbench::wqb_filter_chemical(ecotox_data, rv$chem)
        rv$data$remove_row <- FALSE
        
        rv$name <- unique(rv$data$chemical_name)
        rv$selected <- rv$data
        
        rv$selected <- wqbench::wqb_benchmark_method(rv$selected)
        rv$aggregated <- wqbench::wqb_aggregate(rv$selected)
        w$hide()
      })
      
      # observeEvent(rv$selected, {
      #   w$show()
      #   rv$selected <- wqbench::wqb_benchmark_method(rv$selected)
      #   rv$aggregated <- wqbench::wqb_aggregate(rv$selected)
      #   w$hide()
      # })
      
      # Tab 1.1 ----
      output$text_1 <- renderText({rv$name})
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })
      
      output$button_select <- renderUI({
        req(rv$chem, rv$data)
        actionButton(ns("select"), "Edit Data")
      })
      
      output$download_raw <- renderUI({
        req(rv$chem, rv$data)
        download_button(ns("dl_raw"))
      })
      
      output$dl_raw <- downloadHandler(
        filename = function() {
          file_name_dl("data-raw", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$data)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- rv$data
          }
          readr::write_csv(data, file)
        }
      )

      observeEvent(input$select, {

        rv$data <-
          rv$data |>
          dplyr::mutate(
            id = dplyr::row_number(),
            remove_row = dplyr::case_when(
              id %in% input$table_selected_rows_selected & remove_row ~ FALSE, # if already selected and selected again then deselect
              id %in% input$table_selected_rows_selected ~ TRUE, # then select them 
              TRUE ~ remove_row # keep the rest the same
            )
          ) |>
          dplyr::select(
            -"id"
          )
        
        rv$selected <-
          rv$data |>
          dplyr::filter(!remove_row)
        
      })
      
      output$table_selected <- DT::renderDT({
        req(rv$data)
        data_table(rv$data) |> 
          DT::formatStyle(
            columns = c("remove_row"),
            target = "row",
            backgroundColor = DT::styleEqual(c(1), c("#ff4d4d"))
          )
      })
      
      output$ui_table_selected <- renderUI({
        table_output(ns("table_selected"))
      })
      
      # Tab 1.2 ----
      output$text_3 <- renderText({rv$name})
      output$ui_text_3 <- renderUI({
        text_output(ns("text_3"))
      })
      
      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp
      })
      
      observeEvent(rv$selected, {
        if (length(rv$selected) == 0) {
          return()
        }
        print("render the plot again")
        print(rv$selected)
        rv$gp <- wqbench::wqb_plot(rv$selected)
      })
      
      output$download_plot <- renderUI({
        req(rv$chem, rv$gp)
        download_button(ns("dl_data_plot"))
      })
      
      output$dl_data_plot <- downloadHandler(
        filename = function() {
          file_name_dl("plot-data", rv$chem, "png")
        },
        content = function(file) {
          ggplot2::ggsave(
            file,
            rv$gp,
            device = "png"
          )
        }
      )
      # Tab 1.3 ----
      output$text_4 <- renderText({rv$name})
      output$ui_text_4 <- renderUI({
        text_output(ns("text_4"))
      })
      
      output$table_aggregated <- DT::renderDT({
        data_table(rv$aggregated)
      })
      
      output$ui_table_aggregated <- renderUI({
        table_output(ns("table_aggregated"))
      })
      
      output$download_aggregated <- renderUI({
        req(rv$chem, rv$aggregated)
        download_button(ns("dl_aggregated"))
      })
      
      output$dl_aggregated <- downloadHandler(
        filename = function() {
          file_name_dl("data-aggregaated", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$aggregated)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- rv$aggregated
          }
          readr::write_csv(data, file)
        }
      )
      
      return(rv)
    }
  )
}
