# UI ---- 
text_output <- function(...) {
  textOutput(...)
}


table_output <- function(...) {
  wellPanel(DT::DTOutput(...), style = "font-size:87%", class = "wellpanel")
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

# SSD Calculations ----

prepare_for_ssd <- function(data) {
  data <- data |>
    dplyr::ungroup() |>
    dplyr::select(
      "Chemical" = "cname", "Species" = "tax_taxon", "Conc" = "concentration",
      "Group" = "ecotox_grp", "Units" = "concentration_unit"
    )
  data
}

ssd_distributions_fit <- function(data) {
  fit <- ssdtools::ssd_fit_dists(data)
  fit
}

ssd_distributions_plot <- function(fit) {
  gp <- ssdtools::autoplot(fit) +
    ssdtools::scale_color_ssd()
  gp
}

ssd_distributions_table <- function(fit) {
  tbl <- ssdtools::ssd_gof(fit)
  tbl
}

ssd_hc5_table_generator <- function(fit, nboot = 100) {
  hc5 <- ssdtools::ssd_hc(fit, ci = TRUE, nboot = nboot)
  hc5
}

ssd_hc5_plot_predictions <- function(data, fit) {
  predictions <- stats::predict(fit, ci = TRUE)
  gp <- ssdtools::ssd_plot(data, predictions,
                           color = "Group",
                           label = "Species",
                           xlab = "Concentration (mg/L)",
                           ribbon = TRUE
  ) +
    ggplot2::expand_limits(x = 3000) +
    ssdtools::scale_colour_ssd()
  gp
}

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


