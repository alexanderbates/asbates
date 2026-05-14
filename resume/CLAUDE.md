# Claude's Guide to Alexander Bates CV and Visa Application Materials

> **Purpose**: This document serves as a reference guide for Claude Code when helping Alex update CV materials and visa application documents.

---

## Complete Material Update Workflow

### Trigger Phrase: "update my materials"

When the user says **"update my materials"**, follow this comprehensive workflow to update all CV materials, overview documents, and optionally combined PDFs.

### Step 1: Update CV Materials (R-based)

**1a. Update data and code sources:**
```bash
cd /Users/abates/projects/hugo/asbates/resume
Rscript -e "source('compile_data_and_code.R')"
# This updates: zenodo, github, dataverse, CRAN download stats
# Creates: data_and_code_sources.csv
```

**1b. Rebuild interactive CV:**
```bash
Rscript -e "source('export_cv.R')"
# Outputs: index.html, index.pdf
```

**1c. Rebuild compact CV:**
```bash
Rscript -e "source('build_cv.R')"
# Outputs: cv.md, cv.pdf
```

### Step 2: Update Overview Documents

The following 6 overview documents must be kept in sync:

**Location:** `/Users/abates/projects/hugo/asbates/resume/`

1. `overview_awards_and_grants.md/.docx`
2. `overview_publications_impact_summary.md/.docx`
3. `overview_media_coverage.md/.docx`
4. `overview_conferences_attended.md/.docx`
5. `overview_data_and_code.md/.docx`
6. `overview_review_history.md/.docx`

**2a. Check for manual edits in Word documents:**
```bash
cd /Users/abates/projects/hugo/asbates/resume

# Convert Word docs to markdown to check for manual changes
for file in overview_awards_and_grants overview_publications_impact_summary overview_media_coverage overview_conferences_attended overview_data_and_code overview_review_history; do
    pandoc "${file}.docx" -t markdown -o "${file}_from_docx.md"
done

# Compare *_from_docx.md with original .md files
# If user made manual edits in Word, apply them to the .md files
```

**2b. Update .md files with correlated changes:**
- If CV data changed (new awards, publications, etc.), update corresponding overview .md files
- Example: New award in entries.csv → add to overview_awards_and_grants.md
- Example: New software release → add to overview_data_and_code.md

**2c. Fix all hyperlinks:**
```bash
cd /Users/abates/projects/hugo/asbates/resume
python3 << 'EOF'
import re

def fix_all_links(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Fix "Link:" patterns to [URL](URL)
    def fix_link_pattern(match):
        line = match.group(0)
        url_match = re.search(r'(https?://[^\s\)\]]+)', line)
        if url_match:
            url = url_match.group(1)
            url = re.sub(r'[^\w\-\./:?=&%#@]+$', '', url)
            return f'Link: [{url}]({url})'
        return line

    content = re.sub(r'^(\s*)Link:.*$', fix_link_pattern, content, flags=re.MULTILINE)

    # Fix inline links: [text]([URL](URL)) -> [text](URL)
    content = re.sub(r'\[([^\]]+)\]\(\[(https?://[^\]]+)\]\(\2\)\)', r'[\1](\2)', content)

    with open(filename, 'w') as f:
        f.write(content)

# Process all 6 overview documents
for filename in ['overview_awards_and_grants.md', 'overview_publications_impact_summary.md',
                 'overview_media_coverage.md', 'overview_conferences_attended.md',
                 'overview_data_and_code.md', 'overview_review_history.md']:
    fix_all_links(filename)
EOF
```

**2d. Rebuild all Word documents:**
```bash
cd /Users/abates/projects/hugo/asbates/resume

for file in overview_awards_and_grants overview_publications_impact_summary overview_media_coverage overview_conferences_attended overview_data_and_code overview_review_history; do
    pandoc "${file}.md" -o "${file}.docx"
done
```

**2e. Create PDFs and copy to application folder:**
```bash
cd /Users/abates/projects/hugo/asbates/resume

# Create PDFs with professional formatting
for file in overview_awards_and_grants overview_publications_impact_summary overview_media_coverage overview_conferences_attended overview_data_and_code overview_review_history; do
    pandoc "${file}.md" -o "${file}.pdf" \
      -V geometry:margin=0.75in \
      -V fontsize=11pt \
      -V linestretch=1.15 \
      -V colorlinks=true \
      -V linkcolor=blue \
      -V urlcolor=blue \
      --pdf-engine=xelatex
done

# Copy to application folder
cp overview_*.docx "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/"
cp overview_*.pdf "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/"

echo "✓ Overview documents updated and copied to application folder"
```

### Step 3: Rebuild Combined PDFs (if requested)

**Important:** Only rebuild combined PDFs if the user explicitly requests it, as this takes additional time.

Three combined PDFs exist in the visa application:

1. **Awards Combined PDF** - `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/01_awards/asbates_awards_combined_all_evidence.pdf`
2. **Media Articles Combined PDF** - `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media/asbates_media_articles_combined_all_articles.pdf`
3. **Judge Evidence Combined PDF** - `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/05_judge/asbates_judge_combined_all_evidence.pdf`

See **"Creating Combined PDFs"** section below for detailed instructions.

---

## Creating Combined PDFs

### 1. Awards Combined PDF

**Purpose:** Combine all award evidence files into a single PDF.

**Location:** `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/01_awards/evidence/`

