# Create Publications Summary Document with Biological Outcomes
# This script fetches publications and prepares them for summary generation

library(scholar)
library(dplyr)
library(officer)  # For creating Word documents
library(flextable)

# Get publications from Google Scholar
scholar_id <- "BOVTiXIAAAAJ&hl"
publications <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)

# Filter out unwanted entries
publications <- subset(publications, !journal %in% c("CHEMICAL SENSES", "University of Cambridge", ""))

# Clean up journal names
publications$journal[publications$journal %in% c("BioRxiv", "Biorxiv", "biorxiv")] <- "bioRxiv"
publications$journal <- gsub("elife", "eLife", publications$journal, ignore.case = TRUE)

# Manual correction for the BANC paper
banc_corr <- grepl("Distributed control circuits", publications$title, ignore.case = TRUE)
publications$journal[banc_corr] <- "bioRxiv, in review at Nature"

# Order by year descending
publications <- publications[order(-publications$year), ]

# Create a summary dataframe
pub_summary <- data.frame(
  title = publications$title,
  author = publications$author,
  journal = publications$journal,
  number = publications$number,
  year = publications$year,
  cites = publications$cites,
  pubid = publications$pubid,
  summary = NA_character_,  # To be filled with biological summaries
  stringsAsFactors = FALSE
)

# Add thesis entry
thesis_entry <- data.frame(
  title = "The lateral horn, a brain region in the fly, primes innate olfactory behaviours by combining patterns of second-order olfactory projection neuron activity",
  author = "AS Bates",
  journal = "PhD Thesis, University of Cambridge",
  number = "",
  year = 2020,
  cites = NA,
  pubid = "thesis",
  summary = "This PhD thesis investigated how the lateral horn in Drosophila processes olfactory information to drive innate behaviors, using connectomics and neural circuit reconstruction to map second-order projection neuron patterns. The work developed computational tools for analyzing neural networks and demonstrated how memory systems interact with innate olfactory processing centers. Awards: MRC LMB Max Perutz Prize 2019, British Neuroscience Association Postgraduate Prize 2020.",
  stringsAsFactors = FALSE
)

# Combine with publications
pub_summary <- rbind(pub_summary, thesis_entry)
pub_summary <- pub_summary[order(-pub_summary$year), ]

# Save to CSV for manual editing/population
write.csv(pub_summary, "publications_summary_data.csv", row.names = FALSE)

cat("\nPublications summary template created!\n")
cat("Total publications:", nrow(pub_summary), "\n")
cat("Saved to: publications_summary_data.csv\n")
cat("\nNext steps:\n")
cat("1. Run fetch_publication_abstracts.R to get paper abstracts\n")
cat("2. Generate summaries (can be done manually or with AI assistance)\n")
cat("3. Run generate_publications_word.R to create the Word document\n")
