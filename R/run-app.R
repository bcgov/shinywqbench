#' Run wqbench Application
#' 
#' This function will launch the wqbench app.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' run_wqbench_app()
#' }
run_wqbench_app <- function() {
  shiny::shinyAppDir(
    system.file("app", package = "shinywqbench"),
    options = list("launch.browser" = TRUE)
  )
}
