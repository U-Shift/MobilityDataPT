#' Estimate regulated taxi fare in Portugal for an itinerary
#'
#' Encapsulates the tariff calculation web service provided by the
#' \href{https://fptaxi.pt/simulador-fptaxi/}{Federação Portuguesa do Táxi (FPTaxi)} simulator,
#' calculating regulated taxi fares under Portuguese regulations.
#'
#' @details
#' \bold{Routing & traffic considerations:}
#'
#' Regulated taxi fares in Portugal comprise both a distance component and a time component (applicable when
#' the vehicle moves below the changeover speed or is stopped in traffic).
#'
#' To compute an itinerary's distance and duration, users can rely on open-source routing engines,
#' such as OpenRouteService (via the \code{openrouteservice} R package) or OSRM
#' (via the \code{osrm} R package).
#'
#' Mind that free-flow or static open-source routing profiles do not
#' account for traffic congestion or rush-hour speed decays. Because regulated taxi meters charge
#' by time during delays, using free-flow durations (\code{duration_sec}) can significantly underestimate
#' final fares during peak hours. For high-accuracy estimates, especially in congested urban areas,
#' consider obtaining travel durations from routing services that incorporate real-time or historical
#' traffic profiles (such as TomTom, Google Maps, or HERE).
#'
#' \bold{Highway tolls:}
#'
#' Highway toll costs are not automatically included. If your itinerary involves toll roads,
#' you can calculate Class 1 (\code{C1}) toll amounts using \code{\link{tools_for_itinerary}}
#' and supply the result to the \code{cost_tolls} parameter.
#'
#' @note Data source: Federação Portuguesa do Táxi (\url{https://fptaxi.pt/simulador-fptaxi/}).
#'   Terms of service apply. While the web interface presents detailed breakdown metrics based
#'   on proposed tariffs (Proposta FPT/ANTRAL), this function exclusively computes and returns
#'   the legally binding fare established under AMT regulations (\code{total_amt}).
#'
#' @param distance_km Numeric or \code{sf} object. Route distance in kilometers. If an \code{sf}
#'   or \code{sfc} object is provided, distance is computed automatically using \code{sf::st_length()}.
#' @param duration_sec Numeric. Estimated route travel time in seconds. Defaults to `0`.
#'   Note that omitting duration will calculate fare assuming no congestion or waiting time.
#' @param departure POSIXct or character string (`"YYYY-MM-DDTHH:MM"`) with departure date and time.
#'   Defaults to `Sys.time()`. Note that departure time determines tariff multipliers
#'   (\code{f_ajuste}) for night, weekend, and holiday periods.
#' @param tariff Character. Vehicle tariff class: `"t1"` (up to 4 passengers, default),
#'   `"t2"` (>4 passengers), or `"td"` (unmarked vehicle).
#' @param booking Logical. Whether to include the booking/dispatch supplement (`0.80` EUR). Default is `TRUE`.
#' @param luggage Numeric. Luggage supplement in EUR. Default is `0`.
#' @param cost_tolls Numeric. Toll costs in EUR (e.g. obtained via \code{\link{tools_for_itinerary}}). Default is `0`.
#'
#' @return A \code{data.frame} (or \code{sf} object if an \code{sf} object was passed to \code{distance_km})
#'   containing:
#'   \itemize{
#'     \item \code{distance_km}: Route distance in kilometers.
#'     \item \code{duration_sec}: Travel time in seconds.
#'     \item \code{total_amt}: Estimated regulated taxi fare under current AMT regulation in Euros.
#'   }
#'
#' @examples
#' \donttest{
#' # Calculate fare for a 15 km trip taking 25 minutes (1500 seconds)
#' res <- MobilityDataPT::taxi_fare_for_itinerary(
#'     distance_km  = 15,
#'     duration_sec = 1500,
#'     departure    = Sys.time() + 3600,
#'     tariff       = "t1",
#'     booking      = TRUE,
#'     cost_tolls   = 0
#' )
#' print(res)
#' }
#'
#' @seealso \code{\link{tools_for_itinerary}}
#' @importFrom sf st_sf st_length st_geometry
#' @importFrom jsonlite fromJSON
#' @importFrom httr POST content add_headers stop_for_status
#' @export
taxi_fare_for_itinerary <- function(distance_km,
                                    duration_sec = 0,
                                    departure = Sys.time(),
                                    tariff = c("t1", "t2", "td"),
                                    booking = TRUE,
                                    luggage = 0,
                                    cost_tolls = 0) {
    tariff <- match.arg(tariff)

    route_geom <- NULL
    if (inherits(distance_km, "sf") || inherits(distance_km, "sfc")) {
        route_geom <- sf::st_geometry(distance_km)
        distance_km <- as.numeric(sum(sf::st_length(distance_km))) / 1000
    }

    if (!is.numeric(distance_km) || length(distance_km) != 1 || is.na(distance_km) || distance_km < 0) {
        stop("`distance_km` must be a non-negative numeric value.")
    }

    if (!is.numeric(duration_sec) || length(duration_sec) != 1 || is.na(duration_sec) || duration_sec < 0) {
        stop("`duration_sec` must be a non-negative numeric value.")
    }

    if (!is.numeric(luggage) || length(luggage) != 1 || is.na(luggage) || luggage < 0) {
        stop("`luggage` must be a non-negative numeric value.")
    }

    if (!is.numeric(cost_tolls) || length(cost_tolls) != 1 || is.na(cost_tolls) || cost_tolls < 0) {
        stop("`cost_tolls` must be a non-negative numeric value.")
    }

    departure_str <- if (inherits(departure, "POSIXt")) {
        format(departure, "%Y-%m-%dT%H:%M")
    } else {
        as.character(departure)
    }

    headers <- httr::add_headers(
        `Referer` = "https://fptaxi.pt/simulador-fptaxi/",
        `Origin`  = "https://fptaxi.pt"
    )

    price_body <- list(
        km        = as.numeric(distance_km),
        seg       = as.numeric(duration_sec),
        partida   = departure_str,
        tarifa    = tariff,
        reserva   = isTRUE(booking),
        portagens = as.numeric(cost_tolls),
        params    = stats::setNames(list(), character(0))
    )

    price_resp <- httr::POST(
        url    = "https://fptaxi.pt/wp-json/fpt/v1/price",
        body   = price_body,
        encode = "json",
        headers
    )
    httr::stop_for_status(price_resp)
    price_data <- jsonlite::fromJSON(
        httr::content(price_resp, "text", encoding = "UTF-8"),
        simplifyVector = FALSE
    )

    total_amt <- round(as.numeric(price_data$totalAMT) + as.numeric(luggage), 2)

    out <- data.frame(
        distance_km  = as.numeric(distance_km),
        duration_sec = as.numeric(duration_sec),
        total_amt    = total_amt
    )

    if (!is.null(route_geom)) {
        return(sf::st_sf(out, geometry = route_geom))
    }

    out
}
