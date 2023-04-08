
# shinywqbench

<!-- badges: start -->

[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
<!-- badges: end -->

This package is a shiny app that makes using the functions of the
`wqbench` package accessible to non-R users.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("bcgov/shinywqbench")
```

## How to launch app:

``` r
library(shinywqbench)
run_wqbench_app()
```

## How to Update the Data Set

1.  Go to the *inst/extdata/data.R* file.
2.  Run the script.

## How to Deploy the App

1.  Go to the *scripts/deploy.R* file.
2.  Run the script.

## Getting Help or Reporting an Issue

To report issues, bugs or enhancements, please file an
[issue](https://github.com/bcgov/wqbench/issues). Check out the
[support](https://github.com/bcgov/wqbench/blob/main/.github/SUPPORT.md)
for more info.

## Code of Conduct

Please note that the shinywqbench project is released with a
[Contributor Code of
Conduct](https://github.com/bcgov/wqbench/CODE_OF_CONDUCT.md). By
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
