#' Fetch Census Origin-Destination available regions
#'
#' Queries the INE metadata API for the available regional filtering options
#' available for \code{MobilityDataPT::census_od()}.
#'
#' @return A \code{data.frame} with columns \code{id} and \code{name}.
#'
#' @examplesIf tryCatch({con <- suppressWarnings(socketConnection("www.ine.pt", port = 443, timeout = 10)); close(con); TRUE}, error = function(e) FALSE)
#' regions <- MobilityDataPT::census_od_regions()
#' head(regions)
#'
#' @seealso \code{MobilityDataPT::census_od()}
#'
#' @importFrom httr GET RETRY content http_error status_code
#' @importFrom jsonlite fromJSON
#' @export
census_od_regions <- function() {
    varcd <- "0011702"
    lang <- "PT"
    url <- paste0("https://www.ine.pt/ine/json_indicador/pindicaMeta.jsp?varcd=", varcd, "&lang=", lang)

    res <- httr::RETRY("GET", url, times = 3, pause_min = 1)
    if (httr::http_error(res)) {
        stop("Failed to fetch INE metadata from ", url, " (HTTP status ", httr::status_code(res), ")")
    }

    raw_json <- httr::content(res, "text", encoding = "UTF-8")
    parsed_json <- jsonlite::fromJSON(raw_json, simplifyVector = FALSE)

    if (length(parsed_json) == 0) {
        stop("No metadata returned for varcd: ", varcd)
    }

    item <- parsed_json[[1]]

    indicador_dsg <- if (!is.null(item$IndicadorDsg)) item$IndicadorDsg else item$IndicadorNome
    meta_inf_url <- if (!is.null(item$MetaInfUrl)) item$MetaInfUrl else NA
    data_extracao <- if (!is.null(item$DataExtracao)) item$DataExtracao else NA
    data_ultimo_atualizacao <- if (!is.null(item$DataUltimoAtualizacao)) {
        item$DataUltimoAtualizacao
    } else if (!is.null(item$DataUltimaAtualizacao)) {
        item$DataUltimaAtualizacao
    } else {
        NA
    }

    message("DataExtracao: ", data_extracao)
    message("DataUltimoAtualizacao: ", data_ultimo_atualizacao)

    cat_dim_list <- item$Dimensoes$Categoria_Dim[[1]]
    cats <- do.call(rbind, lapply(cat_dim_list, function(entry_item) {
        entry <- entry_item[[1]]
        if (as.character(entry$dim_num) == "2") {
            data.frame(
                id = as.character(entry$cat_id),
                name = as.character(entry$categ_dsg),
                stringsAsFactors = FALSE
            )
        } else {
            NULL
        }
    }))

    row.names(cats) <- NULL
    return(cats)
}

#' Fetch Census Origin-Destination Data
#'
#' Retrieves Census Origin-Destination (Home/Work & Study) data from INE for a given home location.
#'
#' Refer to \href{https://tabulador.ine.pt/indicador/?id=0011702}{INE website} to access the indicator online.
#'
#' @param id Region category filter ID (default \code{"PT"}). See \code{MobilityDataPT::census_od_regions()} for available IDs.
#'
#' @return A \code{data.frame} containing the aggregated Census OD records with columns:
#'   \itemize{
#'     \item \code{geocod}: Home location code
#'     \item \code{geodsg}: Home location designation
#'     \item \code{dim_3}: Sex category code 
#'     \item \code{dim_3_t}: Sex category designation (H, M, HM) 
#'     \item \code{dim_4}: Employment status code 
#'     \item \code{dim_4_t}: Employment status designation (Empregada, Estudante, Total)
#'     \item \code{dim_5}: Working location code 
#'     \item \code{dim_5_t}: Working location designation 
#'     \item \code{ind_string}: Count / resident population value in string format
#'     \item \code{valor}: Count / resident population value in numeric format
#'     \item \code{Periodo}: Reference period (2011, 2021)
#'   }
#'
#' @examplesIf tryCatch({con <- suppressWarnings(socketConnection("www.ine.pt", port = 443, timeout = 10)); close(con); TRUE}, error = function(e) FALSE)
#' od_data <- MobilityDataPT::census_od(id = "PT")
#' od_data |> dplyr::sample_n(5)
#'
#'
#'
#'
#' @seealso \code{MobilityDataPT::census_od_regions()}
#'
#' @importFrom httr GET content http_error status_code
#' @importFrom jsonlite fromJSON
#' @export
census_od <- function(id = "PT") {
    varcd <- "0011702"
    Dim1 <- "T"
    lang <- "PT"
    url <- paste0(
        "https://www.ine.pt/ine/json_indicador/pindica.jsp?op=2&varcd=", varcd,
        "&lang=", lang, "&id=", varcd, "&Dim1=", Dim1, "&Dim2=", as.character(id)
    )

    res <- httr::RETRY("GET", url, times = 3, pause_min = 1)
    if (httr::http_error(res)) {
        stop("Failed to fetch INE data from ", url, " (HTTP status ", httr::status_code(res), ")")
    }

    raw_json <- httr::content(res, "text", encoding = "UTF-8")
    parsed_json <- jsonlite::fromJSON(raw_json, simplifyVector = FALSE)

    if (length(parsed_json) == 0) {
        stop("No data returned for varcd: ", varcd, " and id: ", id)
    }

    item <- parsed_json[[1]]

    indicador_dsg <- if (!is.null(item$IndicadorDsg)) item$IndicadorDsg else item$IndicadorNome
    meta_inf_url <- if (!is.null(item$MetaInfUrl)) item$MetaInfUrl else NA
    data_extracao <- if (!is.null(item$DataExtracao)) item$DataExtracao else NA
    data_ultimo_atualizacao <- if (!is.null(item$DataUltimoAtualizacao)) {
        item$DataUltimoAtualizacao
    } else if (!is.null(item$DataUltimaAtualizacao)) {
        item$DataUltimaAtualizacao
    } else {
        NA
    }

    message("IndicadorDsg: ", indicador_dsg)
    message("MetaInfUrl: ", meta_inf_url)
    message("DataExtracao: ", data_extracao)
    message("DataUltimoAtualizacao: ", data_ultimo_atualizacao)

    dados_obj <- item$Dados
    if (is.null(dados_obj) || length(dados_obj) == 0) {
        return(data.frame())
    }

    all_rows <- list()
    for (periodo in names(dados_obj)) {
        rows_list <- dados_obj[[periodo]]
        periodo_df <- do.call(rbind, lapply(rows_list, function(r) {
            as.data.frame(r, stringsAsFactors = FALSE)
        }))
        periodo_df$Periodo <- periodo
        all_rows[[periodo]] <- periodo_df
    }

    result_df <- do.call(rbind, all_rows)
    row.names(result_df) <- NULL

    return(result_df)
}
