# Fetch Census Origin-Destination available regions

Queries the INE metadata API for the available regional filtering
options available for
[`MobilityDataPT::census_od()`](https://u-shift.github.io/MobilityDataPT/reference/census_od.md).

## Usage

``` r
census_od_regions()
```

## Value

A `data.frame` with columns `id` and `name`.

## Note

Data source: Instituto Nacional de Estatística (INE)
(<https://www.ine.pt/>).

## See also

[`MobilityDataPT::census_od()`](https://u-shift.github.io/MobilityDataPT/reference/census_od.md)

## Examples

``` r
regions <- MobilityDataPT::census_od_regions()
#> DataExtracao: 2026-08-07T11:52:54.776+01:00
#> DataUltimoAtualizacao: 2022-11-23
head(regions)
#>       id              name
#> 1     PT          Portugal
#> 2      1        Continente
#> 3     11             Norte
#> 4    111        Alto Minho
#> 5   1601 Arcos de Valdevez
#> 6 160101  Aboim das Choças
```
