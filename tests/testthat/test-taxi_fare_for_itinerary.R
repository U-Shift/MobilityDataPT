library(testthat)

test_that("taxi_fare_for_itinerary returns expected data.frame and AMT fare", {
    skip_on_cran()

    result <- taxi_fare_for_itinerary(
        distance_km  = 16.883,
        duration_sec = 1630,
        departure    = Sys.time() + 3600,
        tariff       = "t1",
        booking      = TRUE,
        luggage      = 1.60,
        cost_tolls   = 2.25
    )

    expect_s3_class(result, "data.frame")
    expect_false(inherits(result, "sf"))
    expect_equal(nrow(result), 1)
    expect_equal(names(result), c("distance_km", "duration_sec", "total_amt"))
    expect_equal(result$distance_km, 16.883)
    expect_equal(result$duration_sec, 1630)
    expect_gt(result$total_amt, 0)
})

test_that("taxi_fare_for_itinerary works with sf itinerary object and character departure", {
    skip_on_cran()

    result_char <- taxi_fare_for_itinerary(
        distance_km  = 10,
        duration_sec = 600,
        departure    = "2026-10-26T17:00"
    )
    expect_s3_class(result_char, "data.frame")
    expect_gt(result_char$total_amt, 0)

    sample_file <- system.file("extdata/samples", "tool_itinerary_25AbrilBridge.gpkg", package = "MobilityDataPT")
    if (file.exists(sample_file)) {
        sf_itinerary <- sf::st_read(sample_file, quiet = TRUE)
        result <- taxi_fare_for_itinerary(
            distance_km  = sf_itinerary,
            duration_sec = 900,
            booking      = FALSE
        )
        expect_s3_class(result, "sf")
        expect_equal(nrow(result), 1)
        expect_gt(result$distance_km, 0)
        expect_gt(result$total_amt, 0)
    }
})

test_that("taxi_fare_for_itinerary validates input arguments", {
    expect_error(taxi_fare_for_itinerary(distance_km = -5), "must be a non-negative numeric value")
    expect_error(taxi_fare_for_itinerary(distance_km = "invalid"), "must be a non-negative numeric value")
    expect_error(taxi_fare_for_itinerary(distance_km = 10, duration_sec = -10), "must be a non-negative numeric value")
    expect_error(taxi_fare_for_itinerary(distance_km = 10, luggage = -1), "must be a non-negative numeric value")
    expect_error(taxi_fare_for_itinerary(distance_km = 10, cost_tolls = -1), "must be a non-negative numeric value")
    expect_error(taxi_fare_for_itinerary(distance_km = 10, tariff = "invalid"))
})
