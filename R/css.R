 add_external_resources <- function() {
  addResourcePath("www", system.file("app/www", package = "shinywqbench"))
  tagList(tags$link(rel = "stylesheet", type = "text/css", href = "www/style.css"))
}

css_styling <- function() {
  css_text <-
    "

  "
  tags$style(css_text, type = "text/css")
}
