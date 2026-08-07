# Get Started

## Installation

You can install the development version of `MobilityDataPT` from GitHub
with:

``` r

# install.packages("remotes")
remotes::install_github("U-Shift/MobilityDataPT")
```

## Load the package

``` r

library(MobilityDataPT)
```

## Key functions

### 1. Administrative Boundaries & Postal Codes

Access Eurostat GISCO postal code datasets and spatial coordinates for
Portugal or other EU countries:

``` r

# Download and access full postal code database for Portugal
db <- MobilityDataPT::postal_code_database(cntr_id = "PT", year = 2024, crs = 4326)
db |>
  dplyr::select(POSTCODE, LAU_NAME, Shape) |>
  dplyr::sample_n(5)
#> Simple feature collection with 5 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.097305 ymin: 38.62705 xmax: -8.624415 ymax: 41.70859
#> Geodetic CRS:  WGS 84
#>   POSTCODE
#> 1 3800-376
#> 2 4900-861
#> 3 4450-770
#> 4 2695-725
#> 5 2835-530
#>                                                                              LAU_NAME
#> 1                                                                            Esgueira
#> 2 União das freguesias de Viana do Castelo (Santa Maria Maior e Monserrate) e Meadela
#> 3                               União das freguesias de Matosinhos e Leça da Palmeira
#> 4           União das freguesias de Santa Iria de Azoia, São João da Talha e Bobadela
#> 5                                                           Santo António da Charneca
#>                        Shape
#> 1 POINT (-8.624415 40.66091)
#> 2 POINT (-8.807337 41.70859)
#> 3 POINT (-8.701731 41.19593)
#> 4 POINT (-9.097305 38.82328)
#> 5 POINT (-9.013116 38.62705)

# Get spatial coordinates for specific postal codes
coords <- MobilityDataPT::get_postal_code_coordinates(c("1000-001", "2800-001"))
coords
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.160344 ymin: 38.68097 xmax: -9.13881 ymax: 38.73317
#> Geodetic CRS:  WGS 84
#>        POSTCODE                      Shape
#> 663558 2800-001 POINT (-9.160344 38.68097)
#> 675430 1000-001  POINT (-9.13881 38.73317)
```

### 2. Census Origin-Destination (OD) Data

Retrieve INE Census 2021 Origin-Destination data for home-to-work and
home-to-study mobility flows:

``` r

# Fetch available region filtering options
regions <- MobilityDataPT::census_od_regions()
head(regions)

# Fetch OD mobility records for a specific region ID (e.g., "PT" or "0603")
od_data <- MobilityDataPT::census_od(id = "PT")
head(od_data)
```

### 3. Road & Itinerary Toll Costs

Calculate expected toll costs across vehicle classes (C1, C2, C3, C4)
for spatial route itineraries using the Infraestruturas de Portugal API
service:

``` r

sf_itinerary <- sf::st_read(system.file("extdata/samples",
  "tool_itinerary_25AbrilBridge.gpkg",
  package = "MobilityDataPT"
), quiet = TRUE)

# Calculate toll costs
tolls <- MobilityDataPT::tools_for_itinerary(sf_itinerary)
tolls
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
```
