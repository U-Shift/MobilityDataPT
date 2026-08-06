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
#> DataExtracao: 2026-08-06T15:11:32.376+01:00
#> DataUltimoAtualizacao: 2022-11-23
head(regions)
#>       id              name
#> 1     PT          Portugal
#> 2      1        Continente
#> 3     11             Norte
#> 4    111        Alto Minho
#> 5   1601 Arcos de Valdevez
#> 6 160101  Aboim das Choças

# Fetch OD mobility records for a specific region ID (e.g., "PT" or "0603")
od_data <- MobilityDataPT::census_od(id = "PT")
#> IndicadorDsg: População residente empregada ou estudante (N.º) por Local de residência à data dos Censos [2021] (NUTS - 2013), Sexo, Condição perante o trabalho e Local de trabalho ou estudo; Decenal - INE, Recenseamento da população e habitação - Censos 2021
#> MetaInfUrl: https://www.ine.pt/bddXplorer/htdocs/minfo.jsp?var_cd=0011702&lingua=PT
#> DataExtracao: 2026-08-06T15:11:34.218+01:00
#> DataUltimoAtualizacao: 2022-11-23
head(od_data)
#>   geocod   geodsg dim_3 dim_3_t dim_4   dim_4_t dim_5                  dim_5_t
#> 1     PT Portugal     2       M     2 Estudante 40511      Vila Velha de Ródão
#> 2     PT Portugal     2       M     2 Estudante 44401   Santa Cruz da Graciosa
#> 3     PT Portugal     T      HM     2 Estudante 44401   Santa Cruz da Graciosa
#> 4     PT Portugal     1       H     2 Estudante 40404 Freixo de Espada à Cinta
#> 5     PT Portugal     1       H     2 Estudante 40412                  Vinhais
#> 6     PT Portugal     1       H     2 Estudante 44202                 Nordeste
#>   ind_string valor Periodo
#> 1          1     1    2011
#> 2          1     1    2011
#> 3          1     1    2011
#> 4          2     2    2011
#> 5          2     2    2011
#> 6          2     2    2011
```

### 3. Road & Itinerary Toll Costs

Calculate expected toll costs across vehicle classes (C1, C2, C3, C4)
for spatial route itineraries using the Infraestruturas de Portugal API
service:

``` r

sf_itinerary <- sf::st_read(system.file("extdata/samples",
  "tool_itinerary_25AbrilBridge.gpkg", package = "MobilityDataPT"
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
