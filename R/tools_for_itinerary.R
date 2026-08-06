#' Compute toll costs for an itinerary
#'
#' Encapsulates the calculation functionality of the web service provided by
#' \href{https://portagens.infraestruturasdeportugal.pt/}{Infraestruturas de Portugal}.
#' Queries their API to calculate expected toll costs across vehicle classes (C1, C2, C3, C4)
#' for a given spatial itinerary.
#'
#' @note Terms of service and usage rights of the Infraestruturas de Portugal web service apply.
#'
#' @param sf_itinerary An \code{sf} object containing route geometry (\code{LINESTRING} coordinates).
#'
#' @return A named list containing toll costs in Euros for each vehicle class (\code{C1}, \code{C2}, \code{C3}, \code{C4}).
#' @examples
#' sf_itinerary <- sf::st_read(system.file("extdata/samples",
#'     "tool_itinerary_25AbrilBridge.gpkg",
#'     package = "MobilityDataPT"
#' ), quiet = TRUE)
#'
#' MobilityDataPT::tools_for_itinerary(sf_itinerary)
#'
#' @importFrom sf st_coordinates st_geometry
#' @importFrom dplyr select
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom httr POST content add_headers
#' @export

tools_for_itinerary <- function(sf_itinerary) {
    # Create string with aray of arrays for geometry: [[x1, y1], [x2, y2], ...]]
    geometry_array <- sf::st_geometry(sf_itinerary)[[1]] |>
        sf::st_coordinates() |>
        as.data.frame() |>
        dplyr::select("X", "Y") |>
        as.matrix() |>
        jsonlite::toJSON(auto_unBOX = FALSE)

    # Make POST request to https://portagens.infraestruturasdeportugal.pt/Portagens.asmx/ObterCustoPortagens, with the following attributes
    # JSON body: {"coordenadas": [[x1, y1], [x2, y2], ...]]}
    # Headers: Referer: https://portagens.infraestruturasdeportugal.pt/
    response <- httr::POST(
        url = "https://portagens.infraestruturasdeportugal.pt/Portagens.asmx/ObterCustoPortagens",
        body = list(coordenadas = geometry_array),
        encode = "json",
        httr::add_headers(Referer = "https://portagens.infraestruturasdeportugal.pt/")
    )
    # Example response: {"d":[2.25,4.85,6.55,8.45]}
    costs <- jsonlite::fromJSON(httr::content(response, "text"))

    # Convert to named list with elements: C1, C2, C3 and C4
    costs_list <- as.list(stats::setNames(as.numeric(costs$d), c("C1", "C2", "C3", "C4")))
    return(costs_list)
}

