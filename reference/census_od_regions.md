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
if (FALSE) { # tryCatch({     con <- suppressWarnings(socketConnection("www.ine.pt", port = 443, timeout = 10))     close(con)     TRUE }, error = function(e) FALSE)
regions <- MobilityDataPT::census_od_regions()
head(regions)
}
```
