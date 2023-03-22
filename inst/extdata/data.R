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

#download_location <- "~/Ecotoxicology/ecotox"
#wqb_download_epa_ecotox(file_path = download_location, version = 2)

database <- wqb_create_epa_ecotox(
  file_path = "~/Ecotoxicology/ecotox_db/",
  data_path = "~/Ecotoxicology/ecotox/ecotox_ascii_09_15_2022"
)
#database <- "~/Ecotoxicology/ecotox_db//ecotox_ascii_09_15_2022.sqlite"

bc_species <- wqb_add_bc_species(database = database) 
chem_bc_wqg <- wqb_add_bc_wqg(database = database)
conc_endpoints <- wqb_add_concentration_endpoints(database = database)
lifestage_codes <- wqb_add_lifestage(database = database) 
media_groups <- wqb_add_media(database = database)
trophic_groups <- wqb_add_trophic_group(database = database) 
duration_unit_code_standardization <- wqb_add_duration_conversions(database = database)
concentration_unit_code_standardization <- wqb_add_conc_conversions(database = database)

data <- wqb_compile_dataset(database = database) 
data <- wqb_classify_duration(data)
ecotox_data <- wqb_standardize_effect(data)

cname <- ecotox_data |>
  dplyr::select(cas_number = cas, chemical_name, present_in_bc_wqg) |>
  dplyr::distinct()

ecotox_data <- ecotox_data |>
  dplyr::filter(!present_in_bc_wqg) |>
  dplyr::select(-present_in_bc_wqg)

rm(data)

usethis::use_data(
  cname, ecotox_data, internal = TRUE, overwrite = TRUE
)
