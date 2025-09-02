# CV Builder Script
# This script generates cv.md from your data and optionally converts to PDF

# Generate markdown CV
cat("Generating cv.md from data...\n")
rmarkdown::render("cv_builder.Rmd", output_file = "cv.md")

# Convert to PDF using pandoc with ultra-compact settings
cat("Converting cv.md to PDF...\n")
system("pandoc cv.md -o cv.pdf -V geometry:margin=0.25in -V linkcolor=brown -V urlcolor=brown -V fontsize=8pt -V linestretch=0.8 -V colorlinks=true -V textcolor=darkgray -V documentclass=article --pdf-engine=xelatex")

cat("CV generation complete! Files created:\n")
cat("- cv.md (markdown version)\n")
cat("- cv.pdf (PDF version)\n")