# Script to gather Zenodo projects for Alexander Bates
# Uses the zen4R package with authentication to retrieve depositions

library(zen4R)
library(dplyr)
library(tibble)

# Define %||% operator for NULL coalescing
`%||%` <- function(a, b) if (is.null(a)) b else a

# Function to get user's Zenodo depositions (authenticated)
get_zenodo_depositions <- function() {

  message("Connecting to Zenodo with authentication...")

  # Create Zenodo manager with token from environment
  # Token should be set in .Renviron as ZENODO_PAT
  zenodo <- tryCatch({
    ZenodoManager$new(logger = "INFO", token = Sys.getenv("ZENODO_PAT"))
  }, error = function(e) {
    message("Error creating Zenodo manager: ", e$message)
    message("Make sure ZENODO_PAT is set in .Renviron")
    return(NULL)
  })

  if (is.null(zenodo)) {
    return(tibble())
  }

  message("Fetching your depositions...")

  # Get all depositions
  depositions <- tryCatch({
    zenodo$getDepositions()
  }, error = function(e) {
    message("Error fetching depositions: ", e$message)
    return(list())
  })

  if (length(depositions) == 0) {
    message("No depositions found")
    return(tibble())
  }

  message("Found ", length(depositions), " depositions")

  # Filter to only published depositions and get latest version
  published_records <- list()

  for (deposition in depositions) {
    # Check if published (not a draft)
    if (!is.null(deposition$is_published) && deposition$is_published == TRUE) {
      # Get the published record
      doi <- tryCatch(deposition$getDOI(), error = function(e) NULL)
      if (!is.null(doi)) {
        published_records <- c(published_records, list(deposition))
      }
    }
  }

  if (length(published_records) == 0) {
    message("No published depositions found")
    return(tibble())
  }

  message("Found ", length(published_records), " published depositions")

  # Extract relevant information from published depositions
  records <- lapply(published_records, function(deposition) {
    metadata <- deposition$metadata

    # Get creators (can be people or organizations)
    creators_list <- metadata$creators
    if (!is.null(creators_list) && length(creators_list) > 0) {
      creators <- sapply(creators_list, function(c) {
        if (is.list(c)) {
          # Handle both person and organization structures
          if (!is.null(c$person_or_org)) {
            # New structure: person_or_org field
            if (!is.null(c$person_or_org$name)) {
              return(c$person_or_org$name)
            } else if (!is.null(c$person_or_org$family_name) && !is.null(c$person_or_org$given_name)) {
              return(paste(c$person_or_org$given_name, c$person_or_org$family_name))
            }
          }
          # Fallback: extract name directly
          if (!is.null(c$name)) {
            return(c$name)
          }
          # Last resort: use affiliation
          if (!is.null(c$affiliation)) {
            if (is.list(c$affiliation[[1]]) && !is.null(c$affiliation[[1]]$name)) {
              return(c$affiliation[[1]]$name)
            }
          }
          return("")
        } else {
          return(as.character(c))
        }
      })
      creators <- creators[creators != "" & !is.na(creators)]
      creators_str <- if (length(creators) > 0) paste(creators, collapse = ", ") else "Various authors"
    } else {
      creators_str <- "Various authors"
    }

    # Get DOI using method
    doi <- tryCatch(deposition$getDOI(), error = function(e) NA)

    # Get title
    title <- metadata$title %||% deposition$title %||% NA

    # Get publication date
    pub_date <- metadata$publication_date %||% deposition$created %||% NA

    # Get description (first 200 chars, strip HTML)
    description <- metadata$description %||% NA
    if (!is.na(description)) {
      # Strip HTML tags
      description <- gsub("<[^>]+>", "", description)
      description <- gsub("\\s+", " ", description)  # Clean whitespace
      description <- trimws(description)
      if (nchar(description) > 200) {
        description <- paste0(substr(description, 1, 200), "...")
      }
    }

    # Get resource type
    resource_type <- tryCatch({
      metadata$upload_type %||% metadata$resource_type$type %||% NA
    }, error = function(e) NA)

    # Get record ID for URL
    record_id <- tryCatch(deposition$getId(), error = function(e) NA)
    url <- if (!is.na(record_id)) {
      paste0("https://zenodo.org/records/", record_id)
    } else if (!is.na(doi)) {
      paste0("https://doi.org/", doi)
    } else {
      NA
    }

    # Get download statistics if available (all versions)
    downloads <- NA
    if (!is.null(deposition$stats)) {
      downloads <- tryCatch({
        deposition$stats$all_versions.downloads %||%
        deposition$stats$this_version.downloads %||% NA
      }, error = function(e) NA)
    }

    tibble(
      title = title,
      creators = creators_str,
      doi = doi,
      url = url,
      publication_date = pub_date,
      resource_type = resource_type,
      description = description,
      downloads = downloads
    )
  })

  records_df <- bind_rows(records)

  message("Successfully processed ", nrow(records_df), " records")
  return(records_df)
}

