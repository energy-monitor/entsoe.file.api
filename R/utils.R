#' Get ENTSO-E Folders
#'
#' This function retrieves the ENTSO-E folders from the 'entsoe_extracts.csv' file within the 'entsoe.file.api' package.
#'
#' @return A \code{data.table} of the ENTSO-E folders.
#' @examples
#' \dontrun{
#' get_entsoe_folders()
#' }
#' @export
get_entsoe_folders = function() {
    csv_path = system.file("extdata", "entsoe_extracts.csv", package = "entsoe.file.api")
    data.table::fread(csv_path)
}

convert_POSIXct_to_character = function(p)
    format(lubridate::with_tz(p, "UTC"), "%Y-%m-%dT%H:%M:%OSZ")

convert_character_to_POSIXct = function(c)
    as.POSIXct(c, format="%Y-%m-%dT%H:%M:%OSZ", tz="UTC")

rename_csv_to_parquet = function(n)
    paste0(substr(n, 1, nchar(n) - 3), 'parquet')