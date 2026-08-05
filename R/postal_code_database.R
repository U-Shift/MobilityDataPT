#' Access Eurostat GISCO Postal Code database
#'
#' Downloads and reads the GISCO Postal Codes dataset provided by \href{https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/postal-codes}{Eurostat}.
#' Files are cached locally in the directory specified by the \code{MOBILITYDATAPT_DOWNLOAD_DIRECTORY}
#' environment variable, defaulting to \code{~/.local/share/R/MobilityDataPT}.
#'
#' @param cntr_id Two-letter country code to filter by (default \code{"PT"}). Pass \code{NA} or \code{NULL}
#'   to return all countries present in the dataset.
#' @param year Release year of the dataset. Allowed values are \code{2020} or \code{2024} (default \code{2024}).
#' @param crs Coordinate Reference System (EPSG code) of the dataset. Allowed values are \code{3857},
#'   \code{3035}, or \code{4326} (default \code{4326}).
#' @param download_dir Directory where downloaded GeoPackage files are stored. Defaults to the
#'   \code{MOBILITYDATAPT_DOWNLOAD_DIRECTORY} environment variable or \code{~/.local/share/R/MobilityDataPT}.
#'
#' @return An \code{sf} object containing spatial postal code boundaries/points.
#'   Returned columns include:
#'   \itemize{
#'     \item \code{POSTCODE}: Postal code identifier (e.g. "1000-001")
#'     \item \code{CNTR_ID}: Country identifier (e.g. "PT")
#'     \item \code{LAU_NAME}: Local Administrative Unit name ("freguesia" for Portugal)
#'     \item \code{NUTS3_2024}: NUTS level 3 region code
#'     \item \code{Shape}: Point of postal code location.
#'   }
#'
#' @examples
#' db <- MobilityDataPT::postal_code_database()
#'
#' db |> dplyr::select(POSTCODE, LAU_NAME, Shape) |> dplyr::sample_n(5)
#'
#' @importFrom sf st_read
#' @importFrom utils download.file
#' @export
postal_code_database <- function(cntr_id = "PT", year = 2024, crs = 4326, download_dir = NULL) {
    year_str <- match.arg(as.character(year), choices = c("2020", "2024"))
    crs_str <- match.arg(as.character(crs), choices = c("3035", "4326", "3857"))

    if (is.null(download_dir) || nchar(download_dir) == 0) {
        download_dir <- Sys.getenv("MOBILITYDATAPT_DOWNLOAD_DIRECTORY", unset = "")
    }

    if (nchar(download_dir) == 0) {
        download_dir <- file.path(path.expand("~"), ".local", "share", "R", "MobilityDataPT")
    }

    if (!dir.exists(download_dir)) {
        dir.create(download_dir, recursive = TRUE)
    }

    filename <- paste0("PCODE_PT_", year_str, "_", crs_str, ".gpkg")
    file_path <- file.path(download_dir, filename)

    if (!file.exists(file_path)) {
        url <- paste0("https://gisco-services.ec.europa.eu/distribution/v2/pcode/gpkg/", filename)
        message("Downloading postal code database from ", url, " to ", file_path)

        old_timeout <- getOption("timeout")
        options(timeout = max(600, old_timeout))
        on.exit(options(timeout = old_timeout), add = TRUE)

        tryCatch(
            {
                utils::download.file(url, destfile = file_path, mode = "wb")
            },
            error = function(e) {
                if (file.exists(file_path)) {
                    unlink(file_path)
                }
                stop("Failed to download postal code database: ", e$message)
            }
        )
    }

    data <- sf::st_read(file_path, quiet = TRUE)

    if (!is.null(cntr_id) && !is.na(cntr_id)) {
        data <- data[data$CNTR_ID == cntr_id, ]
    }

    return(data)
}

#' Get Postal Code coordinates
#'
#' Retrieves spatial coordinates and geometry for specific postal code(s) from the
#' Eurostat GISCO postal code database.
#'
#' @param postal_codes Character vector of postal code identifiers (e.g., \code{"1000-001"} or \code{c("1000-001", "2800-001")}).
#'   If \code{NULL}, returns coordinates for all postal codes in the dataset.
#' @param cntr_id Two-letter country code to filter by (default \code{"PT"}). Pass \code{NA} or \code{NULL}
#'   to return all countries.
#' @param year Release year of the dataset. Allowed values are \code{2020} or \code{2024} (default \code{2024}).
#' @param crs Coordinate Reference System (EPSG code) of the dataset. Allowed values are \code{3857},
#'   \code{3035}, or \code{4326} (default \code{4326}).
#' @param download_dir Directory where downloaded GeoPackage files are stored. Defaults to the
#'   \code{MOBILITYDATAPT_DOWNLOAD_DIRECTORY} environment variable or \code{~/.local/share/R/MobilityDataPT}.
#'
#' @return An \code{sf} object containing matching postal code records and geometries.
#'
#' @examples
#' MobilityDataPT::get_postal_code_coordinates(c("1000-001", "2800-001"))
#'
#' @seealso \code{MobilityDataPT::postal_code_database()}
#'
#' @export
get_postal_code_coordinates <- function(postal_codes = NULL, cntr_id = "PT", year = 2024, crs = 4326, download_dir = NULL) {
    db <- postal_code_database(cntr_id = cntr_id, year = year, crs = crs, download_dir = download_dir)

    if (!is.null(postal_codes)) {
        db <- db[db$POSTCODE %in% postal_codes, ]
    }

    return(db |> dplyr::select(tidyselect::any_of(c("POSTCODE", "Shape"))))
}
