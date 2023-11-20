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

app_ui <- function() {
  tagList(
    tags$head(tags$title("shinywqbench")),
    css_styling(),
    add_external_resources(),
    shinyjs::useShinyjs(),
    waiter::useWaiter(),
    navbarPage(
      title = "Emergent Contaminant Aquatic Life Benchmarks - DRAFT",
      selected = "tab1",
      id = "navbarID",
      tabPanel(
        value = "tab1",
        title = "1. Data",
        icon = shiny::icon("table"),
        mod_data_ui("mod_data_ui")
      ),
      tabPanel(
        value = "tab2",
        title = "2. Benchmark",
        icon = shiny::icon("chart-simple"),
        mod_bench_ui("mod_bench_ui")
      ),
      tabPanel(
        value = "tab3",
        title = "3. Summary",
        icon = shiny::icon("file-contract"),
        mod_summary_ui("mod_summary_ui")
      ),
      tabPanel(
        value = "tab4",
        title = "About",
        mod_about_ui("mod_about_ui")
      ),
      tabPanel(
        value = "tab5",
        title = "User Guide",
        mod_user_ui("mod_user_ui")
      )
    ),
    div(
      class = "footer",
      includeHTML("www/footer.html")
    )
  )
}