**Output:** `asbates_awards_combined_all_evidence.pdf` in `01_awards/` folder

**Script:**
```bash
cd "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/01_awards/evidence" && python3 << 'EOF'
import os
import subprocess
import glob
import tempfile

awards_dir = "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/01_awards/evidence"
output_dir = "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/01_awards"
output_file = os.path.join(output_dir, "asbates_awards_combined_all_evidence.pdf")

# Get all PDF and image files
all_files = []
for ext in ['*.pdf', '*.jpg', '*.jpeg', '*.png']:
    all_files.extend(glob.glob(os.path.join(awards_dir, ext)))

all_files = sorted(all_files)

print(f"Found {len(all_files)} award evidence files:")
for f in all_files:
    print(f"  - {os.path.basename(f)}")

# Create temp directory for converted files
temp_dir = tempfile.mkdtemp()

# Process files: convert images to PDF, keep PDFs as-is
files_to_combine = []
for file_path in all_files:
    filename = os.path.basename(file_path)
    ext = os.path.splitext(filename)[1].lower()

    if ext in ['.jpg', '.jpeg', '.png']:
        # Convert image to PDF
        converted_pdf = os.path.join(temp_dir, filename.replace(ext, '.pdf'))
        print(f"\nConverting {filename} to PDF...")
        result = subprocess.run([
            'sips', '-s', 'format', 'pdf', file_path,
            '--out', converted_pdf
        ], capture_output=True, text=True)

        if result.returncode == 0:
            files_to_combine.append(converted_pdf)
            print(f"  ✓ Converted successfully")
        else:
            print(f"  ✗ Failed to convert: {result.stderr}")
    elif ext == '.pdf':
        # Verify it's a valid PDF
        result = subprocess.run(['file', file_path], capture_output=True, text=True)
        if 'PDF' in result.stdout:
            files_to_combine.append(file_path)
        else:
            print(f"\n✗ Skipping {filename} - NOT A VALID PDF")

print(f"\n\nCombining {len(files_to_combine)} files...")

# Combine all PDFs using ghostscript
subprocess.run([
    'gs', '-dBATCH', '-dNOPAUSE', '-q', '-sDEVICE=pdfwrite',
    '-sOutputFile=' + output_file
] + files_to_combine, check=True)

# Clean up temp directory
for f in glob.glob(os.path.join(temp_dir, '*')):
    os.remove(f)
os.rmdir(temp_dir)

# Get file size
size_mb = os.path.getsize(output_file) / (1024 * 1024)

print(f"\n✓ Combined PDF created: {size_mb:.2f} MB")
print(f"✓ Combined {len(files_to_combine)} award evidence files")
print(f"✓ Output: {output_file}")

EOF
```

### 2. Media Articles Combined PDF

**Purpose:** Combine all media article PDFs and images with separator title cards between articles.

**Location:** `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media/articles/`

**Reference:** `media_links.txt` in `04_media/` folder

**Output:** `asbates_media_articles_combined_all_articles.pdf` in `04_media/` folder

**Title card format:**
- If publication name is known: "Publication Name on the Project Name" (e.g., "The Guardian on the FAFB Project")
- If publication name is unknown: No title card (skip separator)
- Projects extracted from filename: FAFB, BANC, or HemiBrain only
- Font: `\LARGE` with 1.5 line spacing
- No dates or additional information

