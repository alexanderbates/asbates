# Master script to compile all Data and Code resources
# This script gathers information from Zenodo, GitHub, and other sources

library(dplyr)
library(tibble)
library(tidyr)

message("=== Compiling Data and Code Resources ===\n")

# 1. Get Zenodo projects
message("Step 1: Gathering Zenodo projects...")
tryCatch({
  source("get_zenodo_projects.R")
  zenodo_data <- zenodo_records
  message("✓ Zenodo data gathered: ", nrow(zenodo_data), " records\n")
}, error = function(e) {
  message("✗ Error gathering Zenodo data: ", e$message, "\n")
  zenodo_data <- tibble()
})

# 2. Get GitHub organization projects
message("Step 2: Loading GitHub organization projects...")
tryCatch({
  # Load the helper functions
  source("get_github_org_projects.R")

  # Check if we have all_repos saved, re-filter with updated logic
  if (file.exists("github_org_all_repos.csv")) {
    all_repos <- read.csv("github_org_all_repos.csv", stringsAsFactors = FALSE)
    message("✓ Loaded ", nrow(all_repos), " total repositories from file\n")

    # Re-filter with updated logic (includes htem/flyconnectome, excludes DeepCAD)
    github_data <- filter_user_repos(all_repos, username = "alexanderbates")
    message("✓ Filtered to ", nrow(github_data), " repositories\n")

    # Save the updated filtered list
    write.csv(github_data, "github_org_projects.csv", row.names = FALSE)
  } else if (file.exists("github_org_projects.csv")) {
    github_data <- read.csv("github_org_projects.csv", stringsAsFactors = FALSE)
    message("✓ Loaded existing GitHub data: ", nrow(github_data), " repositories\n")
  } else {
    # Gather fresh data
    github_data <- get_all_org_repos()
    github_data <- filter_user_repos(github_data)
    message("✓ GitHub data gathered: ", nrow(github_data), " repositories\n")
  }
}, error = function(e) {
  message("✗ Error loading GitHub data: ", e$message, "\n")
  github_data <- tibble()
})

# 3. Add Harvard Dataverse and other manually curated data sources
message("Step 3: Adding manually curated data sources...")
manual_sources <- tibble(
  type = c("dataverse"),
  title = c("BANC Adult Fly Brain Connectome"),
  description = c("Complete synaptic-resolution connectome of an adult female Drosophila melanogaster brain and ventral nerve cord"),
  url = c("https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8TFGGB"),
  doi = c("10.7910/DVN/8TFGGB"),
  organization = c("Harvard Dataverse")
)
message("✓ Added ", nrow(manual_sources), " manual sources\n")

# 4. Format Zenodo data for CV display
if (nrow(zenodo_data) > 0) {
  zenodo_formatted <- zenodo_data %>%
    mutate(
      type = "zenodo",
      display_title = paste0("[", title, "](https://doi.org/", doi, ")"),
      display_text = ifelse(!is.na(description),
                           paste0(display_title, " - ", description),
                           display_title),
      organization = "Zenodo"
    ) %>%
    select(type, title, description, url, doi, organization, display_text)
} else {
  zenodo_formatted <- tibble()
}

# 5. Format GitHub data for CV display
if (nrow(github_data) > 0) {
  github_formatted <- github_data %>%
    mutate(
      type = "github",
      title = name,
      display_title = paste0("[", name, "](", url, ")"),
      display_text = ifelse(!is.na(description),
                           paste0(display_title, " - ", description),
                           display_title),
      doi = NA_character_
    ) %>%
    select(type, title, description, url, doi, organization, display_text, language, stars)
} else {
  github_formatted <- tibble()
}

# 6. Format manual sources
manual_formatted <- manual_sources %>%
  mutate(
    display_title = paste0("[", title, "](", url, ")"),
    display_text = paste0(display_title, " - ", description)
  ) %>%
  select(type, title, description, url, doi, organization, display_text)

# 7. Combine all sources
all_data_sources <- bind_rows(
  manual_formatted,
  zenodo_formatted,
  github_formatted
)

# 8. Save combined data
write.csv(all_data_sources, "data_and_code_sources.csv", row.names = FALSE)
message("✓ Saved combined data to data_and_code_sources.csv\n")

# 9. Create summary statistics
message("=== Summary ===")
message("Total data sources: ", nrow(all_data_sources))
message("  - Manual sources: ", sum(all_data_sources$type == "dataverse"))
message("  - Zenodo records: ", sum(all_data_sources$type == "zenodo"))
message("  - GitHub repos: ", sum(all_data_sources$type == "github"))

# Group by organization
if (nrow(all_data_sources) > 0) {
  message("\nBy organization:")
  org_summary <- all_data_sources %>%
    group_by(organization) %>%
    summarise(count = n(), .groups = "drop") %>%
    arrange(desc(count))

  for (i in 1:nrow(org_summary)) {
    message("  - ", org_summary$organization[i], ": ", org_summary$count[i])
  }
}

message("\n=== Compilation Complete ===\n")

# Return the data for use in other scripts
all_data_sources
