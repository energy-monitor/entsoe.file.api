update_data = function(
    folder, 
    from, to
) {
    logger::log_info(glue::glue("Obtaining metadata for `{folder}`...")) 
    do = list_entsoe_files_online(folder, from, to)
    if (is.null(do)) {
        logger::log_error(glue::glue("No entsoe files found for period in folder `{folder}`"))
        stop(glue::glue("No entsoe files found for period in folder `{folder}`"))
    }
    logger::log_info(glue::glue("Period data is contained in {nrow(do)} file(s)")) 

    dc = NULL

    if (e.pkg$cache$enabled) {
        path = e.pkg$cache$folder
        dc = get_cache_toc()
    } else {
        path = tempdir()
    }
    

    if (is.null(dc)) {
        dd = do
    } else { 
        dm = data.table::merge.data.table(
            do[, .(id, name, updated, from, to, folder, size)],
            dc[, .(name, updated.cache = updated)], 
            by = "name", all.x = TRUE
        )
        dd = dm[updated > updated.cache | is.na(updated.cache)]
        if (nrow(dd) < nrow(dm)) {
            logger::log_info(glue::glue("Using cache for {nrow(dm) - nrow(dd)} file(s)")) 
        }
    }
    if (nrow(dd) > 0) {
        size = signif(sum(dd$size)/2**20, 2)
        logger::log_info(glue::glue("Downloading {nrow(dd)} file(s) (~ {size} MB)...")) 
        download_entsoe_files(dd$id, path)
    }
    if (e.pkg$cache$enabled) {
        dd = update_cache_toc(dd)
    } 
    list(
        files = dd,
        path = path
    )
}


#' Load ENTSO-E Data
#'
#' This function loads the specified ENTSO-E data for a given time range.
#'
#' @param folder String. The type of ENTSO-E data to load. See \code{\link{get_entsoe_folders}} for available data types.
#' @param from POSIXct or character. The start time of the data range.
#' @param to POSIXct or character. The end time of the data range. Defaults to the current system time.
#' @param checkUpdates Logical. Indicates whether the function should check for data updates. Default is TRUE.
#' @return ENTSO-E data for a given time range as \code{data.table}
#' @examples
#' \dontrun{
#' load_entsoe_data("EnergyPrices_12.1.D_r3", "2020-01-01", "2020-12-31")
#' }
#' @export
load_entsoe_data = function(
    folder, 
    from, to = Sys.time(),
    checkUpdates = TRUE
) {
    if (checkUpdates) {
        t = update_data(folder, from, to) 
        dc = t$files
        path = t$path
    } else {
        dc = get_cache_toc()
        path = e.pkg$cache$folder
    }
  
    dc = dc[folder == get("folder", envir = parent.env(environment()))][order(from)]

    intervals = lubridate::interval(dc$from, dc$to)

    i.from = 1
    i.to = nrow(dc)

    w.from = lubridate::`%within%`(as.POSIXct(from), intervals)
    w.to = lubridate::`%within%`(as.POSIXct(to), intervals)

    if (sum(w.from) > 0) i.from = max(which(w.from))
    if (sum(w.to) > 0) i.to = min(which(w.to))

    names = dc[i.from:i.to]$name
  
    d = data.table::rbindlist(lapply(
        file.path(path, rename_csv_to_parquet(names)), arrow::read_parquet
    ))

    time.col = grep("DateTime", colnames(d), value = TRUE)

    if (length(time.col) != 1) {
        logger::log_warn("Could not identify DateTime column, please filter by DateTime yourself")
        return(d)
    }

    d[get(time.col) >= from & get(time.col) <= to]
}


  
