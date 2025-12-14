get_month_between = function(from, to) {
    format(seq(
        lubridate::floor_date(from, "month"),
        lubridate::ceiling_date(to, "month"),
        by = "1 month"
    ), "%Y_%m")
}

update_data_wa = function(
    folder,
    from, to
) {
    logger::log_info(glue::glue("Obtaining metadata for `{folder}`..."))
    do = list_entsoe_folder_online(folder)
    if (is.null(do)) {
        logger::log_error(glue::glue("No entsoe files found for folder `{folder}`"))
        stop(glue::glue("No entsoe files found for folder `{folder}`"))
    }
    do = do[substr(name, 1, 7) %in% get_month_between(from, to)]
    logger::log_info(glue::glue("There are {nrow(do)} file(s)"))

    dc = NULL

    if (e.pkg$cache$enabled) {
        path = e.pkg$cache$folder
        dc = get_cache_toc_wa()
    } else {
        path = tempdir()
    }

    if (is.null(dc)) {
        dd = do
    } else {
        dm = data.table::merge.data.table(
            do[, .(id, name, updated, folder, size)],
            dc[, .(name, updated.cache = updated)],
            by = "name", all.x = TRUE
        )
        dd = dm[updated > updated.cache | is.na(updated.cache)]
        if (nrow(dd) < nrow(dm)) {
            logger::log_info(glue::glue("Using cache for {nrow(dm) - nrow(dd)} file(s)"))
        }
    }
    if (nrow(dd) > 0) {
        size = signif(sum(dd$size) / 2**20, 2)
        logger::log_info(glue::glue("Downloading {nrow(dd)} file(s) (~ {size} MB)..."))
        download_entsoe_files(dd$id, path)
    }
    if (e.pkg$cache$enabled) {
        # print(dd)
        dd = update_cache_toc_wa(dd)
    }
    list(
        files = dd,
        path = path
    )
}


#' @export
load_entsoe_data_wa = function(
    folder,
    from, to = Sys.time(),
    checkUpdates = TRUE
) {
    if (checkUpdates) {
        t = update_data_wa(folder, from, to)
        dc = t$files
        path = t$path
    } else {
        dc = get_cache_toc()
        path = e.pkg$cache$folder
    }

    dc = dc[folder == get("folder", envir = parent.env(environment()))]
    names = dc[substr(name, 1, 7) %in% get_month_between(from, to)]$name

    data.table::rbindlist(lapply(
        file.path(path, rename_csv_to_parquet(names)), arrow::read_parquet
    ))
}
