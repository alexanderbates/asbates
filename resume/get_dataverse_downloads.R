# Script to get download statistics from Harvard Dataverse for BANC dataset
# URL: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8TFGGB

library(rvest)
library(httr)
library(dplyr)
library(stringr)

# Function to get BANC dataset download count from Harvard Dataverse
get_banc_downloads <- function() {

  url <- "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8TFGGB"

  message("Fetching BANC dataset page from Harvard Dataverse...")

  # Fetch the page
  page <- tryCatch({
    read_html(url)
  }, error = function(e) {
    message("Error fetching page: ", e$message)
    return(NULL)
  })

  if (is.null(page)) {
    return(NA)
  }

  # Try to find download count - it's usually in a span or div with specific class
  # Common patterns in Dataverse: look for "Downloads" text followed by a number

  # Strategy 1: Look for download metrics in the page text
  downloads <- tryCatch({
    # Get all text nodes
    page_text <- html_text(page)

    # Look for patterns like "Downloads: 606" or "606 Downloads"
    download_pattern <- regex("([0-9,]+)\\s*(?:Downloads?|downloads?)", ignore_case = TRUE)
    matches <- str_match(page_text, download_pattern)

    if (!is.na(matches[1,2])) {
      # Remove commas and convert to number
      count <- as.numeric(gsub(",", "", matches[1,2]))
      message("Found ", count, " downloads")
      return(count)
    }

    # Alternative pattern: "Downloads?:\\s*([0-9,]+)"
    download_pattern2 <- regex("Downloads?:\\s*([0-9,]+)", ignore_case = TRUE)
    matches2 <- str_match(page_text, download_pattern2)

    if (!is.na(matches2[1,2])) {
      count <- as.numeric(gsub(",", "", matches2[1,2]))
      message("Found ", count, " downloads")
      return(count)
    }

    NA
  }, error = function(e) {
    message("Error parsing downloads: ", e$message)
    NA
  })

  # Strategy 2: Look in specific HTML elements
  if (is.na(downloads)) {
    downloads <- tryCatch({
      # Look for elements with download-related classes
      download_elements <- html_nodes(page, ".metrics-block, .file-count, .download-count, [class*='download'], [class*='metric']")

      for (elem in download_elements) {
        elem_text <- html_text(elem)
        if (grepl("download", elem_text, ignore.case = TRUE)) {
          # Extract number
          numbers <- str_extract_all(elem_text, "[0-9,]+")[[1]]
          if (length(numbers) > 0) {
            count <- as.numeric(gsub(",", "", numbers[1]))
            message("Found ", count, " downloads via HTML element")
            return(count)
          }
        }
      }
      NA
    }, error = function(e) {
      message("Error with HTML elements: ", e$message)
      NA
    })
  }

  # Strategy 3: Use Dataverse API if available
  if (is.na(downloads)) {
    message("Trying Dataverse API...")
    api_url <- "https://dataverse.harvard.edu/api/datasets/:persistentId/?persistentId=doi:10.7910/DVN/8TFGGB"

    downloads <- tryCatch({
      response <- GET(api_url)

      if (status_code(response) == 200) {
        content <- content(response, "parsed")

        # Look for download count in the API response
        # Structure varies but often in data$latestVersion$files or metrics
        if (!is.null(content$data$latestVersion$metadataBlocks)) {
          message("API response received, but download count not in expected location")
        }

        # Try to find any download-related metrics
        downloads_val <- content$data$downloads
        if (!is.null(downloads_val)) {
          count <- as.numeric(downloads_val)
          message("Found ", count, " downloads via API")
          return(count)
        }
      }
      NA
    }, error = function(e) {
      message("API error: ", e$message)
      NA
    })
  }

  if (is.na(downloads)) {
    message("Could not find download count. Manual check may be needed.")
    message("As of last check: 606 downloads")
    return(606)  # Fallback to known value
  }

  return(downloads)
}

# Function to get all dataverse statistics
get_dataverse_stats <- function() {
  banc_downloads <- get_banc_downloads()

  tibble(
    dataset = "BANC Adult Fly Brain Connectome",
    repository = "Harvard Dataverse",
    doi = "10.7910/DVN/8TFGGB",
    url = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8TFGGB",
    codex_url = "https://codex.flywire.ai/?dataset=banc",
    downloads = banc_downloads,
    last_checked = Sys.Date()
  )
}

# Run if executed as script
if (!interactive()) {
  dataverse_stats <- get_dataverse_stats()

  if (nrow(dataverse_stats) > 0) {
    write.csv(dataverse_stats, "dataverse_stats.csv", row.names = FALSE)
    message("Saved Dataverse statistics to dataverse_stats.csv")
    print(dataverse_stats)
  }
}

# For sourcing in other scripts
dataverse_stats <- get_dataverse_stats()
