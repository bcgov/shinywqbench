
# shinywqbench

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

This package is a shiny app that makes using the functions of the
`wqbench` package accessible to non-R users.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("bcgov/shinywqbench")
```

## How to launch app locally:

``` r
library(shinywqbench)
run_wqbench_app()
```

## How to Update the Data Set

If the ECOTOX database has been updated, you first need to update the
reference data in the [wqbench](https://github.com/bcgov/wqbench)
package. Follow the [Developer
Instructions](https://github.com/bcgov/wqbench/vignettes/Developer-instructions.md)
in the wqbench repository.

Next, in this repository: 1. Go to the *inst/extdata/data.R* file. 2.
Run the script.

## How to Deploy the App to the web

Before deploying the app, run it locally to ensure that the changes to
wqbench, and the internal dataset in the app, are functional:

``` r
library(shinywqbench)
run_wqbench_app()
```

1.  Go to the *scripts/deploy.R* file.
2.  Run the script.

It is advised to first run the code that deploys the app name of
`shinywqbench-dev` and confirm the app deploys and functions as
expected. This app is referred to as the development app.

Once it has been confirmed that the app functions and deploys properly
to then run the second chunk of code with the app name `shinywqbench`.
This app is referred to as the production app.

This will help to ensure the production app is always in a working
state.

## Getting Help or Reporting an Issue

To report issues, bugs or enhancements, please file an
[issue](https://github.com/bcgov/wqbench/issues). Check out the
[support](https://github.com/bcgov/wqbench/blob/main/.github/SUPPORT.md)
for more info.

## Code of Conduct

Please note that the shinywqbench project is released with a
[Contributor Code of
Conduct](https://github.com/bcgov/shinywqbench/CODE_OF_CONDUCT.md). By
contributing to this project, you agree to abide by its terms.

## License

The code is released under the Apache License 2.0

> Copyright 2023 Province of British Columbia
>
> Licensed under the Apache License, Version 2.0 (the “License”); you
> may not use this file except in compliance with the License. You may
> obtain a copy of the License at
>
> <https://www.apache.org/licenses/LICENSE-2.0>
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an “AS IS” BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
> implied. See the License for the specific language governing
> permissions and limitations under the License.
