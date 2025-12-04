# Fetch full author lists from Google Scholar
library(scholar)
library(dplyr)

scholar_id <- "BOVTiXIAAAAJ&hl"

# Get publications with full details
cat("Fetching publications from Google Scholar...\n")
publications <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)

# Filter out unwanted entries
publications <- subset(publications, !journal %in% c("CHEMICAL SENSES", "University of Cambridge", ""))

# Clean up journal names
publications$journal[publications$journal %in% c("BioRxiv", "Biorxiv", "biorxiv")] <- "bioRxiv"
publications$journal <- gsub("elife", "eLife", publications$journal, ignore.case = TRUE)

# Order by year
publications <- publications[order(-publications$year), ]

# Print author lists to inspect format
cat("\nAuthor lists from Google Scholar:\n")
cat("=================================\n\n")
for (i in 1:min(5, nrow(publications))) {
  cat("Paper:", publications$title[i], "\n")
  cat("Authors:", publications$author[i], "\n")
  cat("Year:", publications$year[i], "\n\n")
}

# Save the raw Google Scholar data
write.csv(publications, "google_scholar_raw.csv", row.names = FALSE)

cat("\nSaved to google_scholar_raw.csv\n")
cat("Total publications:", nrow(publications), "\n")
