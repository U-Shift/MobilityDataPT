# Load required libraries
library(httr2)
library(jsonlite)
library(dplyr)

# --- Configuration ---
base_url <- "https://c2g091p01.emel.pt"
user_agent <- "Gira/3.4.3 (Android 34)"

# --- Retrieve credentials from environment variables ---
# AttentioN! Make sure to have set the env variables, use usethis::edit_r_environ()

email <- Sys.getenv("GIRA_EMAIL")
password <- Sys.getenv("GIRA_PASSWORD")

if (email == "" || password == "") {
    stop(paste(
        "Missing credentials!",
        "Please set the GIRA_EMAIL and GIRA_PASSWORD environment variables before running this script.",
        "You can set the environment variables using usethis::edit_r_environ()",
        "Don't forget to restart your R session after setting the environment variables.",
        sep = "\n"
    ))
}

message("Authenticating with EMEL GIRA API...")

# --- 1. Login Request ---
login_payload <- list(
    Provider = "EmailPassword",
    CredentialsEmailPassword = list(
        email = email,
        password = password
    )
)

login_req <- request(paste0(base_url, "/auth/login")) %>%
    req_method("POST") %>%
    req_headers(
        `User-Agent` = user_agent,
        `Priority` = "high"
    ) %>%
    req_body_json(login_payload)

# Perform login and extract access token
tryCatch(
    {
        login_resp <- req_perform(login_req)
        login_data <- resp_body_json(login_resp)
        access_token <- login_data$data$accessToken

        if (is.null(access_token)) {
            stop("Login response did not contain 'accessToken'.")
        }

        message("Login successful! Retrieved access token.")
    },
    error = function(e) {
        stop(paste("Authentication failed:", e$message))
    }
)

# --- 2. Retrieve Stations via GraphQL ---
message("Fetching GIRA stations data...")

graphql_query <- "query getStations {
  getStations {
    code
    description
    latitude
    longitude
    name
    bikes
    docks
    serialNumber
    assetStatus
  }
}"

stations_req <- request(paste0(base_url, "/ws/graphql")) %>%
    req_method("POST") %>%
    req_headers(
        `User-Agent` = user_agent,
        `Authorization` = paste("Bearer", access_token)
    ) %>%
    req_body_json(list(query = graphql_query))

# Perform GraphQL request and parse into data.frame
tryCatch(
    {
        stations_resp <- req_perform(stations_req)
        stations_text <- resp_body_string(stations_resp)

        # Parse with jsonlite for direct df extraction
        parsed_response <- jsonlite::fromJSON(stations_text)

        # Access the list of stations
        stations_df <- parsed_response$data$getStations

        if (is.null(stations_df) || !is.data.frame(stations_df)) {
            stop("Failed to parse stations into a data.frame from the response.")
        }

        message(sprintf("Successfully retrieved %d stations!", nrow(stations_df)))

        # Print the first few rows of the data frame to demonstrate
        print(head(stations_df))

        # Export/make stations_df available (if running interactively)
        # or assign it to the global environment
        assign("stations_df", stations_df, envir = .GlobalEnv)
    },
    error = function(e) {
        stop(paste("Failed to retrieve stations data:", e$message))
    }
)


summary(stations_df)
nrow(stations_df)
View(stations_df)
