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

mod_bench_ui <- function(id, label = "bench") {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      width = 3,
      tagList(
        uiOutput(ns("button_benchmark"))
      )
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        id = ns("tabs"),
        tabPanel(
          value = "tab2.1",
          title = "2.1 Plot",
          well_panel(
            uiOutput(ns("download_plot_results")),
            br(),
            h3(uiOutput(ns("ui_text"))),
            br(),
            br(),
            uiOutput(ns("ui_plot"))
          )
        ),
        tabPanel(
          value = "tab2.2",
          title = "2.2 Report",
          well_panel(
            uiOutput(ns("download_data_bench")),
            br(),
            h4(uiOutput(ns("ui_text_1"))),
            h5(uiOutput(ns("ui_text_2"))),
            uiOutput(ns("ui_table_trophic_groups")),
            uiOutput(ns("ui_text_3")),
            uiOutput(ns("ui_text_3_1")),
            br(),
            uiOutput(ns("ui_text_4")),
            uiOutput(ns("ui_table_bench")),
            h5(uiOutput(ns("ui_text_5"))),
            uiOutput(ns("ui_table_summary_af")),
            br(),
            h5(uiOutput(ns("ui_text_6"))),
            uiOutput(ns("ui_table_af")),
            br(),
            h5(uiOutput(ns("ui_text_7"))),
            uiOutput(ns("ui_text_8"))
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
        agg_af = NULL,
        method = NULL,
        name = NULL,
        cas = NULL,
        fit = NULL,
        bench = NULL,
        nboot = 1000,
        gp_results = NULL,
        bench_display = NULL,
        raw = NULL,
        selected = NULL,
        af_table = NULL,
        af = NULL,
        trophic_sp_table = NULL,
        trophic_grp_table = NULL
      )

      w <- waiter_data("Running model for selected chemical ...")

      observeEvent(input$benchmark, {
        # Don't allow value to be generated if already present
        guideline_present <- cname |>
          dplyr::filter(.data$cas_number == ext$chem_check) |>
          dplyr::select("present_in_bc_wqg") |>
          dplyr::pull()

        if (guideline_present) {
          chem_msg <- ext$chem_check
          
          return(
            showModal(
              modalDialog(
                div(
                  paste(
                    cname$chemical_name[cname$cas_number == chem_msg],
                    "has a guideline present. To look up this guideline go to the"
                  ),
                  tags$a(
                    "BC Water Quality Guideline Look-up App",
                    target = "_blank",
                    href = "https://www2.gov.bc.ca/gov/content/environment/air-land-water/water/water-quality/water-quality-guidelines/approved-water-quality-guidelines",
                    target = "_blank"
                  )
                ),
                footer = modalButton("Got it")
              )
            )
          )
        }
        
        w$show()
        rv$raw <- ext$data
        rv$selected <- ext$selected
        rv$agg <- ext$aggregated

        rv$agg_af <- wqbench::wqb_af(rv$agg)

        rv$trophic_sp_table <- wqbench::wqb_summary_trophic_species(rv$agg_af)
        rv$trophic_grp_table <- wqbench::wqb_summary_trophic_groups(rv$agg_af)
        rv$af_table <- wqbench::wqb_summary_af(rv$agg_af)
        rv$af <- prod(rv$af_table[["Assessment Factor"]])

        rv$method <- rv$agg_af$method[1]
        rv$name <- rv$agg_af$chemical_name[1]
        rv$cas <- rv$agg_af$cas[1]

        if (rv$method == "Deterministic") {
          rv$fit <- NULL
          rv$bench <- wqbench::wqb_method_det(rv$agg_af)
          rv$gp_results <- wqbench::wqb_plot_det(rv$agg_af)
        } else {
          rv$fit <- wqbench::wqb_ssd_fit(rv$agg_af)
          rv$bench <- wqbench::wqb_method_ssd(
            rv$agg_af, 
            rv$fit, 
            nboot = rv$nboot
          )
          rv$gp_results <- wqbench::wqb_plot_ssd(rv$agg_af, rv$fit)
        }

        w$hide()
      })

      observeEvent(ext$clear_id, {
        rv$agg_af <- NULL
        rv$method <- NULL
        rv$name <- NULL
        rv$cas <- NULL
        rv$fit <- NULL
        rv$bench <- NULL
        rv$gp_results <- NULL
        rv$bench_display <- NULL
        rv$raw <- NULL
        rv$selected <- NULL
        rv$af_table <- NULL
        rv$af <- NULL
        rv$trophic_sp_table <- NULL
        rv$trophic_grp_table <- NULL
      })

      # Tab 2.1 ----
      output$button_benchmark <- renderUI({
        req(ext$chem, ext$aggregated)
        actionButton(ns("benchmark"), "Generate Benchmark")
      })

      output$text <- renderText({
        rv$name
      })
      output$ui_text <- renderUI({
        text_output(ns("text"))
      })

      output$ui_plot <- renderUI({
        plotOutput(ns("plot"))
      })
      output$plot <- renderPlot({
        rv$gp_results
      })

      output$download_plot_results <- renderUI({
        req(rv$cas, rv$gp_results)
        download_button(ns("dl_plot_results"))
      })

      output$dl_plot_results <- downloadHandler(
        filename = function() {
          file_name_dl("plot-results", rv$cas, "png")
        },
        content = function(file) {
          ggplot2::ggsave(
            file,
            rv$gp_results,
            device = "png",
            width = 15
          )
        }
      )

      # Tab 2.2 ----
      output$text_1 <- renderText({
        paste("Chemical Name:", rv$name)
      })
      output$ui_text_1 <- renderUI({
        req(rv$name)
        text_output(ns("text_1"))
      })

      output$text_2 <- renderText({
        paste("Data Summary")
      })
      output$ui_text_2 <- renderUI({
        req(rv$name)
        text_output(ns("text_2"))
      })

      output$table_trophic_groups <- renderTable({
        rv$trophic_sp_table
      })
      output$ui_table_trophic_groups <- renderUI({
        req(rv$agg_af)
        tableOutput(ns("table_trophic_groups"))
      })

      output$text_3 <- renderText({
        paste("Benchmark devivation method selected:", rv$method)
      })
      output$ui_text_3 <- renderUI({
        req(rv$method)
        text_output(ns("text_3"))
      })

      output$text_3_1 <- renderText({
        req(rv$method)
        if (rv$method == "SSD") {
          paste(
            "Number of bootstrap samples: ", rv$nboot
          )
        } else {
          paste("")
        }
      })
      
      output$ui_text_3_1 <- renderUI({
        req(rv$bench)
        htmlOutput(ns("text_3_1"))
      })
      
      output$text_4 <- renderText({
        paste("Critical Toxicity Value (HC<sub>5</sub> if method is SSD):")
      })
      output$ui_text_4 <- renderUI({
        req(rv$bench)
        htmlOutput(ns("text_4"))
      })

      output$table_bench <- renderTable(
        {
          rv$bench
        },
        digits = 5
      )
      output$ui_table_bench <- renderUI({
        tableOutput(ns("table_bench"))
      })

      output$text_5 <- renderText({
        paste("Assessment Factor Summary")
      })
      output$ui_text_5 <- renderUI({
        req(rv$bench)
        text_output(ns("text_5"))
      })

      output$table_summary_af <- renderTable({
        rv$trophic_grp_table
      })
      output$ui_table_summary_af <- renderUI({
        req(rv$agg_af)
        tableOutput(ns("table_summary_af"))
      })

      output$text_6 <- renderText({
        paste("Recommended Assessment Factor")
      })
      output$ui_text_6 <- renderUI({
        req(rv$bench)
        text_output(ns("text_6"))
      })

      output$table_af <- renderTable({
        rv$af_table
      })
      output$ui_table_af <- renderUI({
        tableOutput(ns("table_af"))
      })

      output$text_7 <- renderText({
        paste("Final Aquatic Life Water Quality Benchmark")
      })
      output$ui_text_7 <- renderUI({
        req(rv$bench)
        text_output(ns("text_7"))
      })

      output$text_8 <- renderText({
        if (!is.null(rv$bench)) {
          paste(
            "Aquatic life water quailty benchmark WQ<sub>AL</sub> = critical toxicity value <span>&#247;</span> assessment factor <br/>",
            "QW<sub>AL</sub> = ", signif(rv$bench$ctv_est_mg.L), "mg/L", "<span>&#247;</span>", rv$af, "<br/>",
            "QW<sub>AL</sub> =", signif(rv$bench$ctv_est_mg.L / rv$af), "mg/L"
          )
        }
      })
      output$ui_text_8 <- renderUI({
        req(rv$bench)
        htmlOutput(ns("text_8"))
      })
      
      output$download_data_bench <- renderUI({
        req(rv$cas, rv$bench, rv$af_table)
        download_button(ns("dl_data_bench"))
      })

      output$dl_data_bench <- downloadHandler(
        filename = function() {
          file_name_dl("data-bench", rv$cas, "xlsx")
        },
        content = function(file) {
          sheets <- list(
            chemical = data.frame(
              chemical_name = rv$name,
              cas_number = rv$cas
            ),
            data_summary = rv$trophic_sp_table,
            ctv = rv$bench,
            af_summary = rv$trophic_grp_table,
            af = rv$af_table
          )
          if (is.null(rv$bench)) {
            sheets <- list(
              note = data.frame(x = "no chemical selected")
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )

      return(rv)
    }
  )
}
