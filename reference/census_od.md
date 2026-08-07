# Fetch Census Origin-Destination Data

Retrieves Census Origin-Destination (Home/Work & Study) data from INE
for a given home location.

## Usage

``` r
census_od(id = "PT")
```

## Arguments

- id:

  Region category filter ID (default `"PT"`). See
  [`MobilityDataPT::census_od_regions()`](https://u-shift.github.io/MobilityDataPT/reference/census_od_regions.md)
  for available IDs.

## Value

A `data.frame` containing the aggregated Census OD records with columns:

- `geocod`: Home location code

- `geodsg`: Home location designation

- `dim_3`: Sex category code

- `dim_3_t`: Sex category designation (H, M, HM)

- `dim_4`: Employment status code

- `dim_4_t`: Employment status designation (Empregada, Estudante, Total)

- `dim_5`: Working location code

- `dim_5_t`: Working location designation

- `ind_string`: Count / resident population value in string format

- `valor`: Count / resident population value in numeric format

- `Periodo`: Reference period (2011, 2021)

## Details

Refer to [INE website](https://tabulador.ine.pt/indicador/?id=0011702)
to access the indicator online.

## Note

Data source: Instituto Nacional de Estatística (INE)
(<https://www.ine.pt/>).

## See also

[`MobilityDataPT::census_od_regions()`](https://u-shift.github.io/MobilityDataPT/reference/census_od_regions.md)

## Examples

``` r
if (FALSE) { # tryCatch({     con <- suppressWarnings(socketConnection("www.ine.pt", port = 443, timeout = 10))     close(con)     TRUE }, error = function(e) FALSE)
od_data <- MobilityDataPT::census_od(id = "PT")
od_data |> dplyr::sample_n(5)



}
```
