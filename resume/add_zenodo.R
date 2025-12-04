# Add Zenodo Connectome Influence Calculator entry back to publications
library(dplyr)

pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Create Zenodo entry
zenodo_entry <- data.frame(
  title = "Connectome Influence Calculator",
  author = "Z Ajabi, AS Bates, J Drugowitsch",
  journal = "Zenodo",
  number = "",
  year = 2024,
  cites = 0,
  pubid = "zenodo",
  summary = "A computational tool for quantifying neural circuit influence through connectome analysis. The software calculates how neurons influence downstream targets using graph theoretical methods to identify key circuit elements.",
  doi = "10.5281/zenodo.17693838",
  stringsAsFactors = FALSE
)

# Add to beginning of dataframe (so it appears first in selected papers)
pub_data <- rbind(zenodo_entry, pub_data)

# Save updated data
write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)

cat("\nZenodo entry added!\n")
cat("Total publications:", nrow(pub_data), "\n")
