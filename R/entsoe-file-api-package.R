#' @keywords internal
"_PACKAGE"

#' @import data.table
#' @importFrom utils unzip

globalVariables(c(":=", "."))

# Package environment
e.pkg = new.env(parent = emptyenv())

e.pkg$urls = list(
    base = "https://fms.tp.entsoe.eu",
    keycloak = "https://keycloak.tp.entsoe.eu/realms/tp/protocol/openid-connect/token"
)

e.pkg$cache = list(
    folder = "entsoe-cache",
    enabled = FALSE
)

NULL
