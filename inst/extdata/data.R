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

library(wqbench)

data_set <- wqb_create_data_set(
  file_path = "~/Ecotoxicology/ecotox", 
  version = 1, 
  folder_path = "~/Ecotoxicology/ecotox_db/"
)

cname <- data_set |>
  dplyr::select(cas_number = cas, chemical_name, present_in_bc_wqg) |>
  dplyr::distinct()

ecotox_data <- data_set |>
  dplyr::filter(!present_in_bc_wqg) |>
  dplyr::select(-present_in_bc_wqg)

rm(data_set)

usethis::use_data(
  cname, ecotox_data, internal = TRUE, overwrite = TRUE
)
