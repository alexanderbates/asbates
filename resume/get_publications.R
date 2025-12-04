library(scholar)

# Get all publications from Google Scholar
scholar_id <- "BOVTiXIAAAAJ&hl"
publications <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)

# Filter out unwanted entries
publications <- subset(publications, !journal %in% c("CHEMICAL SENSES","University of Cambridge",""))

# Clean up journal names
publications$journal[publications$journal %in% c("BioRxiv","Biorxiv","biorxiv")] <- "bioRxiv"
publications$journal <- gsub("Conference","Conf.",publications$journal)
publications$journal <- gsub("Current","Curr.",publications$journal)
publications$journal <- gsub("communications","Comm.",publications$journal)
publications$journal <- gsub("European","Euro.",publications$journal)
publications$journal <- gsub("Research","Res.",publications$journal)
publications$journal <- gsub("elife","eLife",publications$journal)
publications$journal <- gsub("Journal","J.",publications$journal)

# Order by year descending
publications <- publications[order(-publications$year),]

# Export for manual impact factor lookup
write.csv(publications, "publications_for_impact.csv", row.names = FALSE)

# Print summary
cat("Total publications found:", nrow(publications), "\n")
cat("Publications exported to: publications_for_impact.csv\n")
cat("\nJournals found:\n")
unique_journals <- sort(unique(publications$journal))
for(i in 1:length(unique_journals)) {
  cat(i, ". ", unique_journals[i], "\n", sep="")
}