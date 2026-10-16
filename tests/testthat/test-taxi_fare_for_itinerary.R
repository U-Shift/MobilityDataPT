library(testthat)

test_that("taxi_fare_for_itinerary returns expected sf object and fare components", {
    skip_on_cran()

    result <- taxi_fare_for_itinerary(
        origin_lat    = 38.76862,
        origin_lon    = -9.12825,
        dest_lat      = 38.73004,
        dest_lon      = -9.14406,
        departure     = Sys.time() + 3600,
        booking       = TRUE,
        include_tolls = FALSE
    )

    expect_s3_class(result, "sf")
    expect_equal(nrow(result), 1)
    expect_true(all(c(
        "distance_km", "duration_sec", "f_ajuste", "flag_drop",
        "cost_distance", "cost_time", "cost_booking", "cost_luggage",
        "cost_tolls", "total_cost", "total_amt", "geometry"
    ) %in% names(result)))
    expect_gt(result$distance_km, 0)
    expect_gt(result$duration_sec, 0)
    expect_gt(result$total_cost, 0)
})

