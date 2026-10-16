#' Estimate taxi route, travel time, tolls, and regulated fare in Portugal
#'
#' Encapsulates the routing and tariff calculation functionality provided by the
#' \href{https://fptaxi.pt/simulador-fptaxi/}{Federação Portuguesa do Táxi (FPTaxi)} simulator
#' (powered by TomTom traffic profiles) and optionally estimates Class 1 (`C1`) highway tolls
#' via \code{\link{tools_for_itinerary}}.
#'
#' @note Data source: Federação Portuguesa do Táxi (\url{https://fptaxi.pt/simulador-fptaxi/})
#'   and Infraestruturas de Portugal (\url{https://portagens.infraestruturasdeportugal.pt/}).
#'   Terms of service apply.
#'
#' @param origin_lat Numeric. Origin latitude in decimal degrees (WGS84 / EPSG:4326).
#' @param origin_lon Numeric. Origin longitude in decimal degrees (WGS84 / EPSG:4326).
#' @param dest_lat Numeric. Destination latitude in decimal degrees (WGS84 / EPSG:4326).
#' @param dest_lon Numeric. Destination longitude in decimal degrees (WGS84 / EPSG:4326).
#' @param departure POSIXct or character string (`"YYYY-MM-DDTHH:MM"`) with departure date and time.
#'   Note: TomTom uses historical hourly traffic profiles when `departure` is in the future.
#' @param tariff Character. Vehicle tariff class: `"t1"` (up to 4 passengers, default),
#'   `"t2"` (>4 passengers), or `"td"` (unmarked vehicle).
#' @param booking Logical. Whether to include the booking/call supplement (`0.80` EUR). Default is `TRUE`.
#' @param luggage Numeric. Optional luggage supplement in EUR. Default is `0`.
#' @param include_tolls Logical. If `TRUE`, computes Class 1 (`C1`) tolls along the route
#'   using \code{\link{tools_for_itinerary}}. Default is `TRUE`.
#'
#' @return An \code{sf} data frame (\code{EPSG:4326}) with one row containing the route
#'   \code{LINESTRING} geometry and the following columns:
#'   \itemize{
#'     \item \code{distance_km}: Route distance in kilometers.
#'     \item \code{duration_sec}: Estimated travel time in seconds (accounting for traffic).
#'     \item \code{f_ajuste}: Time-of-day/day-type tariff multiplier (\code{1.00}, \code{1.25}, \code{1.50}, or \code{1.75}).
#'     \item \code{flag_drop}: Initial flag drop fee (\code{bandeirada}) in Euros.
#'     \item \code{cost_distance}: Distance component in Euros (including progressive distance tiers).
#'     \item \code{cost_time}: Time component in Euros.
#'     \item \code{cost_booking}: Booking supplement in Euros.
#'     \item \code{cost_luggage}: Luggage supplement in Euros.
#'     \item \code{cost_tolls}: Class 1 (\code{C1}) toll cost in Euros.
#'     \item \code{total_cost}: Final estimated taxi fare in Euros.
#'     \item \code{total_amt}: Reference fare under current AMT regulation (Art. 16-1) in Euros.
#'   }
#'
#' @examples
#' \donttest{
#' res <- MobilityDataPT::taxi_fare_for_itinerary(
#'     origin_lat = 38.76862,
#'     origin_lon = -9.12825,
#'     dest_lat   = 38.73004,
#'     dest_lon   = -9.14406,
#'     departure  = Sys.time() + 3600,
#'     include_tolls = FALSE
#' )
#' print(res)
#' }
#'
#' @importFrom sf st_sf st_sfc st_linestring st_geometry
#' @importFrom jsonlite fromJSON
#' @importFrom httr POST content add_headers stop_for_status
#' @export
taxi_fare_for_itinerary <- function(origin_lat,
                                    origin_lon,
                                    dest_lat,
                                    dest_lon,
                                    departure = Sys.time() + 600,
                                    tariff = c("t1", "t2", "td"),
                                    booking = TRUE,
                                    luggage = 0,
                                    include_tolls = TRUE) {
    tariff <- match.arg(tariff)
    departure_str <- if (inherits(departure, "POSIXt")) {
        format(departure, "%Y-%m-%dT%H:%M")
    } else {
        as.character(departure)
    }

    headers <- httr::add_headers(
        `Referer` = "https://fptaxi.pt/simulador-fptaxi/",
        `Origin`  = "https://fptaxi.pt"
    )

    # 1. Route request (FPTaxi / TomTom)
    route_body <- list(
        origem  = list(lat = as.numeric(origin_lat), lon = as.numeric(origin_lon), nome = "Origin"),
        destino = list(lat = as.numeric(dest_lat),   lon = as.numeric(dest_lon),   nome = "Destination"),
        partida = departure_str
    )

    route_resp <- httr::POST(
        url    = "https://fptaxi.pt/wp-json/fpt/v1/route",
        body   = route_body,
        encode = "json",
        headers
    )
    httr::stop_for_status(route_resp)
    route_data <- jsonlite::fromJSON(
        httr::content(route_resp, "text", encoding = "UTF-8"),
        simplifyVector = FALSE
    )

    km  <- as.numeric(route_data$km)
    seg <- as.numeric(route_data$seg)

    # Convert [lat, lon] points to sf LINESTRING (EPSG:4326)
    coords <- do.call(
        rbind,
        lapply(route_data$pontos, function(p) c(X = as.numeric(p[[2]]), Y = as.numeric(p[[1]])))
    )
    route_sf <- sf::st_sf(geometry = sf::st_sfc(sf::st_linestring(coords), crs = 4326))

    # 2. Optional Class 1 toll calculation via IP API
    toll_c1 <- 0
    if (isTRUE(include_tolls) && nrow(coords) >= 2) {
        tolls <- tryCatch(tools_for_itinerary(route_sf), error = function(e) list(C1 = 0))
        toll_c1 <- as.numeric(tolls$C1)
        if (length(toll_c1) == 0 || is.na(toll_c1)) toll_c1 <- 0
    }

    # 3. Regulated price request (FPTaxi)
    price_body <- list(
        km        = km,
        seg       = seg,
        partida   = departure_str,
        tarifa    = tariff,
        reserva   = isTRUE(booking),
        portagens = toll_c1,
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

    flag_drop     <- as.numeric(price_data$band)
    cost_distance <- as.numeric(price_data$dist$total)
    cost_time     <- as.numeric(price_data$valorTempo)
    f_ajuste      <- as.numeric(price_data$fajusteMedio)
    cost_booking  <- as.numeric(price_data$reserva)
    cost_luggage  <- as.numeric(luggage)
    total_cost    <- round(flag_drop + cost_distance + cost_time + cost_booking + cost_luggage + toll_c1, 2)

    out <- data.frame(
        distance_km   = km,
        duration_sec  = seg,
        f_ajuste      = f_ajuste,
        flag_drop     = flag_drop,
        cost_distance = cost_distance,
        cost_time     = cost_time,
        cost_booking  = cost_booking,
        cost_luggage  = cost_luggage,
        cost_tolls    = toll_c1,
        total_cost    = total_cost,
        total_amt     = round(as.numeric(price_data$totalAMT) + cost_luggage, 2)
    )

    sf::st_sf(out, geometry = sf::st_geometry(route_sf))
}

