# CV Codebase Analysis

## CSS and RMD Relationship

The CV styling is controlled by two CSS files and their application to the index.Rmd structure:

### CSS Files Analysis

1. **dd_cv.css** (Base template styles):
   - Sets Montserrat as main font and Playfair Display for headers
   - Configures sidebar width (7rem) and background color
   - Handles timeline styling with decorator circles and lines
   - Controls spacing and layout of sections, details, and places
   - Manages skill bars and information cards

2. **custom.css** (Personal overrides):
   - Changes fonts (Lexend Deca for h1, Montserrat for h2/h3)
   - Sets earth tone color scheme (#DBCB9F for sidebar, #88816f for accents)
   - Controls link colors and hover effects
   - Adds page break controls with .break-after-me class
   - Overrides text sizes and spacing

### Key CSS-RMD Relationships

| CSS Class/Element | RMD Application | Visual Effect |
|-------------------|-----------------|---------------|
| `.aside` | Sidebar content | Controls width (7rem), background color, text styling |
| `.main-block` | Main content sections | Formats content areas in the main column |
| `.section` | Section headers | Handles section headings with timeline connectors |
| `.decorator` | Timeline elements | Styles timeline circles and connecting lines |
| `.details` | Content descriptions | Controls text in timeline entries and descriptions |
| `.place` | Institution names | Formats workplace and institution entries |
| `.blocks` | Content grouping | Controls spacing and layout of content blocks |

## Current CV Formatting Issues

### Spacing Issues
1. **Line spacing too tight**
   - Text lines are excessively compressed (line-height: 0.9)
   - Bullet points have almost no vertical separation
   - Content appears cramped, particularly in lists

2. **Inconsistent section spacing**
   - Too much vertical space between major sections (PROFESSIONAL RESEARCH, EDUCATION, etc.)
   - Timeline entries have disproportionate spacing between titles and details
   - Blocks of related content need more consistent margins

3. **Text size imbalances**
   - Section headers (h2) are oversized compared to content text (0.7rem vs 0.5rem)
   - Body text size (0.5rem) is too small for comfortable reading
   - Inconsistent text sizing between different content types

### Visual Hierarchy Problems
1. **Section headers too prominent**
   - GRANTS, PAPERS, etc. headings are disproportionately large
   - Creates imbalance between headers and content
   - Heading font weight makes them dominate the page

2. **Poor content differentiation**
   - Difficult to distinguish between different types of entries
   - Subsection titles don't stand out sufficiently from body text
   - Employment dates and locations blend with other content

3. **Timeline visualization issues**
   - Timeline dots are too small (8px) and get lost in the dense content
   - Vertical connector line needs better spacing
   - Date entries have inconsistent alignment

### Content Formatting Issues
1. **Table formatting problems**
   - Tables in the "PAPERS" section have compressed text with poor readability
   - Column alignment issues in tables
   - Citation metrics difficult to read

2. **Text overflow concerns**
   - Publication titles with awkward line breaks
   - Author lists truncated inconsistently
   - Some content runs close to right margin

3. **Uneven page distribution**
   - Content appears unevenly distributed across pages
   - Some pages appear more dense than others

## Technical Style Problems

1. **CSS specificity conflicts**
   - Excessive use of !important flags (necessary but indicates potential structure issues)
   - Competing style rules between dd_cv.css and custom.css
   - Targeting of specific elements could be more efficient

2. **Font size implementation**
   - Global * selector sets base size but conflicts with specific element sizes
   - Inconsistent use of relative units (rem, em)

3. **Layout technique issues**
   - Heavy reliance on fixed margins rather than flexible spacing
   - Limited use of container-based spacing

## Recommendations for Current Issues

1. **Fix line spacing**
   - Increase line-height values from 0.9 to 1.1-1.2 for readability
   - Restore moderate spacing between bullet points

2. **Balance section spacing**
   - Reduce margins between major sections
   - Standardize spacing between all related elements
   - Create consistent vertical rhythm

3. **Improve text size hierarchy**
   - Reduce section header (h2) size
   - Slightly increase body text size for readability
   - Maintain clear size differentiation between heading levels

4. **Enhance visual structure**
   - Better distinguish section headers from content
   - Improve timeline visualization with better spacing
   - Create clearer visual separation between content types

5. **Optimize table formatting**
   - Improve readability of publication tables
   - Standardize column widths and alignment
   - Enhance citation metric display