# Function to get records by ORCID (includes all records where user is a creator)
get_zenodo_records_by_orcid_authenticated <- function(orcid = "0000-0002-1195-0445") {

  message("Connecting to Zenodo with authentication...")

  zenodo <- tryCatch({
    ZenodoManager$new(logger = "INFO", token = Sys.getenv("ZENODO_PAT"))
  }, error = function(e) {
    message("Error creating Zenodo manager: ", e$message)
    message("Make sure ZENODO_PAT is set in .Renviron")
    return(NULL)
  })

  if (is.null(zenodo)) {
    return(tibble())
  }

  message("Searching for records with ORCID: ", orcid, "...")

  # Search for all published records where user is a creator
  records_list <- tryCatch({
    zenodo$getRecords(q = paste0("creators.orcid:", orcid), size = 100)
  }, error = function(e) {
    message("Error searching records: ", e$message)
    return(list())
  })

  if (length(records_list) == 0) {
    message("No Zenodo records found for ORCID: ", orcid)
    return(tibble())
  }

  message("Found ", length(records_list), " Zenodo records")

  # Extract relevant information from records
  records <- lapply(records_list, function(record) {
    metadata <- record$metadata

    # Get creators (can be people or organizations)
    creators_list <- metadata$creators
    if (!is.null(creators_list) && length(creators_list) > 0) {
      creators <- sapply(creators_list, function(c) {
        if (is.list(c)) {
          # Handle both person and organization structures
          if (!is.null(c$person_or_org)) {
            if (!is.null(c$person_or_org$name)) {
              return(c$person_or_org$name)
            } else if (!is.null(c$person_or_org$family_name) && !is.null(c$person_or_org$given_name)) {
              return(paste(c$person_or_org$given_name, c$person_or_org$family_name))
            }
          }
          if (!is.null(c$name)) {
            return(c$name)
          }
          return("")
        } else {
          return(as.character(c))
        }
      })
      creators <- creators[creators != "" & !is.na(creators)]
      creators_str <- if (length(creators) > 0) paste(creators, collapse = ", ") else "Various authors"
    } else {
      creators_str <- "Various authors"
    }

    # Get DOI
    doi <- tryCatch(metadata$doi, error = function(e) NA)

    # Get title
    title <- metadata$title %||% NA

    # Get publication date
    pub_date <- metadata$publication_date %||% NA

    # Get description (first 200 chars, strip HTML)
    description <- metadata$description %||% NA
    if (!is.na(description)) {
      description <- gsub("<[^>]+>", "", description)
      description <- gsub("\\s+", " ", description)
      description <- trimws(description)
      if (nchar(description) > 200) {
        description <- paste0(substr(description, 1, 200), "...")
      }
    }

    # Get resource type
    resource_type <- tryCatch({
      metadata$resource_type$type %||% metadata$upload_type %||% NA
    }, error = function(e) NA)

    # Get record ID for URL
    record_id <- tryCatch(record$id, error = function(e) NA)
    url <- if (!is.na(record_id)) {
      paste0("https://zenodo.org/records/", record_id)
    } else if (!is.na(doi)) {
      paste0("https://doi.org/", doi)
    } else {
      NA
    }

    # Get download statistics if available
    downloads <- NA
    if (!is.null(record$stats)) {
      downloads <- tryCatch({
        record$stats$all_versions.downloads %||%
        record$stats$this_version.downloads %||%
        record$stats$downloads %||% NA
      }, error = function(e) NA)
    }

    tibble(
      title = title,
      creators = creators_str,
      doi = doi,
      url = url,
      publication_date = pub_date,
      resource_type = resource_type,
      description = description,
      downloads = downloads
    )
  })

  records_df <- bind_rows(records)

  message("Successfully processed ", nrow(records_df), " records")
  return(records_df)
}

# Main function - search by ORCID to get all records where user is a creator
get_zenodo_records <- function() {
  return(get_zenodo_records_by_orcid_authenticated())
}

