# list_entsoe_folder_online = function(
#     folder
# ) {
#     pageIndex = 0
#     pageSize = 5000
# 
#     requestBody = list(
#         path = glue::glue("/TP_export/{folder}/"),
#         pageInfo = list(
#             pageIndex = pageIndex,
#             pageSize = pageSize
#         )
#     )
#     response = httr::POST(
#         url = glue::glue("{e.pkg$urls$base}/listFolder"),
#         httr::add_headers(Authorization = glue::glue("Bearer {get_token()}")),
#         body = jsonlite::toJSON(requestBody, auto_unbox = TRUE),
#         httr::content_type("application/json"),
#         httr::timeout(60)
#     )
# 
#     if (httr::status_code(response) != 200) {
#         stop(glue::glue("list_entsoe_folder_online: {httr::status_code(response)}"))
#     }
# 
#     content = httr::content(response)
#     
#     d = data.table::rbindlist(lapply(content$contentItemList, function(e) as.data.frame(t(unlist(e)))))
#     d[, .(
#         id = fileId,
#         name = name,
#         # size = as.integer(size),
#         # originalSize = as.integer(size),
#         updated = convert_character_to_POSIXct(lastUpdatedTimestamp)
#         # folder
#     )]
# }


list_entsoe_files_online = function(
    folder, periodFrom, periodTo = Sys.time()
) {
    pageIndex = 0
    pageSize = 5000
  
    requestBody = list(
        topLevelFolder = "TP_export",
        pageInfo = list(
            pageIndex = pageIndex,
            pageSize = pageSize
        ),
        periodCovered = list(
            from = convert_POSIXct_to_character(periodFrom),
            to = convert_POSIXct_to_character(periodTo)
        ),
        typeSpecificAttributeMap = list(
            path = glue::glue("/TP_export/{folder}/")
        )
    )
    response = httr::POST(
        url = glue::glue("{e.pkg$urls$base}/listFileMetadata"),
        httr::add_headers(Authorization = glue::glue("Bearer {get_token()}")),
        body = jsonlite::toJSON(requestBody, auto_unbox = TRUE),
        httr::content_type("application/json"),
        httr::timeout(60)
    )

    if (httr::status_code(response) != 200) {
        stop(glue::glue("list_entsoe_files_online: {httr::status_code(response)}"))
    }

    content = httr::content(response)
    
    d = data.table::rbindlist(lapply(content$itemList, function(e) as.data.frame(t(unlist(e)))))
    if (nrow(d) == 0) {
        return(NULL)
    }
    d[, .(
        id = fileId,
        name = content.filename,
        size = as.integer(content.size),
        # originalSize = as.integer(content.originalSize),
        updated = convert_character_to_POSIXct(lastUpdatedTimestamp),
        from = convert_character_to_POSIXct(periodCovered.from),
        to = convert_character_to_POSIXct(periodCovered.to),
        folder = folder
    )]
}
