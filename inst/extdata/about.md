**This app is under development and is being shared for testing purposes only.**

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
