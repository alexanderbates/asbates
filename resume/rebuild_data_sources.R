# Rebuild data_and_code_sources.csv using correct GitHub data

library(dplyr)
library(tibble)

# Load the filtered GitHub data (only repos with commits by user)
github_data <- read.csv("github_org_projects_filtered.csv", stringsAsFactors = FALSE)
message("Loaded ", nrow(github_data), " GitHub repositories with user commits")

# Load Zenodo data if available
zenodo_data <- tibble()
if (file.exists("zenodo_projects.csv")) {
  zenodo_data <- read.csv("zenodo_projects.csv", stringsAsFactors = FALSE)
  message("Loaded ", nrow(zenodo_data), " Zenodo records")
}

# Add Harvard Dataverse
manual_sources <- tibble(
  type = c("dataverse"),
  title = c("BANC Adult Fly Brain Connectome"),
  description = c("Complete synaptic-resolution connectome of an adult female Drosophila melanogaster brain and ventral nerve cord"),
  url = c("https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8TFGGB"),
  doi = c("10.7910/DVN/8TFGGB"),
  organization = c("Harvard Dataverse")
)

# Format GitHub data
github_formatted <- github_data %>%
  mutate(
    type = "github",
    title = name,
    display_title = paste0("[", name, "](", url, ")"),
    display_text = ifelse(!is.na(description) & description != "",
                         paste0(display_title, " - ", description),
                         display_title),
    doi = NA_character_,
    downloads = NA_integer_
  ) %>%
  select(type, title, description, url, doi, organization, display_text, language, stars, downloads)

# Format manual sources
manual_formatted <- manual_sources %>%
  mutate(
    display_title = paste0("[", title, "](", url, ")"),
    display_text = paste0(display_title, " - ", description),
    language = NA_character_,
    stars = NA_integer_,
    downloads = NA_integer_
  ) %>%
  select(type, title, description, url, doi, organization, display_text, language, stars, downloads)

# Format Zenodo data
zenodo_formatted <- tibble()
if (nrow(zenodo_data) > 0) {
  zenodo_formatted <- zenodo_data %>%
    mutate(
      type = "zenodo",
      organization = "Zenodo",
      display_title = paste0("[", title, "](", url, ")"),
      display_text = ifelse(!is.na(description) & description != "",
                           paste0(display_title, " - ", description),
                           display_title),
      language = NA_character_,
      stars = NA_integer_
    ) %>%
    select(type, title, description, url, doi, organization, display_text, language, stars, downloads)
}

# Combine
all_data_sources <- bind_rows(manual_formatted, github_formatted, zenodo_formatted)

# Save
write.csv(all_data_sources, "data_and_code_sources.csv", row.names = FALSE)

message("\n=== Summary ===")
message("Total: ", nrow(all_data_sources))
message("  - Harvard Dataverse: 1")
message("  - Zenodo: ", sum(all_data_sources$organization == "Zenodo"))
message("  - natverse: ", sum(all_data_sources$organization == "natverse"))
message("  - wilson-lab: ", sum(all_data_sources$organization == "wilson-lab"))
message("  - htem: ", sum(all_data_sources$organization == "htem"))
message("  - flyconnectome: ", sum(all_data_sources$organization == "flyconnectome"))

all_data_sources
