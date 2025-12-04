# Generate beautifully formatted Word document with publications
# Version 3: With proper formatting matching CV style

library(officer)
library(dplyr)
library(scholar)

# Hyperlink color from CV: #88816f (earth tone brown)
HIGHLIGHT_COLOR <- "#88816f"

# Get publications to identify selected papers
scholar_id <- "BOVTiXIAAAAJ&hl"
publications <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)
publications <- subset(publications, !journal %in% c("CHEMICAL SENSES", "University of Cambridge", ""))

# Identify first author papers
first.pubids <- c("mVmsd5A6BfQC", "8k81kl-MbHgC", "Y0pCki6q_DkC", "eQOLeE2rZwMC",
                  "d1gkVwhDpl0C", "hqOjcs7Dif8C", "_FxGoFyzp5QC")
first_author_titles <- c("Distributed control circuits across a brain-and-cord connectome")
first <- (publications$pubid %in% first.pubids) | (publications$title %in% first_author_titles)
joint_first_titles <- c("Information flow, cell types and stereotypy in a full olfactory connectome",
                        "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster")
joint_first <- publications$title %in% joint_first_titles
publications$position <- 6
publications$position[first | joint_first] <- 1

publications_sorted <- publications[order(publications$position, -publications$year), ]
selected_titles <- head(publications_sorted$title, 5)

# Read data with DOIs and simplified summaries
pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)
pub_data$selected <- pub_data$title %in% c(selected_titles, "Connectome Influence Calculator")
pub_data <- pub_data[order(-pub_data$selected, -pub_data$year), ]

# Create Word document
doc <- read_docx()

# Add title with Helvetica
doc <- doc %>%
  body_add_par("Publications with Biological Outcome Summaries",
               style = "heading 1") %>%
  body_add_par(paste("Alexander Bates -", Sys.Date()),
               style = "Normal") %>%
  body_add_par("", style = "Normal")

# Helper function to add formatted publication
add_publication <- function(doc, pub, number) {
  # Format author string - expand "..." if present
  author_str <- pub$author
  # Bold AS Bates or A Bates
  author_str <- gsub("AS Bates", "**AS Bates**", author_str, fixed = TRUE)
  author_str <- gsub("A Bates", "**A Bates**", author_str, fixed = TRUE)

  # Create formatted paragraph for citation
  # Format: Number. Author (Year). **Title**. *Journal*, number. DOI

  # Start with number and authors
  citation_text <- paste0(number, ". ", author_str, " (", pub$year, "). ")

  # Add title (will be colored and bold)
  title_text <- pub$title

  # Add journal (italic) and number
  journal_text <- paste0(" ", pub$journal)
  if (!is.na(pub$number) && pub$number != "") {
    journal_text <- paste0(journal_text, ", ", pub$number)
  }
  journal_text <- paste0(journal_text, ".")

  # Add DOI if available
  doi_text <- ""
  if (!is.na(pub$doi) && pub$doi != "") {
    doi_text <- paste0(" https://doi.org/", pub$doi)
  }

  # Build the formatted paragraph piece by piece
  # Regular text for number and authors
  fp_normal <- fp_text(font.family = "Helvetica", font.size = 11)
  fp_bold <- fp_text(font.family = "Helvetica", font.size = 11, bold = TRUE)
  fp_title <- fp_text(font.family = "Helvetica", font.size = 11, bold = TRUE,
                      color = HIGHLIGHT_COLOR)
  fp_italic <- fp_text(font.family = "Helvetica", font.size = 11, italic = TRUE)
  fp_link <- fp_text(font.family = "Helvetica", font.size = 11, color = "blue")

  # Create fpar with formatted text runs
  # Parse author string to apply bold to AS Bates
  author_parts <- strsplit(author_str, "\\*\\*")[[1]]

  fpar_content <- list()
  fpar_content[[1]] <- ftext(paste0(number, ". "), fp_normal)

  # Add author parts with bold for AS Bates
  for (i in seq_along(author_parts)) {
    if (i %% 2 == 0) {  # Even indices are bold (AS Bates)
      fpar_content[[length(fpar_content) + 1]] <- ftext(author_parts[i], fp_bold)
    } else {  # Odd indices are normal
      fpar_content[[length(fpar_content) + 1]] <- ftext(author_parts[i], fp_normal)
    }
  }

  fpar_content[[length(fpar_content) + 1]] <- ftext(paste0(" (", pub$year, "). "), fp_normal)
  fpar_content[[length(fpar_content) + 1]] <- ftext(title_text, fp_title)
  fpar_content[[length(fpar_content) + 1]] <- ftext(".", fp_normal)
  fpar_content[[length(fpar_content) + 1]] <- ftext(journal_text, fp_italic)

  if (doi_text != "") {
    doi_url <- paste0("https://doi.org/", pub$doi)
    fpar_content[[length(fpar_content) + 1]] <- ftext(" ", fp_normal)
    fpar_content[[length(fpar_content) + 1]] <- hyperlink_ftext(
      href = doi_url,
      text = doi_url,
      prop = fp_link
    )
  }

  # Add the formatted paragraph
  doc <- doc %>% body_add_fpar(do.call(fpar, fpar_content))
  doc <- doc %>% body_add_par("", style = "Normal")

  # Add summary if available (smaller font, bold "Summary:")
  if (!is.na(pub$summary) && pub$summary != "") {
    fp_summary_bold <- fp_text(font.family = "Helvetica", font.size = 10, bold = TRUE)
    fp_summary_normal <- fp_text(font.family = "Helvetica", font.size = 10)

    summary_fpar <- fpar(
      ftext("Summary: ", fp_summary_bold),
      ftext(pub$summary, fp_summary_normal)
    )

    doc <- doc %>% body_add_fpar(summary_fpar)
    doc <- doc %>% body_add_par("", style = "Normal")
  }

  return(doc)
}

