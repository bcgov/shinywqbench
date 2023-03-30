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


This app **generates aquatic life water quality benchmarks**. 
The app is built from the R package [wqbench](https://github.com/bcgov/wqbench), and shares the same functionality.

## How to Use the shinywqbench App

### Step 1: Select Chemical

**Tab 1.1 Data Review**

- Select a chemical by name or with the CAS registry number (without dashes) by using the radio buttons. 
  - To select a chemical start typing the name or CAS number in the input field. If the chemical is present in the data set it will start to auto fill and will show matches to your search. Click the value to select it.
  - Due to the large number of chemicals present, the input field can only display a thousand values at a time. Type the value (name or CAS number) to narrow down the choices.
  - To clear a selection, hit the backspace button in the input field. 
  - If you are unable to find the chemical by name try the CAS number.
- Once a chemical has been selected, hit the Run button.
  - A loading screen may appear telling you the app is processing your request.
  - Chemicals with more data will take longer to load, be patient.
- If the chemical has an approved BC Water Quality Guideline associated with it, a pop up box will appear and provide a link to the [BC Water Quality Guideline Look-up App](https://www2.gov.bc.ca/gov/content/environment/air-land-water/water/water-quality/water-quality-guidelines/approved-water-quality-guidelines).
- If the chemical is not found in the data set, a pop up box will appear and say "The chemical you selected cannot be found in the database."

### Step 2: Edit Data 

**Tab 1.1 Data Review**

The data on Tab 1.1 Review Data can be edited by removing specific rows.

- To remove a row
  - Click on the row (it will turn blue).
  - Click Edit Data.
  - The row will turn red and has been removed.
- To add a row back in
  - Click on a red row which will turn it blue.
  - Click Edit Data.
  - The screen should refresh turn the row back to the original background colour.
- Download the selected data as a csv using the Download button.
  
### Step 3: View Selected Data 

**Tab 1.2 View Plot** 

- The data selected in step 2 can be viewed as a plot of the concentration value for each species.
- Download the plot as png file.

**Tab 1.3 Aggregated Data**

- Shows the data aggregated for each species.
- The data has been aggregated as per the steps in (LINK TO PDF DOC).
- Download the table as csv.

**Performing your own analysis of the data**

- You can download the aggregated data and upload it into [shinyssdtools](https://bcgov.github.io/shinyssdtools/) app if you want to perform your own species sensitivity distribution (SSD) analysis.

### Step 4: Generate Benchmark

**Tab 2.1 Plot & 2.2 Report**
- Go to Tab 2 Benchmark and click Generate Benchmark on the left panel.
- Either an SSD analysis or deterministic method is used to generate the critical toxicity and benchmark value as per the steps in (LINK TO PDF DOC).
- Download the plot as a png on Tab 2.1 Plot
- Download the tables as an excel file on Tab 2.2 Report

**SSD Method**
The SSD method used in the app uses ssdtools `ssd_hc_bcanz()` with 100 bootstrap samples. 
The number of bootstraps cannot be adjusted in the app.
If a user wants to vary the parameters of the SSD then the aggregated data can be downloaded and used in the [shinyssdtools](https://bcgov.github.io/shinyssdtools/) app.

**Deterministic Method**
The deterministic method selects the lowest concentration as the critical toxicity value.
The deterministic method does not produce an upper and lower confidence interval.

### Step 5: Download Summaries

**Tab 3 Summary**

- Download a pdf report of the selected chemical showing the summary tables, 
critical toxicity value, and benchmark value. 
- Download an excel file with all the data tables: data, selected data, aggregated data, critical toxicity value and assessment factors 

### General Info

- Downloaded files have a consistent name where: file-name_cas-number_datetime-stamp 
  - ex:"data-aggregated_60139_2023-03-17_08-47-52.csv"

## Data Definitions

| Column Name | Description | Source |
| ----------- | ----------- | ------ |
| chemical_name | chemical name | ECOTOX |
| cas | chemical registry number | ECOTOX |
| latin_name | species Latin name | ECOTOX |
| common_name | species common name | ECOTOX |
| endpoint | the statistic or hypothesis generated from the test results (e.g. EC10, NOEC)  | ECOTOX |
| effect | a measurable biological change | ECOTOX |
| effect_conc_mg.L | contaminant concentration that corresponds to the endpoint| ECOTOX |
| lifestage | lifestage description | ECOTOX |
| duration_hrs | study duration, standardized to hours | ECOTOX |
| duration_class | Values are classified as acute or chronic based on rules/step 2 | Acute or chronic | ECOTOX |
| effect_conc_std_mg.L | effect concentration standardized to include the acute to chronic ratio to extrapolate acute and/or effect concentrations to chronic and/or no-effect concentrations | Based on Okonski et al. 2021 |
| sp_aggre_conc_mg.L | standardized effect concentration aggregated for each species |  |
| acr | acute to chronic ratio; either 10, 5 or 1 depending on the duration and endpoint reported | Okonski et al. 2021 |
| media_type | Media type of tests | ECOTOX |
| trophic_group | Trophic group of species: fish, amphibian, invertebrate, algae and plant. | |
| ecological_group | Identification of salmonids and planktonic invertebrates.  If neither of these, listed as "other". | B.C. ENV 2009 |
| species_present_in_bc | Species is present in British Columbia if entry = TRUE | B.C. Conservation Data Centre. 2023 |
| author | Author of reference | ECOTOX |
| title | Title of reference | ECOTOX |
| source |   | ECOTOX |
| publication_year | Publication year of reference | ECOTOX |

## Data Process

- list steps in work plan
- link to pdf

## References

B.C. Conservation Data Centre. 2023. BC Species and Ecosystems Explorer. 
B.C. Minist. of Environ. Victoria, B.C. Available: 
https://a100.gov.bc.ca/pub/eswp/ 
(accessed Jan 16, 2023).

Curated toxicity data were retrieved from the ECOTOXicology Knowledgebase, U.S. Environmental Protection Agency. http:/www.epa.gov/ecotox/ (accessed Mar 20, 2023)

Okonski, A.I., MacDonald, D.B., Potter, K., and Bonnell, M. 2021. Deriving predicted no-effect concentrations (PNECs) using a novel assessment factor method. Hum. Ecol. Risk Assess. Int. J. 27(6): 1613–1635. doi:10.1080/10807039.2020.1865788.

- B.C. ENV 2009?
