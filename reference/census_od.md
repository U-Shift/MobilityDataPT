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
od_data <- MobilityDataPT::census_od(id = "PT")
#> IndicadorDsg: População residente empregada ou estudante (N.º) por Local de residência à data dos Censos [2021] (NUTS - 2013), Sexo, Condição perante o trabalho e Local de trabalho ou estudo; Decenal - INE, Recenseamento da população e habitação - Censos 2021
#> MetaInfUrl: https://www.ine.pt/bddXplorer/htdocs/minfo.jsp?var_cd=0011702&lingua=PT
#> DataExtracao: 2026-08-06T15:10:10.316+01:00
#> DataUltimoAtualizacao: 2022-11-23
od_data |> dplyr::sample_n(5)
#>   geocod   geodsg dim_3 dim_3_t dim_4   dim_4_t dim_5             dim_5_t
#> 1     PT Portugal     1       H     1 Empregada 41304            Gondomar
#> 2     PT Portugal     T      HM     1 Empregada 41114 Vila Franca de Xira
#> 3     PT Portugal     1       H     2 Estudante 41317   Vila Nova de Gaia
#> 4     PT Portugal     1       H     2 Estudante 41013     Pedrógão Grande
#> 5     PT Portugal     T      HM     1 Empregada 41310             Paredes
#>   ind_string valor Periodo
#> 1      4 671  4671    2021
#> 2     14 220 14220    2021
#> 3      1 606  1606    2011
#> 4         78    78    2011
#> 5      7 728  7728    2011


```