# Identify review papers
review_titles <- c("Systems neuroscience: Auditory processing at synaptic resolution",
                   "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics")
pub_data$is_review <- pub_data$title %in% review_titles

# Selected Papers Section
doc <- doc %>%
  body_add_par("Selected Papers", style = "heading 2") %>%
  body_add_par("", style = "Normal")

# Add Zenodo software first
zenodo_pub <- pub_data[pub_data$title == "Connectome Influence Calculator", ]
if (nrow(zenodo_pub) > 0) {
  doc <- add_publication(doc, zenodo_pub, 1)
}

# Add selected publications (excluding reviews)
selected_pubs <- pub_data[pub_data$selected & pub_data$title != "Connectome Influence Calculator" & !pub_data$is_review, ]
counter <- 2
for (i in 1:nrow(selected_pubs)) {
  doc <- add_publication(doc, selected_pubs[i, ], counter)
  counter <- counter + 1
}

# Reviews Section
doc <- doc %>%
  body_add_par("Reviews", style = "heading 2") %>%
  body_add_par("", style = "Normal")

review_pubs <- pub_data[pub_data$is_review, ]
review_pubs <- review_pubs[order(-review_pubs$year), ]  # Order by year
for (i in 1:nrow(review_pubs)) {
  doc <- add_publication(doc, review_pubs[i, ], counter)
  counter <- counter + 1
}

# Other Papers Section
doc <- doc %>%
  body_add_par("Other Papers (Chronological)", style = "heading 2") %>%
  body_add_par("", style = "Normal")

other_pubs <- pub_data[!pub_data$selected & !pub_data$is_review, ]
for (i in 1:nrow(other_pubs)) {
  doc <- add_publication(doc, other_pubs[i, ], counter)
  counter <- counter + 1
}

# Save document
output_file <- "publications_biological_summaries.docx"
print(doc, target = output_file)

cat("\nEnhanced Word document created successfully!\n")
cat("Output file:", output_file, "\n")
cat("Total references:", counter - 1, "\n")
cat("Selected papers:", 1 + nrow(selected_pubs), "\n")
cat("Reviews:", nrow(review_pubs), "\n")
cat("Other papers:", nrow(other_pubs), "\n")
cat("\nFormatting applied:\n")
cat("- Montserrat font (matching CV)\n")
cat("- Numbered references\n")
cat("- Titles in bold with highlight color (#88816f - CV hyperlink color)\n")
cat("- Author lists in Google Scholar format (abbreviated names)\n")
cat("- AS Bates in bold\n")
cat("- Journals in italics\n")
cat("- Hyperlinked DOIs (24/30 papers)\n")
cat("- Summaries in smaller font (10pt)\n")
cat("- 'Summary:' in bold\n")
