library(testthat)

# Helper mock sf dataset
create_mock_sf <- function() {
    sf::st_sf(
        POSTCODE = c("1000-001", "2800-001", "28000"),
        CNTR_ID = c("PT", "PT", "ES"),
        SOURCE = c("NSI", "NSI", "NSI"),
        LAU_NAME = c("Lisboa", "Almada", "Madrid"),
        PC_CNTR = c("1000-001_PT", "2800-001_PT", "28000_ES"),
        CODE = c("1000", "2800", "2800"),
        NUTS3_2024 = c("PT170", "PT170", "ES300"),
        NSI_2021 = c("170101", "170301", "280001"),
        GISCO_2021 = c("G1", "G2", "G3"),
        DGURBA = c(1, 1, 1),
        FUA_ID = c("FUA1", "FUA1", "FUA2"),
        CITY_ID = c("C1", "C2", "C3"),
        NAME_ENGL = c("Lisbon", "Almada", "Madrid"),
        NAME_FREN = c("Lisbonne", "Almada", "Madrid"),
        ISO3_CODE = c("PRT", "PRT", "ESP"),
        SVRG_UN = c("U1", "U1", "U2"),
        CAPT = c("Y", "N", "Y"),
        EU_STAT = c("Y", "Y", "Y"),
        EFTA_STAT = c("N", "N", "N"),
        CC_STAT = c("N", "N", "N"),
        NAME_GERM = c("Lissabon", "Almada", "Madrid"),
        geometry = sf::st_sfc(
            sf::st_point(c(-9.139, 38.713)),
            sf::st_point(c(-9.158, 38.678)),
            sf::st_point(c(-3.703, 40.416)),
            crs = 4326
        )
    )
}

test_that("postal_code_database validates parameters", {
    expect_error(postal_code_database(year = 2019))
    expect_error(postal_code_database(crs = 9999))
})

test_that("postal_code_database calls utils::download.file when file does not exist", {
    temp_dir <- tempfile("pcode_test_dl_")
    on.exit(unlink(temp_dir, recursive = TRUE))

    mock_data <- create_mock_sf()
    download_called <- FALSE
    downloaded_url <- NULL

    local_mocked_bindings(
        download.file = function(url, destfile, mode) {
            download_called <<- TRUE
            downloaded_url <<- url
            sf::st_write(mock_data, destfile, quiet = TRUE)
            0
        },
        .package = "utils"
    )

    res <- postal_code_database(cntr_id = "PT", year = 2024, crs = 4326, download_dir = temp_dir)

    expect_true(download_called)
    expect_equal(downloaded_url, "https://gisco-services.ec.europa.eu/distribution/v2/pcode/gpkg/PCODE_PT_2024_4326.gpkg")
    expect_s3_class(res, "sf")
    expect_equal(nrow(res), 2)
})

test_that("postal_code_database handles download.file errors and unlinks partial files", {
    temp_dir <- tempfile("pcode_test_err_")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))

    local_mocked_bindings(
        download.file = function(url, destfile, mode) {
            # Simulate partial download file creation before failure
            writeLines("partial content", destfile)
            stop("Simulated HTTP download failure")
        },
        .package = "utils"
    )

    expect_error(
        postal_code_database(cntr_id = "PT", year = 2024, crs = 4326, download_dir = temp_dir),
        "Failed to download postal code database"
    )

    # Ensure partial file was cleaned up / unlinked on failure
    expected_file <- file.path(temp_dir, "PCODE_PT_2024_4326.gpkg")
    expect_false(file.exists(expected_file))
})

test_that("postal_code_database respects MOBILITYDATAPT_DOWNLOAD_DIRECTORY environment variable and directory creation", {
    temp_dir <- tempfile("pcode_test_env_")
    on.exit(unlink(temp_dir, recursive = TRUE))

    withr::local_envvar(MOBILITYDATAPT_DOWNLOAD_DIRECTORY = temp_dir)

    mock_data <- create_mock_sf()
    local_mocked_bindings(
        download.file = function(url, destfile, mode) {
            sf::st_write(mock_data, destfile, quiet = TRUE)
            0
        },
        .package = "utils"
    )

    # Directory should be created automatically by the function
    res <- postal_code_database(cntr_id = "PT")

    expect_true(dir.exists(temp_dir))
    expect_true(file.exists(file.path(temp_dir, "PCODE_PT_2024_4326.gpkg")))
    expect_s3_class(res, "sf")
})

test_that("postal_code_database reads cached dataset and filters correctly", {
    temp_dir <- tempfile("pcode_test_cached_")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))

    mock_data <- create_mock_sf()
    mock_file <- file.path(temp_dir, "PCODE_PT_2024_4326.gpkg")
    sf::st_write(mock_data, mock_file, quiet = TRUE)

    # download.file should NOT be called since file already exists
    download_called <- FALSE
    local_mocked_bindings(
        download.file = function(url, destfile, mode) {
            download_called <<- TRUE
            0
        },
        .package = "utils"
    )

    # Test filtering by country ID ("PT")
    res_pt <- postal_code_database(cntr_id = "PT", year = 2024, crs = 4326, download_dir = temp_dir)
    expect_false(download_called)
    expect_s3_class(res_pt, "sf")
    expect_equal(nrow(res_pt), 2)
    expect_true(all(res_pt$CNTR_ID == "PT"))

    # Test returning all records when cntr_id is NA
    res_all <- postal_code_database(cntr_id = NA, year = 2024, crs = 4326, download_dir = temp_dir)
    expect_s3_class(res_all, "sf")
    expect_equal(nrow(res_all), 3)

    # Test get_postal_code_coordinates filtering by specific postal code
    coords_subset <- get_postal_code_coordinates(postal_codes = "1000-001", download_dir = temp_dir)
    expect_s3_class(coords_subset, "sf")
    expect_equal(nrow(coords_subset), 1)
    expect_equal(coords_subset$POSTCODE, "1000-001")
})
