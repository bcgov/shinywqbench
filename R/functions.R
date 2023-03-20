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
      columnDefs = list(
        list(
          className = "dt-center",
          targets = "_all"
        )
      )
    )
  )
}

data_table_raw <- function(data) {
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
      scrollY = TRUE,
      columnDefs = list(
        list(className = "nowrap", targets = "_all"),
        list(
          visible = FALSE,
          targets = c(
            "chemical_name", "cas", "species_number", "remove_row"
          )
        )
      )
    )
  )
}

data_table_agg <- function(data) {
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
        visible = FALSE,
        targets = c(
          "chemical_name", "cas", "species_number"
        )
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

# Filter Col Names ----

filter_data_raw_dl <- function(data) {
  data <- 
    data |>
    dplyr::select(
      "chemical_name", "cas",
      "latin_name", "common_name", "endpoint", "effect", "effect_conc_mg.L",
      "lifestage", "duration_hrs", "duration_class", "effect_conc_std_mg.L",
      "ACR", "media_type", "trophic_group", "ecological_group",
      "species_present_in_bc",
      "author", "title", "source", "publication_year"
    )
  data
}

filter_data_agg_dl <- function(data) {
  data <- 
    data |>
    dplyr::select(
      "chemical_name", "cas",
      "latin_name", "common_name", "effect", "conc1_mean_std_effect_aggr_mg.L",
      "trophic_group", "ecological_group",
      "species_present_in_bc",
      "method"
    )
  data
}