**Script:**
```bash
cd "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media/articles" && python3 << 'EOF'
import os
import subprocess
import glob
import re
import tempfile

def parse_media_links():
    """Parse media_links.txt to get publication names"""
    mapping = {}
    links_file = '/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media/media_links.txt'

    with open(links_file, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    current_file = None
    for i, line in enumerate(lines):
        # Look for file names
        if '.pdf' in line or '.png' in line or '.jpg' in line or '.jpeg' in line:
            match = re.search(r'(asbates_media[^\s]+\.(pdf|png|jpg|jpeg))', line)
            if match:
                current_file = match.group(1)
        # Look for description in parentheses on next line
        elif current_file and line.strip().startswith('('):
            # Extract outlet name from description
            desc = line.strip().strip('()')
            # Extract outlet name (before comma or end)
            outlet_match = re.match(r'^([^,]+)', desc)
            if outlet_match:
                outlet = outlet_match.group(1).strip()
                mapping[current_file] = outlet
            current_file = None

    return mapping

def extract_project_from_filename(filename):
    """Extract project name (FAFB, BANC, HemiBrain) from filename"""
    filename_lower = filename.lower()

    # Check for project names in filename
    if 'fafb' in filename_lower:
        return 'FAFB'
    elif 'banc' in filename_lower:
        return 'BANC'
    elif 'hemibrain' in filename_lower:
        return 'HemiBrain'
    else:
        return None

def create_separator_page_markdown(text, output_pdf):
    """Create separator page using pandoc with smaller font and better spacing"""
    md_content = f"""
---
geometry: margin=1in
---

\\vspace*{{\\fill}}

\\begin{{center}}
{{\\LARGE \\textbf{{{text}}}}}
\\end{{center}}

\\vspace*{{\\fill}}
"""

    temp_md = output_pdf.replace('.pdf', '.md')
    with open(temp_md, 'w') as f:
        f.write(md_content)

    subprocess.run([
        'pandoc', temp_md, '-o', output_pdf,
        '-V', 'linestretch=1.5',
        '--pdf-engine=xelatex'
    ], check=True, capture_output=True)

    os.remove(temp_md)

# Main execution
media_dir = "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media/articles"
output_dir = "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/04_media"
output_file = os.path.join(output_dir, "asbates_media_articles_combined_all_articles.pdf")

# Parse media links to get publication names
print("Parsing media links...")
outlet_mapping = parse_media_links()

# Get all media files
all_files = []
for ext in ['*.pdf', '*.png', '*.jpg', '*.jpeg']:
    all_files.extend(glob.glob(os.path.join(media_dir, ext)))

all_files = sorted(all_files)

print(f"Found {len(all_files)} media files")

# Create temp directory for separators and converted files
temp_dir = tempfile.mkdtemp()

# Process each file: create separator (if known) and add file
combined_list = []
separator_count = 0
for i, file_path in enumerate(all_files):
    filename = os.path.basename(file_path)
    ext = os.path.splitext(filename)[1].lower()

    # Get publication name
    outlet = outlet_mapping.get(filename, "Unknown Publication")

    # Get project name from filename
    project = extract_project_from_filename(filename)

    # Only create separator if outlet is known
    if outlet != "Unknown Publication":
        # Create title card text
        if project:
            title_text = f"{outlet} on the {project} Project"
        else:
            title_text = outlet

        print(f"{i+1}. {title_text}")

        # Create separator page
        separator_pdf = os.path.join(temp_dir, f"sep_{i:02d}.pdf")
        create_separator_page_markdown(title_text, separator_pdf)
        combined_list.append(separator_pdf)
        separator_count += 1
    else:
        print(f"{i+1}. {filename} (no title card)")

    # Add the article/image file
    if ext in ['.png', '.jpg', '.jpeg']:
        # Convert image to PDF
        converted_pdf = os.path.join(temp_dir, f"converted_{i:02d}.pdf")
        subprocess.run([
            'sips', '-s', 'format', 'pdf', file_path,
            '--out', converted_pdf
        ], check=True, capture_output=True)
        combined_list.append(converted_pdf)
    else:
        combined_list.append(file_path)

print(f"\nCombining {len(combined_list)} pages ({separator_count} separators + {len(all_files)} articles)...")

# Combine all PDFs
subprocess.run([
    'gs', '-dBATCH', '-dNOPAUSE', '-q', '-sDEVICE=pdfwrite',
    '-sOutputFile=' + output_file
] + combined_list, check=True)

# Clean up temp directory
for f in glob.glob(os.path.join(temp_dir, '*')):
    os.remove(f)
os.rmdir(temp_dir)

# Get file size
size_mb = os.path.getsize(output_file) / (1024 * 1024)

print(f"\n✓ Combined PDF created: {size_mb:.2f} MB")
print(f"✓ Combined {len(all_files)} articles with {separator_count} separators")
print(f"✓ Output: {output_file}")

EOF
```

### 3. Judge Evidence Combined PDF

**Purpose:** Combine all peer review and judging evidence, organized by category with separator title cards.

**Location:** `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/05_judge/`

**Organization:**
- 8 categories (subfolders) processed in numeric order
- Files within each category in numeric order
- Title card before each category with cleaned folder name

**Title card format:**
- Folder name with numbers and underscores removed
- Example: "01_review_article" → "Review Article"
- Font: `\LARGE` with 1.5 line spacing

**Output:** `asbates_judge_combined_all_evidence.pdf` in `05_judge/` folder

