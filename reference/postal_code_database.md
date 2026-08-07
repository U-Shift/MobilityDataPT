# Access Eurostat GISCO Postal Code database

Downloads and reads the GISCO Postal Codes dataset provided by
[Eurostat](https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes).
Files are cached locally in the directory specified by the
`MOBILITYDATAPT_DOWNLOAD_DIRECTORY` environment variable, defaulting to
`~/.local/share/R/MobilityDataPT`.

## Usage

``` r
postal_code_database(
  cntr_id = "PT",
  year = 2024,
  crs = 4326,
  download_dir = NULL
)
```

## Arguments

- cntr_id:

  Two-letter country code to filter by (default `"PT"`). Pass `NA` or
  `NULL` to return all countries present in the dataset.

- year:

  Release year of the dataset. Allowed values are `2020` or `2024`
  (default `2024`).

- crs:

  Coordinate Reference System (EPSG code) of the dataset. Allowed values
  are `3857`, `3035`, or `4326` (default `4326`).

- download_dir:

  Directory where downloaded GeoPackage files are stored. Defaults to
  the `MOBILITYDATAPT_DOWNLOAD_DIRECTORY` environment variable or
  `~/.local/share/R/MobilityDataPT`.

## Value

An `sf` object containing spatial postal code boundaries/points.
Returned columns include:

- `POSTCODE`: Postal code identifier (e.g. "1000-001")

- `CNTR_ID`: Country identifier (e.g. "PT")

- `LAU_NAME`: Local Administrative Unit name ("freguesia" for Portugal)

- `NUTS3_2024`: NUTS level 3 region code

- `Shape`: Point of postal code location.

## Note

Data source: Eurostat GISCO Postal Codes
(<https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes>).

## Examples

``` r
db <- MobilityDataPT::postal_code_database()

db |> dplyr::select(POSTCODE, LAU_NAME, Shape) |> dplyr::sample_n(5)
#> Simple feature collection with 5 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.351696 ymin: 38.62705 xmax: -8.86759 ymax: 39.10543
#> Geodetic CRS:  WGS 84
#>   POSTCODE
#> 1 2695-725
#> 2 2835-530
#> 3 2050-025
#> 4 2705-906
#> 5 2565-394
#>                                                                    LAU_NAME
#> 1 União das freguesias de Santa Iria de Azoia, São João da Talha e Bobadela
#> 2                                                 Santo António da Charneca
#> 3                                                          Aveiras de Baixo
#> 4                    União das freguesias de São João das Lampas e Terrugem
#> 5                                         Santa Maria, São Pedro e Matacães
#>                        Shape
#> 1 POINT (-9.097305 38.82328)
#> 2 POINT (-9.013116 38.62705)
#> 3  POINT (-8.86759 39.10543)
#> 4  POINT (-9.351696 38.8414)
#> 5 POINT (-9.211773 39.09116)
```
