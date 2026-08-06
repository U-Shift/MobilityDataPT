# Get Postal Code coordinates

Retrieves spatial coordinates and geometry for specific postal code(s)
from the Eurostat GISCO postal code database.

## Usage

``` r
get_postal_code_coordinates(
  postal_codes = NULL,
  cntr_id = "PT",
  year = 2024,
  crs = 4326,
  download_dir = NULL
)
```

## Arguments

- postal_codes:

  Character vector of postal code identifiers (e.g., `"1000-001"` or
  `c("1000-001", "2800-001")`). If `NULL`, returns coordinates for all
  postal codes in the dataset.

- cntr_id:

  Two-letter country code to filter by (default `"PT"`). Pass `NA` or
  `NULL` to return all countries.

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

An `sf` object containing matching postal code records and geometries.

## Note

Data source: Eurostat GISCO Postal Codes
(<https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes>).

## See also

[`MobilityDataPT::postal_code_database()`](https://u-shift.github.io/MobilityDataPT/reference/postal_code_database.md)

## Examples

``` r
MobilityDataPT::get_postal_code_coordinates(c("1000-001", "2800-001"))
#> Downloading postal code database from https://gisco-services.ec.europa.eu/distribution/v2/pcode/gpkg/PCODE_PT_2024_4326.gpkg to /home/runner/.local/share/R/MobilityDataPT/PCODE_PT_2024_4326.gpkg
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.160344 ymin: 38.68097 xmax: -9.13881 ymax: 38.73317
#> Geodetic CRS:  WGS 84
#>        POSTCODE                      Shape
#> 663558 2800-001 POINT (-9.160344 38.68097)
#> 675430 1000-001  POINT (-9.13881 38.73317)
```
