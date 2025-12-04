# Use Google Scholar author format directly
library(scholar)
library(dplyr)

# Read current data
pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Get fresh Google Scholar data
scholar_id <- "BOVTiXIAAAAJ&hl"
gs_pubs <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)
gs_pubs <- subset(gs_pubs, !journal %in% c("CHEMICAL SENSES", "University of Cambridge", ""))

# Update author lists to match Google Scholar format
for (i in 1:nrow(pub_data)) {
  title <- pub_data$title[i]

  # Skip thesis and Zenodo entries
  if (title == "The lateral horn, a brain region in the fly, primes innate olfactory behaviours by combining patterns of second-order olfactory projection neuron activity") {
    pub_data$author[i] <- "AS Bates"
    next
  }
  if (title == "Connectome Influence Calculator") {
    pub_data$author[i] <- "Z Ajabi, AS Bates, J Drugowitsch"
    next
  }

  # Find matching publication in Google Scholar data
  gs_match <- gs_pubs[gs_pubs$title == title, ]

  if (nrow(gs_match) > 0) {
    pub_data$author[i] <- gs_match$author[1]
  }
}

# Save updated data
write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)

cat("\nUpdated to Google Scholar author format!\n")
cat("Author format example:\n")
cat("  ", pub_data$author[1], "\n\n")
