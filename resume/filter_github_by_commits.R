# Filter GitHub repos by checking actual commit history
# Uses cached repo data from github_org_all_repos.csv

library(httr)
library(jsonlite)
library(dplyr)
library(tibble)

# Load cached repo data
all_repos <- read.csv("github_org_all_repos.csv", stringsAsFactors = FALSE)
message("Loaded ", nrow(all_repos), " repositories from cache")

# Function to check if user has made any commits to a repo
check_has_commits <- function(org_name, repo_name, username = "alexanderbates") {
  url <- paste0("https://api.github.com/repos/", org_name, "/", repo_name, "/commits")

  # Check for commits by this author (just need 1 to confirm)
  response <- GET(url, query = list(author = username, per_page = 1))

  if (status_code(response) != 200) {
    # Could be 404 (no commits), 403 (rate limit), or other error
    if (status_code(response) == 404) {
      return(FALSE)
    }
    # For rate limiting or other errors, return FALSE but warn
    if (status_code(response) == 403) {
      warning("Rate limit hit for ", org_name, "/", repo_name)
      # Sleep longer on rate limit
      Sys.sleep(60)
    }
    return(FALSE)
  }

  commits <- content(response, as = "parsed")

  # If we got any commits back, user has contributed
  return(length(commits) > 0)
}

# Filter repos by commit history
exclude_repos <- c("DeepCAD")

all_repos$has_commits <- FALSE

message("Checking commit history for ", nrow(all_repos), " repositories...")
message("This may take several minutes...")

for (i in 1:nrow(all_repos)) {
  org <- all_repos$organization[i]
  repo_name <- all_repos$name[i]

  # Skip excluded repos
  if (repo_name %in% exclude_repos) {
    message("  [", i, "/", nrow(all_repos), "] Skipping excluded repo: ", repo_name)
    next
  }

  # Check if user has made any commits
  message("  [", i, "/", nrow(all_repos), "] Checking commits for ", org, "/", repo_name)
  all_repos$has_commits[i] <- check_has_commits(org, repo_name, "alexanderbates")

  # Small delay to avoid rate limiting
  Sys.sleep(0.2)
}

# Filter to repos with commits
user_repos <- all_repos %>% filter(has_commits)

message("\n=== Results ===")
message("Total repositories checked: ", nrow(all_repos))
message("Repositories with commits: ", nrow(user_repos))
message("\nBreakdown by organization:")
for (org in unique(user_repos$organization)) {
  count <- sum(user_repos$organization == org)
  message("  ", org, ": ", count)
}

# Save results
write.csv(user_repos, "github_org_projects_filtered.csv", row.names = FALSE)
message("\nSaved filtered repositories to github_org_projects_filtered.csv")

# Also save the full data with has_commits column for reference
write.csv(all_repos, "github_org_all_repos_with_commits.csv", row.names = FALSE)
message("Saved full data with commit flags to github_org_all_repos_with_commits.csv")
