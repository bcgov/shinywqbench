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
          file_name_dl("ecotox-report", ext2$cas, "pdf")
        },
        content = function(file) {
          tempReport <- file.path(tempdir(), "summary-report.Rmd")
          file.copy(
            system.file("extdata/summary-report.Rmd", package = "shinywqbench"), 
            tempReport, overwrite = TRUE
          )
          params <- list(
            chem_name = stringr::str_squish(ext2$name),
            af_table = ext2$af_table,
            af = ext2$af,
            trophic_sp_table = ext2$trophic_sp_table,
            trophic_grp_table = ext2$trophic_grp_table,
            method = ext2$method,
            benchmark = ext2$bench
          )
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
          sheets <- list(
            raw = filter_data_raw_dl(ext2$raw),
            selected = filter_data_raw_dl(ext2$selected),
            aggregate_data = filter_data_agg_dl(ext2$agg),
            assessment_factor = ext2$af_table,
            ctv = ext2$bench
          )
          if (is.null(ext1$data)) {
            sheets <- list(
              note = data.frame(x = "no chemical selected")
            )
          }
          writexl::write_xlsx(sheets, file)
        }
      )
      
    }
  )
}