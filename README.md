# MobilityDataPT 

<!-- badges: start -->
[![](https://github.com/U-Shift/MobilityDataPT/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/U-Shift/MobilityDataPT/actions/workflows/R-CMD-check.yaml) [![codecov](https://codecov.io/gh/U-Shift/MobilityDataPT/graph/badge.svg?token=RWVWEGGOF8)](https://codecov.io/gh/U-Shift/MobilityDataPT)
<!-- badges: end -->

**MobilityDataPT** package provides a collection of methods to get and mobility related data for Portugal.

## Installation

You can install the development version of **MobilityDataPT** from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("U-Shift/MobilityDataPT")
```

## Load the package

``` r
library(MobilityDataPT)
```

## Get started

For more details on the package and how to get started, please visit the [Get started](https://u-shift.github.io/MobilityDataPT/articles/MobilityDataPT.html) page.

## Data Sources

This package interfaces with and retrieves data from public APIs and open data repositories provided by official entities:


- **[Eurostat GISCO](https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes)**: Spatial boundaries and point locations of postal codes

> `MobilityDataPT::postal_code_database()`
> `MobilityDataPT::get_postal_code_coordinates()`

- **[Instituto Nacional de Estatística (INE)](https://www.ine.pt/)**: 2021 Census Origin-Destination (Home-to-Work & Home-to-Study) mobility flows

> `MobilityDataPT::census_od_regions()`
> `MobilityDataPT::census_od()`

- **[Infraestruturas de Portugal](https://portagens.infraestruturasdeportugal.pt/)**: Toll calculation services across Portuguese highway networks

> `MobilityDataPT::tools_for_itinerary()`



## Acknowledgement

**MobilityDataPT** is developed and maintained by
[U-Shift](https://ushift.tecnico.ulisboa.pt) urban mobility research
group, part of [CERIS](https://ceris.pt/) research unit, at [Instituto
Superior Técnico](https://tecnico.ulisboa.pt/pt/), Lisbon, Portugal.

<br/>

<img src="man/figures/logo_acknowledgement.png" width="75%">

