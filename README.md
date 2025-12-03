# entsoe.file.api

> [!WARNING]  
> Under development

The [ENTSO-E File Library API](https://transparencyplatform.zendesk.com/hc/en-us/articles/35960137882129-File-Library-Guide) is the replacement for the discontinued SFTP access.

This R package is a wrapper around this [API](https://documenter.getpostman.com/view/28274243/2sB2qgfz3W#b7c7695c-ab81-4100-9c3a-cde1a4cf46ac) and provides:
  - Transparent authentication
  - Simple retrieval by ENTSO‑E folder names
  - ZIP-compressed downloads
  - Transparent local caching via file update timestamps
  - Compact, fast, readable `parquet` cache files

## Installation

```r
# Install from GitHub
devtools::install_github("energy-monitor/entsoe.file.api")
```


## Usage

```r
library(entsoe.file.api)

# Set up caching
set_entsoe_cache("cache")

# Set up authentication
set_entsoe_credentials("username", "password")

# Get available folders
get_entsoe_folders()

# Download data
load_entsoe_data(
    "EnergyPrices_12.1.D_r3", from = "2025-01-01"
)
```

## Licence

GPL-3
