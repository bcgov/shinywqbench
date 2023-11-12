# Copyright 2023 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

mod_data_ui <- function(id, label = "data") {
  ns <- NS(id)

  fluidRow(
    column(
      4,
      wellPanel(
        tagList(
          radioButtons(
            ns("chem_type"),
            label = "Select chemical by",
            choices = c("Name", "CAS Registry Number (without dashes)"),
            selected = "Name",
            inline = TRUE
          ),
          shinyjs::hidden(
            div(
              id = ns("div_name"),
              selectizeInput(
                ns("select_chem_name"),
                label = "",
                choices = NULL
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
      wellPanel(
        p("Select a chemical by name or with the CAS registry number (without dashes) by using the radio buttons."),
        p("1. To clear a selection, hit the backspace button in the input field."),
        p("2. If you are unable to find the chemical by name try the CAS number."),
        p(
          "3. You can use the", 
          a("CAS Common Chemistry lookup tool", href = "https://commonchemistry.cas.org/"), 
          "maintained by the American Chemical Society to look up the CAS number."
        ),
        p(
          "4. The", 
          a("CompTox Chemicals Dashboard", href = "https://comptox.epa.gov/dashboard/"), 
          "is also helpful to look up synonyms. Many chemicals have multiple names."
        ),
        p("Once a chemical has been selected, hit the Run button."),
      ),
      wellPanel(
        p("You can add your own data by filling in the table below and then hitting the add button."),
        br(),
        rhandsontable::rHandsontableOutput(ns("add")),
        br(),
        actionButton(ns("add_button"), "Add"),
        br()
      )
    ),
    column(
      8,
      tabsetPanel(
        tabPanel(
          title = "1.1 Data Review",
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
          title = "1.2 View Plot",
          well_panel(
            uiOutput(ns("download_plot")),
            br(),
            h3(uiOutput(ns("ui_text_2"))),
            br(),
            br(),
            uiOutput(ns("ui_plot"))
          )
        ),
        tabPanel(
          title = "1.3 Aggregated Data",
          well_panel(
            uiOutput(ns("download_aggregated")),
            br(),
            h3(uiOutput(ns("ui_text_3"))),
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
        name = NULL,
        data_table_agg = NULL,
        clear_id = 1
      )

      # Inputs ----
      updateSelectizeInput(
        session = session,
        inputId = "select_chem_name",
        choices = sort(cname$chemical_name),
        server = TRUE,
        selected = ""
      )

      updateSelectizeInput(
        session = session,
        inputId = "select_cas_num",
        choices = sort(cname$cas_number),
        server = TRUE,
        selected = ""
      )

      # Select chemical ----
      observeEvent(input$chem_type, {
        if (input$chem_type == "Name") {
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
        if (input$chem_type == "Name") {
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
          rv$data_table_agg <- NULL
          rv$clear_id <- 1 + rv$clear_id
          return(
            showModal(
              modalDialog(
                div("The chemical you selected cannot be found in the database."),
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
          rv$data_table_agg <- NULL
          rv$clear_id <- 1 + rv$clear_id
          return(
            showModal(
              modalDialog(
                div("The chemical you selected cannot be found in the database."),
                footer = modalButton("Got it")
              )
            )
          )
        }

        if (input$chem_type == "Name") {
          cas_number <- cname |>
            dplyr::filter(.data$chemical_name == input$select_chem_name) |>
            dplyr::select(cas_number) |>
            dplyr::pull()
          rv$chem_check <- cas_number
        } else {
          rv$chem_check <- input$select_cas_num
        }

        w$show()
        rv$chem <- rv$chem_check
        rv$data <- wqbench::wqb_filter_chemical(ecotox_data, rv$chem)
        rv$data$remove_row <- FALSE
        rv$name <- unique(rv$data$chemical_name)
        rv$selected <- rv$data
        rv$selected <- wqbench::wqb_benchmark_method(rv$selected)
        rv$aggregated <- wqbench::wqb_aggregate(rv$selected)
        w$hide()
      })

      observeEvent(rv$selected, {
        w$show()
        rv$selected <- wqbench::wqb_benchmark_method(rv$selected)
        rv$aggregated <- wqbench::wqb_aggregate(rv$selected)
        w$hide()
      })

      # Clear Tab 2 when data is edited or chemical re selected
      observeEvent(rv$chem_pick, {
        rv$clear_id <- 1 + rv$clear_id
      })
      
      # Add data
      
      # TODO: pull the sample values from the database in the data.R file
      output$add <- rhandsontable::renderRHandsontable({
        add_df_template <- data.frame(
          species_number = rep(NA_integer_, 5),
          latin_name = rep(NA_character_, 5),
          endpoint = factor(
            rep(NA_character_, 5),
            levels = sort(unique(ecotox_data$endpoint))
          ),
          effects = factor(
            NA_character_,
            levels = sort(unique(ecotox_data$effect))
          ),
          effect_conc_std_mg.L = NA_real_,
          lifestage = factor(
            NA_character_,
            levels = sort(unique(ecotox_data$lifestage))
          ),
          trophic_group = factor(
            NA_character_,
            levels = sort(unique(ecotox_data$trophic_group))
          ),
          ecological_group = factor(
            NA_character_,
            levels = sort(unique(ecotox_data$ecological_group))
          ),
          species_present_in_bc = NA
        )
        if (!is.null(add_df_template)) {
          rhandsontable::rhandsontable(add_df_template, rowHeaders = NULL) |>
            rhandsontable::hot_rows(rowHeights = 50) |>
            rhandsontable::hot_col("endpoint", allowInvalid = FALSE) |>
            rhandsontable::hot_col("effects", allowInvalid = FALSE) |>
            rhandsontable::hot_col("lifestage", allowInvalid = FALSE) |>
            rhandsontable::hot_col("trophic_group", allowInvalid = FALSE) |>
            rhandsontable::hot_col("ecological_group", allowInvalid = FALSE)
        }
      })
      
      


      # Tab 1.1 ----
      output$text_1 <- renderText({
        rv$name
      })
      output$ui_text_1 <- renderUI({
        text_output(ns("text_1"))
      })

      output$button_select <- renderUI({
        req(rv$chem, rv$data)
        actionButton(ns("select"), "Edit Data")
      })

      output$download_raw <- renderUI({
        req(rv$chem, rv$selected)
        download_button(ns("dl_raw"))
      })

      output$dl_raw <- downloadHandler(
        filename = function() {
          file_name_dl("data-raw", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$selected)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- filter_data_raw_dl(rv$selected)
          }
          readr::write_csv(data, file)
        }
      )

      observeEvent(input$select, {
        rv$clear_id <- 1 + rv$clear_id

        rv$data <-
          rv$data |>
          dplyr::mutate(
            id = dplyr::row_number(),
            remove_row = dplyr::case_when(
              .data$id %in% input$table_selected_rows_selected & .data$remove_row ~ FALSE, # if already selected and selected again then deselect
              .data$id %in% input$table_selected_rows_selected ~ TRUE, # then select them
              TRUE ~ .data$remove_row # keep the rest the same
            )
          ) |>
          dplyr::select(
            -"id"
          )

        rv$selected <-
          rv$data |>
          dplyr::filter(!.data$remove_row)
      })

      output$table_selected <- DT::renderDT({
        req(rv$data)
        data_table_raw(rv$data) |>
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
      output$text_2 <- renderText({
        rv$name
      })
      output$ui_text_2 <- renderUI({
        text_output(ns("text_2"))
      })

      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp
      })

      observeEvent(rv$selected, {
        if (nrow(rv$selected) == 0) {
          rv$gp <- NULL
          return(
            showModal(
              modalDialog(
                div(
                  "Ensure there is at least one row of data to continue.
                  All rows are selected to be removed."
                ),
                footer = modalButton("Got it")
              )
            )
          )
        }
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
      output$text_3 <- renderText({
        rv$name
      })
      output$ui_text_3 <- renderUI({
        text_output(ns("text_3"))
      })

      observeEvent(rv$selected, {
        if (nrow(rv$selected) == 0) {
          rv$data_table_agg <- NULL

          return()
        }
        rv$data_table_agg <- data_table_agg(rv$aggregated)
      })


      output$table_aggregated <- DT::renderDT({
        rv$data_table_agg
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
          file_name_dl("data-aggregated", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$aggregated)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- filter_data_agg_dl(rv$aggregated)
          }
          readr::write_csv(data, file)
        }
      )

      return(rv)
    }
  )
}
