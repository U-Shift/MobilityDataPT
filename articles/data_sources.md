# Data Sources

This package interfaces with and retrieves data from public APIs and
open data repositories provided by official entities:

- **[Eurostat
  GISCO](https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes)**:
  Spatial boundaries and point locations of postal codes

> [`MobilityDataPT::postal_code_database()`](https://u-shift.github.io/MobilityDataPT/reference/postal_code_database.md)
> [`MobilityDataPT::get_postal_code_coordinates()`](https://u-shift.github.io/MobilityDataPT/reference/get_postal_code_coordinates.md)

- **[Instituto Nacional de Estatística (INE)](https://www.ine.pt/)**:
  Census Origin-Destination (Home-to-Work & Home-to-Study) mobility
  flows

> [`MobilityDataPT::census_od_regions()`](https://u-shift.github.io/MobilityDataPT/reference/census_od_regions.md)
> [`MobilityDataPT::census_od()`](https://u-shift.github.io/MobilityDataPT/reference/census_od.md)

- **[Infraestruturas de
  Portugal](https://portagens.infraestruturasdeportugal.pt/)**: Toll
  calculation services across Portuguese highway networks

> [`MobilityDataPT::tools_for_itinerary()`](https://u-shift.github.io/MobilityDataPT/reference/tools_for_itinerary.md)
