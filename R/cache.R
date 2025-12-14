#' Set Cache Folder
#'
#' This function sets the cache folder for the data files. Calling this function also enables caching.
#'
#' @param folder String. The directory to set as the cache folder.
#' @return No return value, called for side effects
#' @examples
#' \dontrun{
#' set_entsoe_cache("your_folder")
#' }
#' @export
set_entsoe_cache = function(folder) {
    e.pkg$cache = list(
        folder = folder,
        enabled = TRUE
    )
}

get_toc_file = function() file.path(e.pkg$cache$folder, "toc.parquet")

get_cache_toc = function() {
    if (!file.exists(get_toc_file()))
        return(NULL)

    data.table::as.data.table(arrow::read_parquet(get_toc_file()))
}

update_cache_toc = function(dn) {
    dir.create(e.pkg$cache$folder, showWarnings = FALSE, recursive = TRUE)

    do = get_cache_toc()
    dt = dn[, .(name, updated, from, to, folder)]

    if (is.null(do)) {
        df = dt
    } else {
        df = rbind(
            do[!(name %in% dn$name)],
            dt
        )
    }

    df = df[order(folder, from)]
    arrow::write_parquet(df, get_toc_file())
    df
}


get_toc_file_wa = function() file.path(e.pkg$cache$folder, "toc_wa.parquet")

get_cache_toc_wa = function() {
    if (!file.exists(get_toc_file_wa()))
        return(NULL)

    data.table::as.data.table(arrow::read_parquet(get_toc_file_wa()))
}

update_cache_toc_wa = function(dn) {
    dir.create(e.pkg$cache$folder, showWarnings = FALSE, recursive = TRUE)

    do = get_cache_toc_wa()
    dt = dn[, .(name, updated, folder)]

    if (is.null(do)) {
        df = dt
    } else {
        df = rbind(
            do[!(name %in% dn$name)],
            dt
        )
    }

    df = df[order(folder, name)]
    arrow::write_parquet(df, get_toc_file_wa())
    df
}
