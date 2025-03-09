# CV Codebase Analysis

## CSS and RMD Relationship

The CV styling is controlled by two CSS files and their application to the index.Rmd structure:

### CSS Files Analysis

1. **dd_cv.css** (Base template styles):
   - Sets Montserrat as main font and Playfair Display for headers
   - Configures sidebar width (7rem) and background color (#f7fbff)
   - Handles timeline styling with decorator circles and lines
   - Controls spacing and layout of sections, details, and places
   - Manages skill bars and information cards

2. **custom.css** (Personal overrides):
   - Changes fonts (Lexend Deca for h1, Montserrat for h2/h3)
   - Sets a pink color scheme (#FC6882 for h1, #B80068 for h3)
   - Overrides sidebar background to pink
   - Controls link colors (#800080) and hover effects
   - Adds page break controls with .break-after-me class

### Key CSS-RMD Relationships

| CSS Class/Element | RMD Application | Visual Effect |
|-------------------|-----------------|---------------|
| `.aside` | Sidebar content | Controls width (7rem), background color, text styling |
| `.main-block` | Main content sections | Formats content areas in the main column |
| `.section` | Section headers | Handles section headings with timeline connectors |
| `.section.no-timeline` | Special sections | Removes timeline connectors for certain sections |
| `.decorator` | Timeline elements | Styles timeline circles and connecting lines |
| `.skill-bar` | Skills visualization | Formats skill level indicators in sidebar |
| `.info-card` | Highlighted content | Creates boxed content for emphasis |

## CV Formatting Issues

### Layout and Structure Issues
1. **Inconsistent spacing**
   - Uneven spacing between sections (particularly noticeable between grant entries)
   - Inconsistent line spacing between bullet points

2. **Timeline visualization problems**
   - Date ranges on left side sometimes appear cramped
   - Vertical timeline connector line is inconsistently aligned with dots
   - The `--sidebar-width` (7rem) may be insufficient for content

3. **Content overflow**
   - Publication titles are extremely long with awkward line breaks
   - Author lists extend too far and get truncated with "..."
   - Some text runs too close to the right margin

### Visual Design Issues
1. **Color scheme concerns**
   - Bright pink sidebar is visually overwhelming and appears unprofessional
   - Limited contrast between some text and background (especially citation metrics)

2. **Typography inconsistencies**
   - Mixing of font sizes within same content sections
   - Inconsistent font weights across similar content
   - Section headers lack sufficient visual distinction

3. **Alignment problems**
   - Misalignment between publication titles and details
   - Bullet points sometimes misaligned with text
   - Table column width inconsistencies in publications sections

### Content Formatting Issues
1. **Inconsistent date formats**
   - Dates appear in different formats throughout (23/09/1993 vs 01/10/2020)
   - Some date ranges use a dash, others don't

2. **Content organization**
   - "Did not pursue" notes for grants seem oddly placed
   - Skills section in sidebar appears crowded
   - Page 7 has significant empty space at bottom

3. **Responsiveness concerns**
   - Content might not adapt well to different screen sizes or print formats
   - The custom CSS may be conflicting with base template styling

## Template Findings

The implementation is based on the datadrivencv template but has several customizations that may be causing issues:

1. **Custom code modifications**:
   - The comment "MUDEI ISSO" in cv_printing_functions.r indicates timeline display modifications
   - Custom R code for publications and peer reviews not in standard template

2. **CSS customization issues**:
   - Potential incompatibility between custom.css overrides and dd_cv.css base styles
   - The sidebar width (7rem) may be too narrow for content
   - PDF mode settings for decorator alignment need review

3. **Data sourcing**:
   - Using local CSV files instead of Google Sheets (standard in template)

## Recommendations

1. Adjust the sidebar width to accommodate content properly
2. Review and possibly revert timeline display modifications
3. Ensure consistent spacing between sections and content elements
4. Reconsider the color scheme for a more professional appearance
5. Implement cleaner text wrapping for long publication titles
6. Standardize date formats throughout the document
7. Improve visual hierarchy of section headers
8. Check compatibility between custom CSS and template CSS
9. Review pagedown::html_resume CSS dependencies