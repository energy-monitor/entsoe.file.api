download_entsoe_files = function(
    ids, targetFolder
) {
    chunk.size = 100
    dir.create(targetFolder, showWarnings = FALSE, recursive = TRUE)

    for (idsChunk in split(ids, ceiling(seq_along(ids)/chunk.size))) {
        request_body = list(
            fileIdList = I(idsChunk),
            topLevelFolder = "TP_export",
            downloadAsZip = TRUE
        )

        response = httr::POST(
            url = glue::glue("{e.pkg$urls$base}/downloadFileContent"),
            httr::add_headers(Authorization = glue::glue("Bearer {get_token()}")),
            body = jsonlite::toJSON(request_body, auto_unbox = TRUE),
            httr::content_type("application/json"),
            httr::timeout(600)  # Longer timeout for batch download
        )

        if (httr::status_code(response) != 200) {
            stop(glue::glue("download_entsoe_files: {httr::status_code(response)}"))
        }

        zipfile = tempfile(fileext = ".zip")
        writeBin(httr::content(response, "raw"), zipfile)
        files = utils::unzip(zipfile, exdir = targetFolder, overwrite = TRUE)
        lapply(files, function(f) {
            d = data.table::fread(f)
            arrow::write_parquet(d, rename_csv_to_parquet(f))
            file.remove(f)
        })
        file.remove(zipfile)
    }
}
