# Get full citations with complete author lists and DOIs
library(scholar)
library(dplyr)
library(rcrossref)

# Read existing data
pub_data <- read.csv("publications_summary_data.csv", stringsAsFactors = FALSE)

# Function to get DOI from CrossRef
get_doi <- function(title, author_first) {
  tryCatch({
    # Search CrossRef
    results <- cr_works(query = title, limit = 5)

    if (!is.null(results) && nrow(results$data) > 0) {
      # Try to match by title
      for (i in 1:min(5, nrow(results$data))) {
        result_title <- tolower(results$data$title[i])
        search_title <- tolower(title)

        # Check if titles match (allowing for some variation)
        if (grepl(substr(search_title, 1, 30), result_title, fixed = TRUE)) {
          return(results$data$doi[i])
        }
      }
    }
    return(NA)
  }, error = function(e) {
    return(NA)
  })
}

# Known DOIs for major papers (manually curated)
known_dois <- list(
  "Distributed control circuits across a brain-and-cord connectome" = "10.1101/2025.07.31.667571",
  "Neuronal wiring diagram of an adult brain" = "10.1038/s41586-024-07558-y",
  "Whole-brain annotation and multi-connectome cell typing of Drosophila" = "10.1038/s41586-024-07686-5",
  "Network statistics of the whole-brain connectome of Drosophila" = "10.1038/s41586-024-07968-y",
  "A Drosophila computational brain model reveals sensorimotor processing" = "10.1038/s41586-024-07763-9",
  "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster" = "10.1016/j.cell.2024.04.016",
  "Comparative connectomics of Drosophila descending and ascending neurons" = "10.1038/s41586-025-08925-z",
  "Neural circuit mechanisms for steering control in walking Drosophila" = "10.7554/eLife.102230",
  "A connectome and analysis of the adult Drosophila central brain" = "10.7554/eLife.57443",
  "Complete connectomic reconstruction of olfactory projection neurons in the fly brain" = "10.1016/j.cub.2020.06.042",
  "Information flow, cell types and stereotypy in a full olfactory connectome" = "10.7554/eLife.66018",
  "The natverse, a versatile toolbox for combining and analysing neuroanatomical data" = "10.7554/eLife.53350",
  "The connectome of the adult Drosophila mushroom body provides insights into function" = "10.7554/eLife.62576",
  "BAcTrace, a tool for retrograde tracing of neuronal circuits in Drosophila" = "10.1038/s41592-020-00989-1",
  "Connectomics analysis reveals first-, second-, and third-order thermosensory and hygrosensory neurons in the adult Drosophila brain" = "10.1016/j.cub.2020.06.028",
  "Input connectivity reveals additional heterogeneity of dopaminergic reinforcement in Drosophila" = "10.1016/j.cub.2020.06.099",
  "Functional and anatomical specificity in a higher olfactory centre" = "10.7554/eLife.44590",
  "Neurogenetic dissection of the Drosophila lateral horn reveals major outputs, diverse behavioural functions, and interactions with the mushroom body" = "10.7554/eLife.43079",
  "Communication from learned to innate olfactory processing centers is required for memory retrieval in Drosophila" = "10.1016/j.neuron.2018.09.029",
  "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics" = "10.1016/j.conb.2018.12.012",
  "Combinatorial encoding of odors in the mosquito antennal lobe" = "10.1038/s41467-023-39303-w",
  "Discriminative attribution from paired images" = "10.1007/978-3-031-25069-9_27",
  "Systems neuroscience: Auditory processing at synaptic resolution" = "10.1016/j.cub.2022.07.018",
  "Analysis and optimization of equitable US cancer clinical trial center access by travel time" = "10.1001/jamaoncol.2024.0046"
)

# Add DOIs to data
pub_data$doi <- NA_character_
for (title in names(known_dois)) {
  pub_data$doi[pub_data$title == title] <- known_dois[[title]]
}

# Add Zenodo DOI
pub_data$doi[pub_data$title == "Connectome Influence Calculator"] <- "10.5281/zenodo.17693838"

# Save updated data
write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)

cat("\nDOIs added to publications!\n")
cat("Publications with DOIs:", sum(!is.na(pub_data$doi)), "/", nrow(pub_data), "\n")
