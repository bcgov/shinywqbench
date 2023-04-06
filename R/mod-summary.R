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

mod_summary_ui <- function(id, label = "summary") {
  ns <- NS(id)
  
  tagList(
    wellPanel(
      h2("Summary"),
      br(),
      br(),
      download_button(ns("report"), label = "Generate PDF report"),
      br(),
      br(),
      download_button(ns("data"), label = "Download data set"),
      br(),
      br()
    )
  )
}

mod_summary_server <- function(id, ext1, ext2) {
  moduleServer(
    id, 
    function(input, output, session) {
      ns <- session$ns
      
      output$report <- downloadHandler(
        filename = function() {
          file_name_dl("shinywqbench-report", ext2$cas, "pdf")
        },
        content = function(file) {
          tempReport <- file.path(tempdir(), "summary-report.Rmd")
          file.copy(
            system.file("extdata/summary-report.Rmd", package = "shinywqbench"), 
            tempReport, overwrite = TRUE
          )
          
          if (!is.null(ext2$name)) {
            params <- list(
              chem_name = stringr::str_squish(ext2$name),
              cas_num = ext2$cas,
              af_table = ext2$af_table,
              af = ext2$af,
              trophic_sp_table = ext2$trophic_sp_table,
              trophic_grp_table = ext2$trophic_grp_table,
              method = ext2$method,
              benchmark = ext2$bench,
              gp_result = ext2$gp_results
            )
          } else {
            # for when no benchmark has been calculated
            params <- list(
              chem_name = "",
              cas_num = "",
              af_table = NULL,
              af = NA_real_,
              trophic_sp_table = NULL,
              trophic_grp_table = NULL,
              method = "",
              benchmark = data.frame(ctv_est_mg.L = NA_real_),
              gp_result = NULL
            )
          }
          
    
          rmarkdown::render(
            tempReport, 
            output_file = file,
            params = params,
            envir = new.env(parent = globalenv())
          )
        }
      )
      
      # add raw, aggregated, ctv
      output$data <- downloadHandler(
        filename = function() {
          file_name_dl("data-summary", ext2$cas, "xlsx")
        },
        content = function(file) {
          if (is.null(ext2$raw)) {
            sheets <- list(
              note = data.frame(x = "no benchmark generated")
            )
          } else {
            sheets <- list(
              raw = filter_data_raw_dl(ext2$raw),
              selected = filter_data_raw_dl(ext2$selected),
              aggregate_data = filter_data_agg_dl(ext2$agg),
              assessment_factor = ext2$af_table,
              ctv = ext2$bench
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )
      
    }
  )
}