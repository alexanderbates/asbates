# Script to get CRAN download statistics for R packages
# Uses the cranlogs package to retrieve download counts

library(dplyr)
library(tibble)

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install cranlogs if not available
if (!requireNamespace("cranlogs", quietly = TRUE)) {
  install.packages("cranlogs")
}
library(cranlogs)

# Define %||% operator for NULL coalescing
`%||%` <- function(a, b) if (is.null(a) || is.na(a)) b else a

# Function to get CRAN download statistics for a package
get_cran_downloads <- function(package_name, from = "2015-01-01", to = Sys.Date()) {
  message("Fetching download stats for package: ", package_name)

  tryCatch({
    # Get total downloads from specified start date to today
    downloads <- cranlogs::cran_downloads(
      packages = package_name,
      from = from,
      to = to
    )

    if (is.null(downloads) || nrow(downloads) == 0) {
      message("  No download data found for ", package_name)
      return(NA_integer_)
    }

    total <- sum(downloads$count, na.rm = TRUE)
    message("  Total downloads: ", format(total, big.mark = ","))
    return(total)

  }, error = function(e) {
    message("  Error fetching downloads for ", package_name, ": ", e$message)
    return(NA_integer_)
  })
}

# Function to check if a package is on CRAN
is_on_cran <- function(package_name) {
  tryCatch({
    # Try to get package info from CRAN
    tools::CRAN_package_db() %>%
      filter(Package == package_name) %>%
      nrow() > 0
  }, error = function(e) {
    FALSE
  })
}

# List of R packages from the CV (based on GitHub repos with language = "R")
r_packages <- c(
  "nat",           # Main NeuroAnatomy Toolbox
  "flycircuit",    # FlyCircuit data access
  "nat.nblast",    # NBLAST algorithm
  "rcatmaid",      # CATMAID API access
  "elmr",          # EM/LM fly brain data
  "mouselightr",   # MouseLight bridge
  "fafbseg",       # FAFB-FlyWire support
  "nat.h5reg",     # HDF5 registration
  "drvid",         # DVID API access
  "neuprintr",     # neuPrint client
  "neuromorphr",   # neuromorpho.org client
  "natverse",      # Umbrella package
  "insectbrainr",  # InsectBrainDB client
  "fishatlas",     # Fish Brain Atlas client
  "hemibrainr",    # Hemibrain data
  "neuronbridger", # NeuronBridge client
  "influencer",    # Connectivity scores
  "nat.ggplot"     # ggplot2 rendering
  # Note: bancr and crantr are not on CRAN (flyconnectome packages)
)

# Function to get downloads for all packages
get_all_package_downloads <- function(packages) {

  message("Checking CRAN availability and fetching download statistics...")
  message("This may take a few minutes...\n")

  results <- tibble(
    package = character(),
    on_cran = logical(),
    total_downloads = integer()
  )

  for (pkg in packages) {
    message("\n=== ", pkg, " ===")

    # Check if on CRAN
    on_cran <- tryCatch({
      # Simple test: try to get downloads for 1 day
      test <- cranlogs::cran_downloads(pkg, from = Sys.Date() - 1, to = Sys.Date())
      !is.null(test) && nrow(test) > 0
    }, error = function(e) FALSE)

    if (!on_cran) {
      message("  Not on CRAN or no download data available")
      results <- bind_rows(results, tibble(
        package = pkg,
        on_cran = FALSE,
        total_downloads = NA_integer_
      ))
      next
    }

    message("  On CRAN - fetching download statistics...")

    # Get total downloads from package publication date or 2015 (whichever is later)
    downloads <- get_cran_downloads(pkg, from = "2015-01-01")

    results <- bind_rows(results, tibble(
      package = pkg,
      on_cran = TRUE,
      total_downloads = downloads
    ))

    # Small delay to be nice to CRAN servers
    Sys.sleep(0.1)
  }

  return(results)
}

# Main execution
if (!interactive()) {
  message("Starting CRAN download statistics collection...")
  message("Date: ", Sys.Date(), "\n")

  package_stats <- get_all_package_downloads(r_packages)

  # Save to CSV
  if (nrow(package_stats) > 0) {
    write.csv(package_stats, "cran_download_stats.csv", row.names = FALSE)
    message("\n===========================================")
    message("Saved CRAN download statistics to cran_download_stats.csv")
    message("===========================================\n")

    # Print summary
    message("Summary:")
    message("  Total packages checked: ", nrow(package_stats))
    message("  On CRAN: ", sum(package_stats$on_cran, na.rm = TRUE))
    message("  Not on CRAN: ", sum(!package_stats$on_cran, na.rm = TRUE))
    message("  Total downloads (CRAN only): ",
            format(sum(package_stats$total_downloads, na.rm = TRUE), big.mark = ","))
  }
}

# For sourcing in other scripts
get_package_downloads <- function() {
  return(get_all_package_downloads(r_packages))
}

# Run if sourced
package_download_stats <- get_package_downloads()