**Script:**
```bash
python3 << 'EOF'
import os
import subprocess
import glob
import re
import tempfile

def clean_folder_name(folder_name):
    """Remove numbers, underscores, and add spaces between words"""
    # Remove leading numbers and underscore
    name = re.sub(r'^\d+_', '', folder_name)
    # Replace underscores with spaces
    name = name.replace('_', ' ')
    # Capitalize each word
    name = ' '.join(word.capitalize() for word in name.split())
    return name

def create_separator_page_markdown(text, output_pdf):
    """Create separator page using pandoc"""
    md_content = f"""
---
geometry: margin=1in
---

\\vspace*{{\\fill}}

\\begin{{center}}
{{\\LARGE \\textbf{{{text}}}}}
\\end{{center}}

\\vspace*{{\\fill}}
"""

    temp_md = output_pdf.replace('.pdf', '.md')
    with open(temp_md, 'w') as f:
        f.write(md_content)

    subprocess.run([
        'pandoc', temp_md, '-o', output_pdf,
        '-V', 'linestretch=1.5',
        '--pdf-engine=xelatex'
    ], check=True, capture_output=True)

    os.remove(temp_md)

# Main execution
judge_dir = "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/05_judge"
output_file = os.path.join(judge_dir, "asbates_judge_combined_all_evidence.pdf")

# Get all subdirectories in numeric order
subdirs = sorted([d for d in os.listdir(judge_dir)
                  if os.path.isdir(os.path.join(judge_dir, d)) and d[0].isdigit()])

print(f"Found {len(subdirs)} categories in 05_judge")

# Create temp directory for separators and converted files
temp_dir = tempfile.mkdtemp()

# Process each subdirectory
combined_list = []
total_files = 0
separator_count = 0

for subdir in subdirs:
    subdir_path = os.path.join(judge_dir, subdir)

    # Get all PDF and image files recursively
    files = []
    for ext in ['*.pdf', '*.png', '*.jpg', '*.jpeg']:
        files.extend(glob.glob(os.path.join(subdir_path, '**', ext), recursive=True))

    # Sort files by their complete path to maintain numeric order
    files = sorted(files)

    if files:  # Only create separator if there are files
        # Create separator page with cleaned folder name
        clean_name = clean_folder_name(subdir)
        print(f"\n=== {clean_name} ===")
        print(f"Found {len(files)} files")

        separator_pdf = os.path.join(temp_dir, f"sep_{subdir}.pdf")
        create_separator_page_markdown(clean_name, separator_pdf)
        combined_list.append(separator_pdf)
        separator_count += 1

        # Add each file
        for file_path in files:
            filename = os.path.basename(file_path)
            ext = os.path.splitext(filename)[1].lower()

            print(f"  - {os.path.relpath(file_path, judge_dir)}")

            if ext in ['.png', '.jpg', '.jpeg']:
                # Convert image to PDF
                converted_pdf = os.path.join(temp_dir, f"converted_{subdir}_{filename}.pdf")
                subprocess.run([
                    'sips', '-s', 'format', 'pdf', file_path,
                    '--out', converted_pdf
                ], check=True, capture_output=True)
                combined_list.append(converted_pdf)
            else:
                combined_list.append(file_path)

            total_files += 1

print(f"\n\nCombining {len(combined_list)} pages ({separator_count} separators + {total_files} files)...")

# Combine all PDFs
subprocess.run([
    'gs', '-dBATCH', '-dNOPAUSE', '-q', '-sDEVICE=pdfwrite',
    '-sOutputFile=' + output_file
] + combined_list, check=True)

# Clean up temp directory
for f in glob.glob(os.path.join(temp_dir, '*')):
    os.remove(f)
os.rmdir(temp_dir)

# Get file size
size_mb = os.path.getsize(output_file) / (1024 * 1024)

print(f"\n✓ Combined PDF created: {size_mb:.2f} MB")
print(f"✓ Combined {total_files} files across {separator_count} categories")
print(f"✓ Output: {output_file}")

EOF
```

---

## Quick Reference: How to Update Files

### Updating the CV

#### 1. Update Data Sources

**Main data file:**
```bash
# Location: /Users/abates/projects/hugo/asbates/resume/entries.csv
# Contains: All CV entries (grants, education, talks, positions, etc.)
# Structure: title, institution, loc, start, end, section, in_resume, description_1-4
```

**To add a new CV entry:**
1. Open `entries.csv`
2. Add new row with appropriate `section` value:
   - `grants` - Fellowships and awards
   - `education` - Degrees
   - `research_projects` - Positions
   - `meetings` - Conference talks
   - `posters` - Poster presentations
   - `leadership_experience` - Mentorship, organization
   - `experience` - Visiting positions, training
3. Set `in_resume` to TRUE to include in CV
4. Add bullet points in `description_1` through `description_4`
5. Rebuild CV (see below)

**To update data and code sources:**
```r
# In R console, navigate to resume/ directory:
setwd("/Users/abates/projects/hugo/asbates/resume")

# Option 1: Full refresh (fetches from APIs - requires API tokens)
source("compile_data_and_code.R")

# Option 2: Rebuild from cached data (faster, no API calls)
source("rebuild_data_sources.R")

# Individual API scripts if needed:
source("get_zenodo_projects.R")      # Requires ZENODO_PAT in .Renviron
source("get_github_org_projects.R")  # Queries natverse, flyconnectome, wilson-lab, htem
source("get_dataverse_downloads.R")  # Web scraping for BANC downloads
source("get_cran_downloads.R")       # R package download stats
```

#### 2. Build the CV

**Interactive HTML/PDF CV** (pagedown format, rich styling):
```r
# In R console:
setwd("/Users/abates/projects/hugo/asbates/resume")
source("export_cv.R")
# OR
rmarkdown::render("index.Rmd")
pagedown::chrome_print("index.html")

# Outputs: index.html, index.pdf
```

**Compact Text CV** (8pt font, tight spacing, for visa applications):
```r
# In R console:
source("build_cv.R")
# OR
rmarkdown::render("cv_builder.Rmd", output_file = "cv.md")

# Then convert to PDF:
system("pandoc cv.md -o cv.pdf -V geometry:margin=0.25in -V linkcolor=brown -V urlcolor=brown -V fontsize=8pt -V linestretch=0.8 -V colorlinks=true -V textcolor=darkgray -V documentclass=article --pdf-engine=xelatex")

# Outputs: cv.md, cv.pdf
```

**Shell script alternative for PDF conversion:**
```bash
cd /Users/abates/projects/hugo/asbates/resume
./md2pdf.sh
```

#### 3. Generate Visa Support Documents

**Word documents with styled formatting:**
```r
# In R console:
setwd("/Users/abates/projects/hugo/asbates/resume")

# Generate publication summaries with impact metrics
source("generate_publications_word_final.R")

# Outputs:
# - publications_biological_summaries.docx
# - publications_impact_summary.docx
```

**Convert markdown to Word (simple):**
```bash
# For any .md file in resume/
pandoc document_name.md -o document_name.docx
```

**Convert markdown to Word (with template):**
```bash
# Using custom reference document for styling
pandoc document_name.md -o document_name.docx --reference-doc=template.docx
```

### Updating Contact Information, Text Blocks, or Skills

**Contact info:**
```bash
# Edit: resume/contact_info.csv
# Columns: loc, icon, contact
```

