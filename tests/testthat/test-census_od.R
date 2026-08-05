library(testthat)

test_that("census_od_regions fetches regions metadata as a data.frame with id and name", {
    df <- census_od_regions()

    expect_s3_class(df, "data.frame")
    expect_named(df, c("id", "name"))
    expect_gt(nrow(df), 0)
})

test_that("census_od fetches data and aggregates Dados into a data.frame", {
    data_df <- census_od(id = 3)

    expect_s3_class(data_df, "data.frame")
    expect_gt(nrow(data_df), 0)
    expect_true("geocod" %in% colnames(data_df))
    expect_true("valor" %in% colnames(data_df))
})
