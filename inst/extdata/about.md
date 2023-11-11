<!---
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
-->

The purpose of this app is to allow the user to calculate aquatic life benchmarks for emergent contaminants when no water quality guidelines are available.
Although these benchmarks follow methods similar to those outlined in the [BC WQG derivation protocol](https://www2.gov.bc.ca/assets/gov/environment/air-land-water/water/waterquality/water-quality-guidelines/derivation-protocol/bc_wqg_aquatic_life_derivation_protocol.pdf), many steps have been omitted including data quality screening and expert review and therefore these benchmarks are not equivalent to water quality guidelines.
Rather the purpose of the benchmarks is to support the assessment of monitoring data and the potential for a chemical to impact the aquatic environment.

If you have any feedback or comments on this app, please email them to Angeline.Tillmanns@gov.bc.ca  For further information on this app, please see the draft overview: 
Tillmanns, A.R. and Pearson, A.  2023.  DRAFT wqbench: A Tool for Calculating Emergent Contaminant Aquatic Life Benchmarks.  Ministry of Water, Land and Resource Stewardship. Province of British Columbia, Victoria.
 

 

The app automatically completes the following steps:

- Step 1: Data is pulled from the US EPA EcoTox database and a number of data cleaning and standardization steps are conducted.
- Step 2: Tests are classified as either acute or chronic following the guidance of CCME 2007.
- Step 3: Endpoints that are acute and/or effect endpoints are standardized to chronic and no-effect endpoints using acute to chronic values proposed by Okonski et al. 2021.
- Step 4: The benchmark derivation method (either SSD or deterministic) is determined depending upon the number of species represented for the selected chemical.
- Step 5: Data are aggregated and the most sensitive endpoint for the most sensitive life stage is selected for each species.
- Step 6: Assessment factors are applied to account for uncertainty related to the number of species, representation of ecologically important groups and representation of B.C. species.

A full description of the steps can be found in the accompanying document, "[An overview of the aquatic life water quality benchmark generator](https://www2.gov.bc.ca/assets/gov/environment/air-land-water/water/waterquality/water-quality-guidelines/approved-wqgs/benchmarks_for_emerging_contaminants_overview_draft_august_2023.pdf)" which will eventually be published.

Please do not cite this app at this point.

The code is released under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
