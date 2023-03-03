# UI ---- 
well_panel <- function(...) {
  wellPanel(..., style = "font-size:87%", class = "wellpanel")
}

text_output <- function(...) {
  textOutput(...)
}

table_output <- function(...) {
  DT::DTOutput(...)
}

data_table <- function(data) {
  if (!is.data.frame(data)) {
    return()
  }
  DT::datatable(
    data,
    escape = FALSE, 
    rownames = FALSE, 
    class = "cell-border compact",
    options = list(
      ordering = TRUE,
      autowidth = TRUE, 
      scrollX = TRUE,
      columnDefs = list(list(
        className = "dt-center",
        targets = "_all"
      ))
    )
  )
}

# Buttons ---- 
dl_group <- function(x, ns) {
  fillRow(
    height = "90%", width = 300, flex = c(2, 3),
    dl_button(ns(paste0("dl_", x)), "Download")
  )
}

dl_button <- function(..., icon = "download", class = "btn-primary") {
  downloadButton(..., icon = icon(icon), class = class)
}

# Shinyjs Annotation ----
hide <- function(id, anim = TRUE) {
  shinyjs::hide(id, anim = anim)
}

show <- function(id, anim = TRUE) {
  shinyjs::show(id, anim = anim)
}

# Assessment Factor ----
tabulate_af <- function(data) {
  af_descriptions <- data.frame(
    Name = c("af_variation", "af_salmon", "af_planktonic", "af_bc_species"),
    Description = c(
      "Factor based on number of trophic groups and species present",
      "Ecological factor based on having a salmonid species present",
      "Ecological factor based on having a planktonic crustacean species present",
      "Factor based on number of British Columbia species present"
    )
  )
  
  data <- data |>
    dplyr::select(
      "af_variation", "af_salmon", "af_planktonic", "af_bc_species"
    ) |>
    dplyr::distinct() |>
    tidyr::pivot_longer(
      cols = c("af_variation", "af_salmon", "af_planktonic", "af_bc_species"),
      names_to = "Name",
      values_to = "Assessment Factor"
    ) |>
    dplyr::left_join(af_descriptions, by = "Name")
  
  data
}


