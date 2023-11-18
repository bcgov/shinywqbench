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
        p("To add your own data."),
        p("1. Download and fill in template. Check the User Guide tab for descriptions of each column."),
        uiOutput(ns("download_add")),
        br(), 
        p("2. Upload the completed template."),
        fileInput(
          ns("file_add"), 
          "",
          multiple = FALSE,
          accept = c(".csv")
        ),
        p("3. Click the Add button to add the uploaded data."),
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
        rv$data <- dplyr::relocate(
          rv$data,
          latin_name, endpoint, effect, lifestage, effect_conc_std_mg.L, 
          trophic_group, ecological_group, species_present_in_bc,
          .after = "cas",
        )
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
      
      ## Add Data ----
      output$download_add <- renderUI({
        download_button(ns("dl_add"))
      })
      
      output$dl_add <- downloadHandler(
        filename = function() paste0("template-wqbench.csv"),
        content = function(file) {
          readr::write_csv(wqbench::template[0, -1], file)
        }
      )
      
      # Add data
      observeEvent(input$add_button, {
        # Check that data already present
        if (is.null(rv$data)) {
          return(
            showModal(
              modalDialog(
                title = "Please fix the following issue ...",
                div("You must select a chemical and click run before adding your data."),
                footer = modalButton("Got it")
              )
            )
          )
        }
        
        check_uploaded_1 <- try(
          check_upload(input$file_add$datapath, ext = "csv"), 
          silent = TRUE
        )
        if (is_try_error(check_uploaded_1)) {
          return(showModal(check_modal(check_uploaded_1)))
        }
        
        add_tbl_1 <- readr::read_csv(
          input$file_add$datapath,
          show_col_types = FALSE
        )
        
        if (nrow(add_tbl_1) == 0) {
          return(
            showModal(
              modalDialog(
                title = "Please fix the following issue ...",
                paste("There are no rows of data in the uploaded data.,", 
                "Please fill out the template and try again."),
                footer = modalButton("Got it")
              )
            )
          )
        }
        
        add_tbl_1 <- try(
          wqbench::wqb_check_add_data(add_tbl_1, wqbench::template),
          silent = TRUE
        )
        if (is_try_error(add_tbl_1)) {
          return(showModal(check_modal(add_tbl_1)))
        }
        
        species_match <- rv$data |>
          dplyr::select(species_number, latin_name) |>
          dplyr::distinct()
        
        add_tbl_1 <- add_tbl_1 |>
          dplyr::left_join(
            species_match, 
            by = "latin_name", 
            multiple = "first"
          ) |>
          dplyr::mutate(
            species_number = dplyr::if_else(
              is.na(species_number), 
              (max(rv$data$species_number):(max(rv$data$species_number) + nrow(add_tbl_1)))[-1], 
              species_number
            ),
            trophic_group = factor(
              trophic_group,
              levels = levels(rv$data$trophic_group)
            ),
            ecological_group = factor(
              ecological_group, 
              levels = levels(rv$data$ecological_group)
            ), 
            remove_row = FALSE
          )
        
        # 3. Add to data set
        rv$data <-
          rv$data |>
          dplyr::bind_rows(add_tbl_1) |>
          tidyr::fill(chemical_name, cas)

        ## not sure where this can go or how the other parts may need to be adjusted 
        rv$selected <- wqbench::wqb_benchmark_method(rv$data)
        rv$aggregated <- wqbench::wqb_aggregate(rv$selected)
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
          file_name_dl("data-review", rv$chem, "csv")
        },
        content = function(file) {
          if (is.null(rv$selected)) {
            data <- data.frame(x = "no chemical selected")
          } else {
            data <- filter_data_raw_dl(rv$selected)
          }
          readr::write_csv(data, file, na = "")
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
          readr::write_csv(data, file, na = "")
        }
      )

      return(rv)
    }
  )
}
