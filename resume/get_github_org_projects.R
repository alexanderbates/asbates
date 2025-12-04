# Script to gather GitHub organization projects for Alexander Bates
# Uses the GitHub API to retrieve repositories from specified organizations

library(httr)
library(jsonlite)
library(dplyr)
library(tibble)
library(purrr)

# Organizations to query
orgs <- c("natverse", "wilson-lab", "htem", "flyconnectome")

# Function to get repositories from an organization
get_org_repos <- function(org_name) {
  base_url <- paste0("https://api.github.com/orgs/", org_name, "/repos")

  message("Fetching repositories for organization: ", org_name)

  # Get all pages of results
  all_repos <- list()
  page <- 1

  repeat {
    response <- GET(base_url, query = list(
      page = page,
      per_page = 100,
      type = "public"
    ))

    if (status_code(response) != 200) {
      warning("Failed to fetch repos for ", org_name, ". Status: ", status_code(response))
      break
    }

    repos <- content(response, as = "parsed")

    if (length(repos) == 0) break

    all_repos <- c(all_repos, repos)
    page <- page + 1

    # Check if there are more pages
    link_header <- headers(response)$link
    if (is.null(link_header) || !grepl('rel="next"', link_header)) break
  }

  if (length(all_repos) == 0) {
    message("No repositories found for ", org_name)
    return(tibble())
  }

  # Extract relevant information
  repos_df <- map_dfr(all_repos, function(repo) {
    tibble(
      organization = org_name,
      name = repo$name %||% NA,
      full_name = repo$full_name %||% NA,
      description = repo$description %||% NA,
      url = repo$html_url %||% NA,
      homepage = repo$homepage %||% NA,
      language = repo$language %||% NA,
      stars = repo$stargazers_count %||% 0,
      forks = repo$forks_count %||% 0,
      created_at = repo$created_at %||% NA,
      updated_at = repo$updated_at %||% NA,
      topics = paste(unlist(repo$topics), collapse = ", ")
    )
  })

  message("Found ", nrow(repos_df), " repositories for ", org_name)
  return(repos_df)
}

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
    }
    return(FALSE)
  }

  commits <- content(response, as = "parsed")

  # If we got any commits back, user has contributed
  return(length(commits) > 0)
}

# Function to filter repos where user has made commits
filter_user_repos <- function(repos_df, username = "alexanderbates",
                              include_orgs = c("natverse", "wilson-lab", "htem", "flyconnectome"),
                              exclude_repos = c("DeepCAD")) {
  message("Filtering repositories by commit history...")

  # Check all repos for commits by the user
  repos_df$has_commits <- FALSE

  for (i in 1:nrow(repos_df)) {
    org <- repos_df$organization[i]
    repo_name <- repos_df$name[i]

    # Skip excluded repos
    if (repo_name %in% exclude_repos) {
      message("  Skipping excluded repo: ", repo_name)
      next
    }

    # Check if user has made any commits
    message("  Checking commits for ", org, "/", repo_name)
    repos_df$has_commits[i] <- check_has_commits(org, repo_name, username)

    # Small delay to avoid rate limiting
    Sys.sleep(0.1)
  }

  user_repos <- repos_df %>% filter(has_commits)

  message("User has commits in ", nrow(user_repos), " repositories")
  return(user_repos)
}

# Main execution
if (!interactive()) {
  # Get all repos from all organizations
  all_repos <- map_dfr(orgs, get_org_repos)

  # Filter to repos where user is a contributor
  user_repos <- filter_user_repos(all_repos)

  # Save to CSV
  if (nrow(user_repos) > 0) {
    write.csv(user_repos, "github_org_projects.csv", row.names = FALSE)
    message("Saved GitHub organization projects to github_org_projects.csv")
  }

  # Also save all repos (for reference)
  write.csv(all_repos, "github_org_all_repos.csv", row.names = FALSE)
}

# For sourcing in other scripts
get_all_org_repos <- function() {
  all_repos <- map_dfr(orgs, get_org_repos)
  return(all_repos)
}

github_org_repos <- get_all_org_repos()
