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

This app calculates aquatic life benchmarks for use when interpreting monitoring results when no water quality guidelines is available.  The app requires the user to first screen the data and then follow the necessary steps to calculate a benchmark.  

The app automatically completes the following steps:

- Step 1: Data is pulled from the US EPA EcoTox database and a number of data cleaning and standardization steps are conducted.
- Step 2: Tests are classified as either acute or chronic following the guidance of CCME 2007.
- Step 3: Endpoints that are acute and/or effect endpoints are standardized to chronic and no-effect endpoints using acute to chronic values proposed by Okonski et al. 2021.
- Step 4: The benchmark derivation method (either SSD or deterministic) is determined depending upon the number of species represented for the selected chemical.
- Step 5: Data are aggregated and the most sensitive endpoint for the most sensitive life stage is selected for each species.
- Step 6: Assessment factors are applied to account for uncertainty related to the number of species, representation of ecologically important groups and representation of B.C. species.

A full description of the steps can be found in the accompanying word document, “An overview of the aquatic life water quality benchmark generator” which will eventually be published.

Please do not cite this app at this point.

The code is released under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