# Legacy function for ORCID search (fallback, not used)
get_zenodo_records_by_orcid <- function(orcid = "0000-0002-1195-0445") {

  message("Connecting to Zenodo...")

  # Create Zenodo manager (no token needed for public records)
  zenodo <- ZenodoManager$new(logger = "INFO")

  # Search for records by ORCID
  message("Searching for records with ORCID: ", orcid, "...")

  # Try multiple search strategies
  all_records_list <- list()

  # Strategy 1: ORCID search
  tryCatch({
    message("  Trying ORCID search...")
    records <- zenodo$getRecords(q = paste0("creators.orcid:", orcid), size = 100)
    if (length(records) > 0) {
      message("  Found ", length(records), " via ORCID")
      all_records_list <- c(all_records_list, records)
    }
  }, error = function(e) {
    message("  ORCID search error: ", e$message)
  })

  # Strategy 2: Name search
  tryCatch({
    message("  Trying name search...")
    records <- zenodo$getRecords(q = 'creators.name:"Bates"', size = 100)
    if (length(records) > 0) {
      message("  Found ", length(records), " via name")
      all_records_list <- c(all_records_list, records)
    }
  }, error = function(e) {
    message("  Name search error: ", e$message)
  })

  # Strategy 3: Keyword search for connectome/natverse projects
  tryCatch({
    message("  Trying keyword search...")
    records <- zenodo$getRecords(q = "Bates AND (connectome OR natverse OR hemibrain)", size = 100)
    if (length(records) > 0) {
      message("  Found ", length(records), " via keywords")
      all_records_list <- c(all_records_list, records)
    }
  }, error = function(e) {
    message("  Keyword search error: ", e$message)
  })

  # Remove duplicates based on record ID
  if (length(all_records_list) > 0) {
    record_ids <- sapply(all_records_list, function(r) r$id %||% r$record_id %||% NA)
    unique_indices <- !duplicated(record_ids)
    records_list <- all_records_list[unique_indices]
  } else {
    records_list <- list()
  }

  if (length(records_list) == 0) {
    message("No Zenodo records found.")
    return(tibble())
  }

  message("Found ", length(records_list), " Zenodo records")

  # Extract relevant information
  records <- lapply(records_list, function(record) {
    metadata <- record$metadata

    # Get creators
    creators_list <- metadata$creators
    if (!is.null(creators_list) && length(creators_list) > 0) {
      if (is.list(creators_list[[1]])) {
        creators <- sapply(creators_list, function(c) c$name %||% "")
      } else {
        creators <- as.character(creators_list)
      }
      creators_str <- paste(creators, collapse = ", ")
    } else {
      creators_str <- NA
    }

    # Get DOI
    doi <- metadata$doi %||% record$doi %||% NA

    # Get title
    title <- metadata$title %||% NA

    # Get publication date
    pub_date <- metadata$publication_date %||% NA

    # Get description (first 200 chars, strip HTML)
    description <- metadata$description %||% NA
    if (!is.na(description)) {
      # Strip HTML tags
      description <- gsub("<[^>]+>", "", description)
      description <- gsub("\\s+", " ", description)  # Clean whitespace
      description <- trimws(description)
      if (nchar(description) > 200) {
        description <- paste0(substr(description, 1, 200), "...")
      }
    }

    # Get resource type
    resource_type <- tryCatch({
      metadata$resource_type$type %||% metadata$upload_type %||% NA
    }, error = function(e) NA)

    # Get record ID for URL
    record_id <- record$id %||% record$record_id %||% NA
    url <- if (!is.na(record_id)) {
      paste0("https://zenodo.org/records/", record_id)
    } else {
      paste0("https://doi.org/", doi)
    }

    tibble(
      title = title,
      creators = creators_str,
      doi = doi,
      url = url,
      publication_date = pub_date,
      resource_type = resource_type,
      description = description
    )
  })

  records_df <- bind_rows(records)

  # Filter to only records where user is a creator (check ORCID or name)
  if (nrow(records_df) > 0) {
    records_df <- records_df %>%
      filter(grepl("Bates", creators, ignore.case = TRUE) | !is.na(creators))
  }

  message("Found ", nrow(records_df), " Zenodo records")
  return(records_df)
}

# Run the function
if (!interactive()) {
  zenodo_records <- get_zenodo_records()

  # Save to CSV
  if (nrow(zenodo_records) > 0) {
    write.csv(zenodo_records, "zenodo_projects.csv", row.names = FALSE)
    message("Saved Zenodo records to zenodo_projects.csv")
  }
}

# For sourcing in other scripts
zenodo_records <- get_zenodo_records()
