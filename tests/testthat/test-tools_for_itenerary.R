library(testthat)

test_that("tools_for_itinerary returns expected toll costs data.frame", {
    coords <- matrix(
        c(-9.173740, 38.675274,-9.174055, 38.676656),
        ncol = 2,
        byrow = TRUE
    )
    sf_itinerary <- sf::st_sf(geometry = sf::st_sfc(sf::st_linestring(coords), crs = 4326))
    # mapview::mapview(sf_itinerary)

    result <- tools_for_itinerary(sf_itinerary)

    expect_s3_class(result, "data.frame")
    expect_named(result, c("C1", "C2", "C3", "C4"))
    expect_equal(nrow(result), 1)
})
