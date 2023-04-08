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

# run the test first
rsconnect::deployApp(
  appDir = ".", 
  account = "bcgov-env", 
  appName = "shinywqbench-dev", 
  forceUpdate = TRUE
)

# live site
rsconnect::deployApp(
  appDir = ".", 
  account = "bcgov-env",
  appName = "shinywqbench", 
  forceUpdate = TRUE
)

if (FALSE) {
  rsconnect::deployApp(
    appDir = ".",
    account = "poissonconsulting",
    appName = "shinywqbench",
    forceUpdate = TRUE
  )
}
