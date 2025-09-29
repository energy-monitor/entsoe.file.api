#' Set ENTSO-E API credentials
#'
#' This function sets the username and password for the ENTSO-E API within the e.pkg package.
#'
#' @param username String. ENTSO-E API username.
#' @param password String. ENTSO-E API password.
#' @return No return value, called for side effects
#' @examples
#' \dontrun{
#' set_entsoe_credentials("your_username", "your_password")
#' }
#' @export
set_entsoe_credentials = function(username, password)
    e.pkg$credentials = list(
        username = username, password = password
    )

get_token = function() {
    if (is.null(e.pkg$credentials)) {
        logger::log_error("No credentials set")
        stop("No credentials set")
    } 

    tryCatch({
        time = Sys.time()
        response = httr::POST(
            url = e.pkg$urls$keycloak,
            body = list(
                grant_type = "password",
                client_id = "tp-fms-public",
                username = e.pkg$credentials$username,
                password = e.pkg$credentials$password
            ),
            encode = "form",
            httr::timeout(30)
        )

        if (httr::status_code(response) == 200) {
            token_data = httr::content(response)
            token = token_data$access_token

            e.pkg$token.cache = list(
                token = token,
                expires_at = time + lubridate::seconds(token_data$expires_in)
            )

            return(token)
        } else if (httr::status_code(response) == 401) {
            logger::log_error("Code 401: Most likely wrong credentials.")
            stop(glue::glue("Failed to get token: {httr::status_code(response)}"))
        } else {
            stop(glue::glue("Failed to get token: {httr::status_code(response)}"))
        }
    }, error = function(e) {
        stop(glue::glue("Error getting token: {e$message}"))
    })
}
