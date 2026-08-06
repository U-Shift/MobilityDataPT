# Compute toll costs for an itinerary

Encapsulates the calculation functionality of the web service provided
by [Infraestruturas de
Portugal](https://portagens.infraestruturasdeportugal.pt/). Queries IP
API to calculate expected toll costs across vehicle classes (C1, C2, C3,
C4) for a given spatial itinerary.

## Usage

``` r
tools_for_itinerary(sf_itinerary)
```

## Arguments

- sf_itinerary:

  An `sf` object containing route geometry (`LINESTRING` coordinates).

## Value

A named list containing toll costs in Euros for each vehicle class
(`C1`, `C2`, `C3`, `C4`).

## Note

Data source: Infraestruturas de Portugal
(<https://portagens.infraestruturasdeportugal.pt/>). Terms of service
apply.

## Examples

``` r
sf_itinerary <- sf::st_read(system.file("extdata/samples",
    "tool_itinerary_25AbrilBridge.gpkg",
    package = "MobilityDataPT"
), quiet = TRUE)

MobilityDataPT::tools_for_itinerary(sf_itinerary)
#> $C1
#> [1] 2.25
#> 
#> $C2
#> [1] 4.85
#> 
#> $C3
#> [1] 6.55
#> 
#> $C4
#> [1] 8.45
#> 
```
