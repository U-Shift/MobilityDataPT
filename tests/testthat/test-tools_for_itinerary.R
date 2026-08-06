library(testthat)

test_that("tools_for_itinerary returns expected toll costs data.frame", {
    coords <- matrix(
        c(
            -9.17322, 38.67254,
            -9.17331, 38.67295,
            -9.17346, 38.67359,
            -9.17360, 38.67415,
            -9.17383, 38.67507,
            -9.17401, 38.67588,
            -9.17403, 38.67596,
            -9.17405, 38.67605,
            -9.17415, 38.67656,
            -9.17420, 38.67680,
            -9.17426, 38.67711,
            -9.17433, 38.67752,
            -9.17441, 38.67787,
            -9.17453, 38.67846,
            -9.17459, 38.67872,
            -9.17465, 38.67898,
            -9.17478, 38.67948,
            -9.17478, 38.67948,
            -9.17487, 38.67986,
            -9.17507, 38.68073,
            -9.17602, 38.68501,
            -9.17802, 38.69401,
            -9.17895, 38.69831,
            -9.17911, 38.69900,
            -9.17911, 38.69900
        ),
        ncol = 2,
        byrow = TRUE
    )
    sf_itinerary <- sf::st_sf(geometry = sf::st_sfc(sf::st_linestring(coords), crs = 4326))
    # sf::st_write(sf_itinerary, "inst/extdata/samples/tool_itinerary_25AbrilBridge.gpkg")
    # mapview::mapview(sf_itinerary)

    result <- tools_for_itinerary(sf_itinerary)

    expect_type(result, "list")
    expect_named(result, c("C1", "C2", "C3", "C4"))
    expect_true(all(unlist(result) > 0))
})
