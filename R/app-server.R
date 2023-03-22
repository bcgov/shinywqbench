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

app_server <- function(input, output, session) {
  
  data_output <- mod_data_server(
    "mod_data_ui"
  )
  
  bench_output <- mod_bench_server(
    "mod_bench_ui",
    data_output
  )

  mod_summary_server(
    "mod_summary_ui",
    data_output,
    bench_output
  )

  mod_about_server(
    "mod_about_ui"
  )
  
  mod_user_server(
    "mod_user_ui"
  )
}