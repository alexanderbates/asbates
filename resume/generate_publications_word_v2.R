# Generate Word Document with Publication Summaries
# Version 2: Organized into Selected and Other Papers sections

library(officer)
library(dplyr)
library(scholar)

# Get publications to identify which are "selected" (top 5 first author papers)
scholar_id <- "BOVTiXIAAAAJ&hl"
publications <- get_publications(scholar_id, sortby = "year", pagesize = 100, flush = TRUE)
publications <- subset(publications, !journal %in% c("CHEMICAL SENSES", "University of Cambridge", ""))

# Identify first author papers (matching cv_builder.Rmd logic)
first.pubids <- c("mVmsd5A6BfQC", "8k81kl-MbHgC", "Y0pCki6q_DkC", "eQOLeE2rZwMC",
                  "d1gkVwhDpl0C", "hqOjcs7Dif8C", "_FxGoFyzp5QC")
first_author_titles <- c("Distributed control circuits across a brain-and-cord connectome")
first_by_pubid <- publications$pubid %in% first.pubids
first_by_title <- publications$title %in% first_author_titles
first <- first_by_pubid | first_by_title
publications$position <- 6
publications$position[first] <- 1

# Joint first author papers
joint_first_titles <- c("Information flow, cell types and stereotypy in a full olfactory connectome",
                        "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster")
joint_first <- publications$title %in% joint_first_titles
publications$position[joint_first] <- 1

# Get top 5 first author papers (these are "selected")
publications_sorted <- publications[order(publications$position, -publications$year), ]
selected_titles <- head(publications_sorted$title, 5)

# Read the summary data
pub_data <- read.csv("publications_summary_data.csv", stringsAsFactors = FALSE)

# Add Zenodo software citation
zenodo_entry <- data.frame(
  title = "Connectome Influence Calculator",
  author = "Zaki Ajabi, Alexander S. Bates, Jan Drugowitsch",
  journal = "Zenodo",
  number = "DOI: 10.5281/zenodo.17693838",
  year = 2025,
  cites = NA,
  pubid = "zenodo_17693838",
  summary = "This R package and Python software computes neural influence scores in connectomes using linear dynamical models of signal propagation, quantifying how strongly neurons or neuron groups influence downstream neural activity through both direct and indirect connectivity effects. Originally developed for the BANC (Brain and Nerve Cord) Drosophila connectome, the tool implements algorithms to calculate steady-state neural responses to simulated stimulation, enabling researchers to identify which neurons functionally control information flow through neural circuits beyond simple anatomical connectivity patterns.",
  stringsAsFactors = FALSE
)

# Mark selected vs other
pub_data$selected <- pub_data$title %in% c(selected_titles, "Connectome Influence Calculator")
pub_data <- pub_data[order(-pub_data$selected, -pub_data$year), ]

# Create Word document
doc <- read_docx()

# Add title
doc <- doc %>%
  body_add_par("Publications with Biological Outcome Summaries", style = "heading 1") %>%
  body_add_par(paste("Alexander Bates - Generated", Sys.Date()), style = "Normal") %>%
  body_add_par("", style = "Normal")

# Selected Papers Section
doc <- doc %>%
  body_add_par("Selected Papers", style = "heading 2") %>%
  body_add_par("", style = "Normal")

# Add Zenodo entry first
doc <- doc %>%
  body_add_par(paste0(zenodo_entry$author, " (", zenodo_entry$year, "). ",
                      zenodo_entry$title, ". ", zenodo_entry$journal, ", ",
                      zenodo_entry$number, "."), style = "Normal") %>%
  body_add_par("", style = "Normal") %>%
  body_add_par(paste("Summary:", zenodo_entry$summary), style = "Normal") %>%
  body_add_par("", style = "Normal") %>%
  body_add_par("", style = "Normal")

# Add selected publications
selected_pubs <- pub_data[pub_data$selected & pub_data$title != "Connectome Influence Calculator", ]
for (i in 1:nrow(selected_pubs)) {
  pub <- selected_pubs[i, ]

  citation <- paste0(pub$author, " (", pub$year, "). ", pub$title, ". ", pub$journal)
  if (!is.na(pub$number) && pub$number != "") {
    citation <- paste0(citation, ", ", pub$number)
  }
  citation <- paste0(citation, ".")

  doc <- doc %>%
    body_add_par(citation, style = "Normal") %>%
    body_add_par("", style = "Normal")

  if (!is.na(pub$summary) && pub$summary != "") {
    doc <- doc %>%
      body_add_par(paste("Summary:", pub$summary), style = "Normal") %>%
      body_add_par("", style = "Normal")
  }

  doc <- doc %>% body_add_par("", style = "Normal")
}

# Other Papers Section
doc <- doc %>%
  body_add_par("Other Papers (Chronological)", style = "heading 2") %>%
  body_add_par("", style = "Normal")

other_pubs <- pub_data[!pub_data$selected, ]
for (i in 1:nrow(other_pubs)) {
  pub <- other_pubs[i, ]

  citation <- paste0(pub$author, " (", pub$year, "). ", pub$title, ". ", pub$journal)
  if (!is.na(pub$number) && pub$number != "") {
    citation <- paste0(citation, ", ", pub$number)
  }
  citation <- paste0(citation, ".")

  doc <- doc %>%
    body_add_par(citation, style = "Normal") %>%
    body_add_par("", style = "Normal")

  if (!is.na(pub$summary) && pub$summary != "") {
    doc <- doc %>%
      body_add_par(paste("Summary:", pub$summary), style = "Normal") %>%
      body_add_par("", style = "Normal")
  }

  doc <- doc %>% body_add_par("", style = "Normal")
}

# Save document
output_file <- "publications_biological_summaries.docx"
print(doc, target = output_file)

cat("\nWord document created successfully!\n")
cat("Output file:", output_file, "\n")
cat("Selected papers:", sum(pub_data$selected), "\n")
cat("Other papers:", sum(!pub_data$selected), "\n")
cat("Total publications:", nrow(pub_data), "\n")
