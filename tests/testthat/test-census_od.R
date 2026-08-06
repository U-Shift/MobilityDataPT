library(testthat)

ine_is_reachable <- function() {
    if (!curl::has_internet()) return(FALSE)
    tryCatch({
        con <- suppressWarnings(socketConnection("www.ine.pt", port = 443, timeout = 2))
        close(con)
        TRUE
    }, error = function(e) FALSE)
}

test_that("census_od_regions fetches regions metadata as a data.frame with id and name", {
    skip_on_cran()
    if (!ine_is_reachable()) skip("www.ine.pt is unreachable")
    df <- census_od_regions()

    expect_s3_class(df, "data.frame")
    expect_named(df, c("id", "name"))
    expect_gt(nrow(df), 0)
})

test_that("census_od fetches data and aggregates Dados into a data.frame", {
    skip_on_cran()
    if (!ine_is_reachable()) skip("www.ine.pt is unreachable")
    data_df <- census_od(id = 3)

    expect_s3_class(data_df, "data.frame")
    expect_gt(nrow(data_df), 0)
    expect_true("geocod" %in% colnames(data_df))
    expect_true("valor" %in% colnames(data_df))
})


