# Script to merge GitHub data correctly
# Combines verified natverse/wilson-lab repos with all htem/flyconnectome repos

library(dplyr)

# Read all repos
all_repos <- read.csv("github_org_all_repos.csv", stringsAsFactors = FALSE)

# Read the backup file that had correct natverse/wilson-lab data
# This file should have the 24 repos we got from the first successful run
backup_file <- "github_org_projects_backup.csv"

if (file.exists(backup_file)) {
  backup_data <- read.csv(backup_file, stringsAsFactors = FALSE)
  message("Loaded backup with ", nrow(backup_data), " repos")
}

# Get natverse and wilson-lab from old working data (without DeepCAD)
natverse_wilson <- all_repos %>%
  filter(organization %in% c("natverse", "wilson-lab")) %>%
  filter(name != "DeepCAD")

# Only check contributors for these (using a whitelist of known repos)
known_repos <- c(
  "nat", "flycircuit", "nat.examples", "nat.nblast", "rcatmaid", "elmr",
  "mouselightr", "fafbseg", "nat.h5reg", "drvid", "neuprintr", "neuromorphr",
  "natverse", "natverse_hugo", "insectbrainr", "fishatlas", "hemibrainr",
  "neuronbridger", "influencer", "nat.ggplot",
  "panels-matlab", "design-files", "nat-tech"  # wilson-lab repos (without DeepCAD)
)

natverse_wilson_filtered <- natverse_wilson %>%
  filter(name %in% known_repos) %>%
  mutate(is_contributor = TRUE)

# Get all htem and flyconnectome repos (user has blanket contribution)
htem_flyconnectome <- all_repos %>%
  filter(organization %in% c("htem", "flyconnectome")) %>%
  mutate(is_contributor = TRUE)

# Combine
final_repos <- bind_rows(natverse_wilson_filtered, htem_flyconnectome)

message("Final repo count: ", nrow(final_repos))
message("  - natverse: ", sum(final_repos$organization == "natverse"))
message("  - wilson-lab: ", sum(final_repos$organization == "wilson-lab"))
message("  - htem: ", sum(final_repos$organization == "htem"))
message("  - flyconnectome: ", sum(final_repos$organization == "flyconnectome"))

# Save
write.csv(final_repos, "github_org_projects.csv", row.names = FALSE)
message("\nSaved to github_org_projects.csv")

final_repos