**Text blocks (intro, etc.):**
```bash
# Edit: resume/text_blocks.csv
# Columns: loc, text
```

**Language/technical skills:**
```bash
# Edit: resume/language_skills.csv
# Columns: skill, level
```

---

## Repository Structure

### Main Repository
```
/Users/abates/projects/hugo/asbates/
├── resume/                    # CV and visa document generation system
├── content/                   # Hugo website content
├── static/                    # Hugo static assets
├── themes/                    # Hugo themes
└── config.toml               # Hugo configuration
```

### Resume Directory Structure
```
resume/
├── DATA FILES
│   ├── entries.csv                      # MASTER CV DATABASE
│   ├── contact_info.csv                 # Email, GitHub, ORCID
│   ├── text_blocks.csv                  # Reusable text snippets
│   ├── language_skills.csv              # Technical skills
│   └── data_and_code_sources.csv        # Generated: datasets + repos
│
├── BUILD SCRIPTS (R)
│   ├── export_cv.R                      # Build interactive HTML/PDF
│   ├── build_cv.R                       # Build compact text CV
│   ├── cv_printing_functions.r          # Core utilities
│   ├── md2pdf.sh                        # Shell script for PDF conversion
│   └── generate_publications_word_final.R  # Styled Word docs
│
├── CV TEMPLATES (R Markdown)
│   ├── index.Rmd                        # Interactive HTML resume (pagedown)
│   └── cv_builder.Rmd                   # Compact text CV builder
│
├── DATA COLLECTION SCRIPTS (R)
│   ├── compile_data_and_code.R          # Master compilation script
│   ├── rebuild_data_sources.R           # Rebuild from cache
│   ├── get_zenodo_projects.R            # Zenodo API (requires token)
│   ├── get_github_org_projects.R        # GitHub API
│   ├── get_dataverse_downloads.R        # Web scraping
│   └── get_cran_downloads.R             # CRAN stats
│
├── GENERATED OUTPUTS
│   ├── index.html                       # Interactive CV
│   ├── index.pdf                        # Print-friendly interactive CV
│   ├── cv.md                            # Markdown CV
│   ├── cv.pdf                           # Compact PDF CV
│   ├── publications_impact_summary.docx # Impact metrics (Word)
│   ├── data_and_code.docx               # Data/code listing (Word)
│   ├── media_coverage.docx              # Media coverage (Word)
│   ├── review_history.docx              # Peer review history (Word)
│   └── conferences_attended.docx        # Conference list (Word)
│
├── STYLING
│   ├── dd_cv.css                        # Main CV stylesheet
│   └── custom.css                       # Custom overrides
│
└── CACHED DATA (from API calls)
    ├── zenodo_projects.csv
    ├── github_org_projects.csv
    ├── github_org_all_repos.csv
    ├── dataverse_stats.csv
    └── cran_download_stats.csv
```

---

## Visa Application Materials

### Location
```
/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/
```

### Directory Organization (8 Evidence Categories)

