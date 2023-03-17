This app **generates aquatic life water quality benchmarks**. 
The app is built from the R package [wqbench](https://github.com/bcgov/wqbench), and shares the same functionality.

## How to Use the shinywqbench App

### Step 1: Select Chemical

**Tab 1.1 Data Review**

- Select a chemical either by name or with the CAS registry number (without dashes) by using the radio buttons. 
  - To select a chemical start typing the name or CAS number in the input field and if the chemical is present in the data set it will start to auto fill and show matches to your search. Click the value to select it.
  - Due to the large number of chemicals present, the input field can only display a thousand values at a time. Type the value (name or CAS number) to narrow down the choices.
  - To clear a selection, hit the backspace button in the input field. 
- Once a chemical has been selected, hit the Run
- A loading screen will appear telling you the app is processing your request


- If the chemical already has an approved BC Water Quality Guideline associated with it, a pop up box will appear and provide a link to the BC Water Quality Guideline Lookup App
- If the chemical is present in the data set, a pop up box will appear and advise you to pick a different chemical to continue.


### Step 2: Edit Data 

**Tab 1.1 Data Review**

The data in the table on Tab 1.1 Review Data can be edited by removing specific rows.

- To remove a row
  - click on the row (it will turn blue)
  - click Edit Data 
  - the row will turn red and has been removed. Check the View Plot tab to confirm yourself. 
- To add a row back in
  - click on a red row which will turn it blue
  - click Edit Data
  - the screen should refresh turn the row back to the original background colour 
- Download selected data as a csv using the Download button
  
### Step 3: View Selected Data 

**Tab 1.2 View Plot & 1.3 Aggregated Data**

The data selected in step 2 can be viewed as a plot of the concentration value for each species

- Download the plot as png file


Tab 1.4 Aggregate Data 

- shows the data aggregated for each species
- insert rules for Step 5 
- Download the table as csv 
  
### Step 4: Generate Benchmark

**Tab 2.1 Plot & 2.2 Report**
- Go Tab 2 Benchmark and click Generate Benchmark on the left panel.
- Either an species sensitivity distribution (SSD) or deterministic method is used to generate the benchmark value depending on the number of trophic groups and species present in the data set. 
- Download the plot as a png on Tab 2.1 Plot
- Download a summary report on Tab 2.2 Report

### Step 5: Download Summaries

**Tab 3 Summary**

- Download a pdf report of the select chemical, benchmark and assessment factors. 
- Download an excel table with all the data tables: data, selected data, aggregated data, benchmark values and assessment factors 

## Data Definitions

| Column Name | Description |
| ----------- | ----------- |
| chemical_name | chemical name (from ECOTOX) |
| cas | chemical registry number (from ECOTOX) |
| latin_name | species latin name (from ECOTOX) |
| common_name | species common name (from ECOTOX) |
| endpoint | endpoint (from ECOTOX) |
| effect | effect description (from ECOTOX) |
| effect_conc_mg.L ||
| lifestage | lifestage description (from ECOTOX) |
| duration_hrs | |
| duration_class | Values are classified as acute or chronic based on rules/step 2 |
| effect_conc_std_mg.L ||
| ACR ||
| media_type | Media type of tests (from ECOTOX) |
| trophic_group | Grouping of species into fish, amphibian, invertebrate, algae and plant. |
| ecological_group | Grouping of species into salmonid, plankoc invertebrates and other. |
| species_present_in_bc | Column added to indicate if the species is present in British Columbia or not. Value is TRUE if the species has been found in British Columbia. |
| author | Author of reference (from ECOTOX) |
| title | Title of reference (from ECOTOX) |
| source |   |
| publication_year | Publication year of reference (from ECOTOX) |

## Data Process

- list steps in workplan?

## Reference

- Ecotox version




