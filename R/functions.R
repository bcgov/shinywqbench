# UI ---- 
inline <- function(x) {
  tags$div(style = "display:inline-block; width:105px; height:75px;", x)
}

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
download_button <- function(..., icon = "download", class = "btn-primary") {
  downloadButton(..., icon = icon(icon), class = class)
}

# Waiting Screen ----
waiter_data <- function(msg = "Loading data for selected chemical ...") {
  waiter::Waiter$new(
    html = tagList(
      waiter::spin_flower(),
      h4(msg)
    ),
    color = "rgb(44, 62, 80, 0.9)"
  )
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
      "Accounts for uncertainty due to limited species and trophic coverage",
      "Accounts for uncertainty when missing data on planktonic invertebrates and/or salmonids",
      "Accounts for uncertainty when missing data on planktonic invertebrates and/or salmonids",
      "Accounts for uncertainty of not having representation of B.C. species"
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

# File Names for Downloading ----

file_name_dl <- function(file_name, cas_number, ext) {
  time_stamp <- format(Sys.time(), format = "%F %T", tz = "PST8PDT")
  time_stamp <- stringr::str_replace(time_stamp, " ", "_")
  time_stamp <- stringr::str_replace_all(time_stamp, ":", "-")
  if (is.null(cas_number)) {
    cas_num <- ""
  } else {
    cas_num <- cas_number
  }
  dl_name <- paste(file_name, cas_num, time_stamp, sep = "_")
  dl_name <- paste0(dl_name, ".", ext)
}