**01_awards/** (20 files)
- EMBO postdoctoral fellowship offer
- Henry Wellcome fellowship offer
- LSRF offer
- HFSP offer
- Max Perutz Prize
- BNA thesis award
- Herchel Smith Award
- iGEM Gold medal
- Academic prizes from UCL

**02_associations/** (empty)
- *Action needed*: Add professional memberships

**03_publications/**
- `publications/` - 22 major papers (Nature, eLife, Cell, Current Biology, Neuron)
- `preprints/` - bates_et_al_2025.pdf
- `code/` - 10 software package documentation files (nat, fafbseg, etc.)
- `citations/` - Google Scholar profile, iCite metrics

**04_media/** (24 files)
- BBC Science of the Year 2024
- New York Times, Guardian, Scientific American
- NPR, WIRED Magazine
- Nature Communications coverage
- UKRI press releases

**05_judge/**
- `conference_review/` - Cosyne 2026 reviewer (12 files)
- `grant_review/` - UKRI reviews (4 files)
- `paper_reviews/accepted/` - 9 completed reviews (eLife, Nature Communications)
- `paper_reviews/invited/` - 4 review invitations
- `editorial_invite/` - Genes journal Guest Editor invitation
- `review_article/` - 2 published review articles
- `journalism/` - New Scientist features
- `summer_school/` - Teaching documentation

**06_contributions_of_significance/**
- `invited_talks/` - 5 major conference invitations
- `conference_proceedings/` - Abstract books
- `letters_of_support/connected_to_me/` - Jefferis, Waddell (2 files)
- `letters_of_support/not_connected_to_me/` - *Action needed*: 2-3 independent letters

**07_essential_capacity/** (3 files)
- Dean Daley letter
- Rachel Wilson letter
- Wei-Chung Allen Lee letter

**08_high_salary/** (empty)
- *Action needed*: Salary documentation

### Supporting Materials

**qualifications/** (14 files)
- PhD from Cambridge (certificate, transcript, verification)
- UCL BSc Neuroscience
- A-level qualifications

**phd_thesis/** (7 files)
- PhD thesis PDF (776 MB)
- Topic summary
- Verification letters

**cv/**
- asbates_cv_long.pdf

**guidance/**
- `hio_guidance/` - O-1 guidelines from Harvard International Office (7 files)
- `templates/` - EB-1A letter templates (3 files)
- `example_from_colleague/` - Successful EB-1A letters (5 examples)
- `from_lawyer.txt` - Dunn Law Firm detailed instructions

**travel_documents/** (11 subfolders)
- DS2019, I94, J1 stamps, passport, payslips, SEVIS, W2

**waiver/** (9 files)
- J-1 waiver application packet

**Root level:**
- O-1 example cover sheets
- O-1 sample major headings
- O-1 sample table of contents
- notes.txt (case numbers, lawyer notes, action items)

---

## Key Technical Details

### Dependencies

**R Packages:**
- `pagedown` - HTML resume rendering
- `rmarkdown` - R Markdown processing
- `scholar` - Google Scholar API
- `rorcid` - ORCID API
- `zen4R` - Zenodo API
- `officer` - Word document generation with styling
- `httr`, `jsonlite` - API communication
- `dplyr`, `tidyverse` - Data manipulation
- `formattable` - Table styling

**External Tools:**
- `pandoc` - Document conversion (markdown → PDF/DOCX)
- `xelatex` - PDF rendering engine (Unicode support)
- Chrome/Chromium - pagedown PDF printing

**Environment Variables:**
- `ZENODO_PAT` - Zenodo API token (stored in `.Renviron`)

### Data Flow

```
External APIs               CSV Data Files           R Scripts             Outputs
--------------             ---------------          ----------            --------
Google Scholar    →        entries.csv       →      index.Rmd      →      index.html → index.pdf
ORCID API         →        contact_info.csv  →      ↓                     (interactive CV)
                          text_blocks.csv   →      cv_printing_functions.r
                          language_skills.csv→

Zenodo API        →        zenodo_projects.csv  →   cv_builder.Rmd →      cv.md → cv.pdf
GitHub API        →        github_org_*.csv     →   ↓                     (compact CV)
CRAN logs         →        cran_download*.csv   →   compile_data_and_code.R
Dataverse scrape  →        dataverse_stats.csv  →

                          data_and_code_sources.csv → Various visa docs
                                                   → (markdown/Word)
```

### Important User Information

**Personal Details:**
- ORCID: 0000-0002-1195-0445
- Google Scholar: [Profile link in contact_info.csv]
- GitHub orgs: natverse, flyconnectome, wilson-lab, htem
- Current position: Harvard Medical School
- Previous: MRC LMB Cambridge, UCL

**Current Git Branch:** main
**Git Status:** Multiple modified files in resume/, several untracked Word/markdown visa documents

---

## Common Tasks

### Add a New Award
1. Add entry to `entries.csv` with `section = "grants"`
2. Add supporting documentation to visa folder: `01_awards/`
3. Rebuild CV: `source("export_cv.R")`

### Add a New Publication
1. Publications automatically pulled from Google Scholar via `index.Rmd`
2. For manual entry, add to `entries.csv` with `section = "publications"`
3. Add PDF to visa folder: `03_publications/publications/`
4. Update citation metrics if needed: `03_publications/citations/`
5. Rebuild impact summary: `source("generate_publications_word_final.R")`

### Add Conference Talk
1. Add to `entries.csv` with `section = "meetings"`
2. If invited talk, add invitation to visa folder: `06_contributions_of_significance/invited_talks/`
3. Add abstract book to: `06_contributions_of_significance/conference_proceedings/`
4. Rebuild CV

### Add Peer Review Activity
1. Add documentation to visa folder:
   - Review invitations → `05_judge/paper_reviews/invited/`
   - Completed reviews → `05_judge/paper_reviews/accepted/`
   - Conference reviews → `05_judge/conference_review/`
   - Grant reviews → `05_judge/grant_review/`
2. Update review summary in `resume/review_history.md`
3. Convert to Word: `pandoc review_history.md -o review_history.docx`

### Add Media Coverage
1. Add PDF to visa folder: `04_media/`
2. Update `resume/media_coverage.md`
3. Convert to Word: `pandoc media_coverage.md -o media_coverage.docx`

### Update Software/Data Releases
1. Run data collection: `source("compile_data_and_code.R")`
2. Review `data_and_code_sources.csv`
3. Update `resume/data_and_code.md` if manual additions needed
4. Convert to Word: `pandoc data_and_code.md -o data_and_code.docx`
5. Add package documentation PDFs to visa folder: `03_publications/code/`

### Generate Letter of Support (for someone else to review)
1. Review templates: `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/guidance/templates/`
2. Review examples: `.../guidance/example_from_colleague/`
3. Read instructions: `.../guidance/from_lawyer.txt`
4. Create draft in appropriate location:
   - Independent letters → `06_contributions_of_significance/letters_of_support/not_connected_to_me/`
   - Dependent letters → `06_contributions_of_significance/letters_of_support/connected_to_me/`

---

## Visa Application Status

### Completed Evidence Categories
✅ 01 - Awards (extensive documentation)
✅ 03 - Publications (22 major papers + software)
✅ 04 - Media coverage (24 major articles)
✅ 05 - Judging (comprehensive peer review)
✅ 06 - Contributions (invited talks, proceedings)
✅ 07 - Essential capacity (3 letters)

### Action Needed
⚠️ 02 - Associations (add professional memberships if applicable)
⚠️ 06 - Letters (need 2-3 independent letters)
⚠️ 08 - High salary (add documentation)

### EB-1A vs O-1A Notes
- EB-1A: Permanent residency ("green card"), higher bar, no labor certification needed
- O-1A: Temporary visa (3 years, renewable), requires employer sponsorship
- Both use similar evidence categories
- Current materials support both applications
- See `notes.txt` in visa folder for lawyer's guidance

---

## Visa Application Package - Document Sync Workflow

### Application Attachments

The following Word documents from `resume/` are part of the formal visa application package and must be kept in sync with the application folder:

**Location:** `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/`

**Attachment Mapping:**
- **Attachment 9:** review_history.docx
- **Attachment 11:** publications_impact_summary.docx + data_and_code.docx
- **Attachment 12:** conferences_attended.docx
- **Attachment 15:** media_coverage.docx

### Sync Workflow

**IMPORTANT:** These documents must stay synchronized between the local repo and the Dropbox application folder.

**When updating any of these documents:**
1. Make changes to the source files in `resume/` (markdown or R scripts)
2. Rebuild the Word document locally using pandoc or R scripts
3. **ALWAYS ASK USER BEFORE SYNCING** to the application folder
4. Once approved, copy updated file to: `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/`

**Copy command template:**
```bash
cp /Users/abates/projects/hugo/asbates/resume/[filename].docx "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/"
```

**Example workflow:**
```bash
# 1. Update source markdown
# Edit review_history.md

# 2. Rebuild Word document
pandoc review_history.md -o review_history.docx

# 3. Ask user for approval to sync

# 4. Copy to application folder (after approval)
cp /Users/abates/projects/hugo/asbates/resume/review_history.docx "/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/"
```

### Current Application Package Files

These files are currently synchronized:
- ✅ conferences_attended.docx
- ✅ data_and_code.docx
- ✅ media_coverage.docx
- ✅ publications_impact_summary.docx
- ✅ review_history.docx

Also in application folder (not auto-generated):
- O-1_cover_sheets.docx
- O-1_table_of_contents.docx

---

## Important Commands Reference

```bash
# Navigate to resume directory
cd /Users/abates/projects/hugo/asbates/resume

# Quick CV rebuild (in R console)
source("export_cv.R")          # Interactive HTML/PDF
source("build_cv.R")            # Compact text CV

# Data updates
source("compile_data_and_code.R")      # Full refresh with API calls
source("rebuild_data_sources.R")       # Quick rebuild from cache

# Markdown to Word conversion
pandoc document.md -o document.docx

# Markdown to PDF with custom formatting
pandoc cv.md -o cv.pdf -V geometry:margin=0.25in -V fontsize=8pt -V linestretch=0.8 --pdf-engine=xelatex

# View git status
git status

# Commit changes (example)
git add entries.csv index.html index.pdf
git commit -m "Update CV with new publication"
```

---

## Notes for Claude

- Always read files before editing them
- When updating `entries.csv`, preserve exact column structure
- Test CV builds after major changes
- Check that pandoc conversions maintain formatting
- Be mindful of file sizes in Dropbox folder (PhD thesis is 776 MB)
- API scripts require tokens - check `.Renviron` if errors occur
- Word documents with styling should use `officer` package, not just pandoc
- When helping with visa applications, always reference the lawyer's guidance in `from_lawyer.txt`
- Independent letters of support are critical - these are from people Alex hasn't worked directly with
- Keep visa evidence organized in the 8 category structure

### CV Formatting Preferences

**Compact CV (cv.pdf) Formatting:**
- **Zenodo datasets**: Show only name, DOI, and download count - NO descriptions
  - Format: `[Dataset Name](URL) (DOI: xxx) - Downloads: xxx`
  - Implemented in: `cv_builder.Rmd` lines 410-412
  - Downloads are formatted with thousand separators (e.g., "1,491")

**File Dependencies:**
- Changes to `cv.pdf` require updating `cv_builder.Rmd` (source file)
- Running `build_cv.R` regenerates both `cv.md` and `cv.pdf`
- Changes to `cv.md` directly will be overwritten on next build - always edit `cv_builder.Rmd` for permanent changes
- Similarly, `index.pdf` is generated from `index.Rmd` - edit the .Rmd file, not the outputs

---

## Visa Application Overview Documents - Workflow and Standards

### Overview Document Files

The visa application includes five "overview" documents that summarize different aspects of Dr. Bates's career:

**Location:** `/Users/abates/projects/hugo/asbates/resume/`

1. **overview_awards_and_grants.md/docx** - Fellowships, grants, scholarships, and awards
2. **overview_publications_impact_summary.md/docx** - Publication list with journal metrics and citation impact
3. **overview_media_coverage.md/docx** - Media attention for research projects
4. **overview_conferences_attended.md/docx** - Scientific meetings and presentations
5. **overview_data_and_code.md/docx** - Open datasets and software contributions

### Document Update Workflow

**CRITICAL: Always follow this exact workflow when updating visa overview documents:**

#### Step 1: Check for Manual Changes in Word Documents
```bash
# Convert Word docs to markdown to identify any manual edits
for file in overview_awards_and_grants overview_publications_impact_summary overview_media_coverage overview_conferences_attended overview_data_and_code; do
    pandoc "${file}.docx" -t markdown -o "${file}_from_docx.md"
done

# Compare with existing .md files to identify changes
# Apply any user-made changes from Word docs to the .md files
```

#### Step 2: Apply Content Modifications
- Make all content edits to the `.md` files first
- Never edit Word documents directly as they will be regenerated

#### Step 3: Fix All Hyperlinks
**CRITICAL:** All URLs must be clickable hyperlinks in Word documents.

Format requirement: `Link: [URL](URL)` where the URL is both displayed and hyperlinked

```bash
# Use Python script to convert all plain URLs to clickable markdown links
python3 << 'EOF'
import re

def fix_all_links(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Fix "Link:" patterns
    def fix_link_pattern(match):
        line = match.group(0)
        url_match = re.search(r'(https?://[^\s\)\]]+)', line)
        if url_match:
            url = url_match.group(1)
            url = re.sub(r'[^\w\-\./:?=&%#@]+$', '', url)
            return f'Link: [{url}]({url})'
        return line

    content = re.sub(r'^(\s*)Link:.*$', fix_link_pattern, content, flags=re.MULTILINE)

    # Fix inline links: [text]([URL](URL)) -> [text](URL)
    content = re.sub(r'\[([^\]]+)\]\(\[(https?://[^\]]+)\]\(\2\)\)', r'[\1](\2)', content)

    with open(filename, 'w') as f:
        f.write(content)

# Process all 5 overview documents
for filename in ['overview_awards_and_grants.md', 'overview_publications_impact_summary.md',
                 'overview_media_coverage.md', 'overview_conferences_attended.md',
                 'overview_data_and_code.md']:
    fix_all_links(filename)
EOF
```

#### Step 4: Rebuild All Word Documents
```bash
# Always rebuild all 5 documents together to maintain consistency
pandoc overview_awards_and_grants.md -o overview_awards_and_grants.docx
pandoc overview_publications_impact_summary.md -o overview_publications_impact_summary.docx
pandoc overview_media_coverage.md -o overview_media_coverage.docx
pandoc overview_conferences_attended.md -o overview_conferences_attended.docx
pandoc overview_data_and_code.md -o overview_data_and_code.docx
```

### Document Formatting Standards

All overview documents follow these standards (based on overview_awards_and_grants.md):

**1. Title and Introduction**
```markdown
# [Category] - Dr. Alexander Shakeel Bates

[Brief introduction paragraph explaining the document's purpose]

---
```

**2. Section Structure**
- Main sections: `## Section Name` (no numbers)
- Subsections: `### 1. Item Name`, `### 2. Item Name` (numbered sequentially)
- Numbering resets for each new `##` section
- Separate items with `---`

**3. Subsection Content Format**
```markdown
### 1. Award/Item Name

**[Field]:** [Value]
**[Field]:** [Value]
...

**Significance:** [Detailed explanation of importance]

---
```

**4. Hyperlink Format**
- "Link:" lines: `Link: [URL](URL)` - URL is both display text and link target
- Inline links: `[descriptive text](URL)` - descriptive text is displayed
- **Never** use plain URLs - they must be clickable in Word documents
- **Never** hyperlink regular words to URLs - use "Link:" format instead

**5. Summary Statistics**
- Include summary section at end with key metrics
- Use clear bullet points or structured format

### Common Tasks

**Adding a New Award/Grant**
1. Add entry to `overview_awards_and_grants.md` following the numbered format
2. Add supporting documentation to visa folder: `01_awards/`
3. Run link-fixing script
4. Rebuild Word document

**Adding Media Coverage**
1. Add article details to `overview_media_coverage.md`
2. Include: outlet, title, key points, significance, publication date
3. Add "Link: [URL](URL)" at the end
4. Add PDF to visa folder: `04_media/articles/`
5. Follow naming convention: `asbates_media_articles_XX_description.pdf`
6. Run link-fixing script
7. Rebuild Word document

**Updating Publication Metrics**
1. Update citation counts in `overview_publications_impact_summary.md`
2. Update h-index, RCR, and other metrics in Impact Summary section
3. Run link-fixing script
4. Rebuild Word document

**Expanding Existing Content** (e.g., adding detail to an article)
1. Edit the relevant section in the `.md` file
2. Add subsections with `**Subheading:**` format
3. Include scientist names, affiliations, and quotes where relevant
4. Maintain professional, formal tone
5. Run link-fixing script
6. Rebuild Word document

### Integration with Visa Application Package

**Syncing to Application Folder:**
Some documents are also formal attachments in the visa application package.

**Location:** `/Users/abates/HMS Dropbox/Alexander Bates/admin/US_visa/asbates_o1/application/`

**Attachment Mapping:**
- **Attachment 9:** overview_review_history.docx (not in resume/ folder)
- **Attachment 11:** overview_publications_impact_summary.docx + overview_data_and_code.docx
- **Attachment 12:** overview_conferences_attended.docx
- **Attachment 15:** overview_media_coverage.docx

**IMPORTANT:** Always ask user before syncing updated files to the application folder.

### Quality Checklist

Before completing any visa document update:
- [ ] All "Link:" entries use `[URL](URL)` format
- [ ] No plain URLs anywhere in documents
- [ ] No hyperlinked regular words (e.g., don't hyperlink "article" - use "Link: URL")
- [ ] Section numbering follows `### 1.`, `### 2.` pattern
- [ ] All content changes made to `.md` files first
- [ ] All 5 Word documents rebuilt together
- [ ] Professional, formal tone maintained throughout
- [ ] Proper structure with `##` and `###` headers
- [ ] Summary statistics updated if relevant

---

**Last Updated:** 2025-12-05
**Maintained by:** Claude Code
**For:** Alexander Bates
