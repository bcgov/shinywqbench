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

add_external_resources <- function() {
  addResourcePath("www", system.file("app/www", package = "shinywqbench"))
  tagList(tags$link(rel = "stylesheet", type = "text/css", href = "www/bcgov.css"))
}

css_styling <- function() {
  css_text <-
    "
    .nowrap {
      white-space: nowrap;
    }

    .about-table table :is(td, th) {
      border: 1px solid black;
      padding: 0.3em;
      padding-right: 1em;
    }
  
    .container-fluid {
      margin-top: 10px;
    }
  
    .navbar-nav {
      float: right;
      margin-bottom: 0;
      margin-right: 20px !important;
    }
  
  "
  tags$style(css_text, type = "text/css")
}
