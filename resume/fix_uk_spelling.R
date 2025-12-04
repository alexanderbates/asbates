# Fix US spelling to UK spelling in summaries
library(dplyr)

pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Fix common US to UK spelling
pub_data$summary <- gsub("behavior", "behaviour", pub_data$summary)
pub_data$summary <- gsub("behaviors", "behaviours", pub_data$summary)
pub_data$summary <- gsub("organization", "organisation", pub_data$summary)
pub_data$summary <- gsub("organizations", "organisations", pub_data$summary)
pub_data$summary <- gsub("center", "centre", pub_data$summary)
pub_data$summary <- gsub("centers", "centres", pub_data$summary)
pub_data$summary <- gsub("analyze", "analyse", pub_data$summary)
pub_data$summary <- gsub("analyzed", "analysed", pub_data$summary)
pub_data$summary <- gsub("analyzing", "analysing", pub_data$summary)
pub_data$summary <- gsub("realizes", "realises", pub_data$summary)
pub_data$summary <- gsub("realize", "realise", pub_data$summary)
pub_data$summary <- gsub("realized", "realised", pub_data$summary)
pub_data$summary <- gsub("optimization", "optimisation", pub_data$summary)
pub_data$summary <- gsub("optimized", "optimised", pub_data$summary)
pub_data$summary <- gsub("recognizes", "recognises", pub_data$summary)
pub_data$summary <- gsub("recognize", "recognise", pub_data$summary)
pub_data$summary <- gsub("recognized", "recognised", pub_data$summary)

# Save updated data
write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)

cat("\nUK spelling corrections applied!\n")
cat("Fixed: behavior -> behaviour\n")
cat("       center -> centre\n")
cat("       organization -> organisation\n")
cat("       analyze -> analyse\n")
cat("       realize -> realise\n")
cat("       recognize -> recognise\n")
cat("       optimization -> optimisation\n")
