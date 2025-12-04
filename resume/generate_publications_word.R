# Generate Word Document with Publication Summaries
# This script takes the publications_summary_data.csv and creates a formatted Word document

library(officer)
library(dplyr)

# Read the summary data
pub_data <- read.csv("publications_summary_data.csv", stringsAsFactors = FALSE)

# Create Word document
doc <- read_docx()

# Add title
doc <- doc %>%
  body_add_par("Publications with Biological Outcome Summaries", style = "heading 1") %>%
  body_add_par(paste("Alexander Bates - Generated", Sys.Date()), style = "Normal") %>%
  body_add_par("", style = "Normal")

# Function to format author list (bold AS Bates)
format_authors <- function(authors) {
  # This will be plain text for now, Word formatting can be added if needed
  authors <- gsub("AS Bates", "**AS Bates**", authors)
  return(authors)
}

# Add each publication
for (i in 1:nrow(pub_data)) {
  pub <- pub_data[i, ]

  # Format citation
  citation <- paste0(
    pub$author, " (",
    pub$year, "). ",
    pub$title, ". ",
    pub$journal
  )

  if (!is.na(pub$number) && pub$number != "") {
    citation <- paste0(citation, ", ", pub$number)
  }

  citation <- paste0(citation, ".")

  # Add citation
  doc <- doc %>%
    body_add_par(citation, style = "Normal") %>%
    body_add_par("", style = "Normal")

  # Add summary if available
  if (!is.na(pub$summary) && pub$summary != "") {
    doc <- doc %>%
      body_add_par(paste("Summary:", pub$summary), style = "Normal") %>%
      body_add_par("", style = "Normal")
  }

  # Add spacing between entries
  doc <- doc %>% body_add_par("", style = "Normal")
}

# Save document
output_file <- "publications_biological_summaries.docx"
print(doc, target = output_file)

cat("\nWord document created successfully!\n")
cat("Output file:", output_file, "\n")
cat("Total publications:", nrow(pub_data), "\n")
