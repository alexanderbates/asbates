# Build a clean, vertical, scroll-down visual timeline from entries.csv.
# No plotly / htmlwidgets: emits a self-contained, theme-wrapped HTML page.
# Run from the repo root:  Rscript resume/build_timeline.R
# Output: content/timeline/index.html

ent <- read.csv("resume/entries.csv", stringsAsFactors = FALSE, check.names = TRUE)
ent <- ent[ent$in_resume %in% c(TRUE, "TRUE", "true"), , drop = FALSE]

parse_d <- function(x) { x[is.na(x) | x == ""] <- NA; as.Date(x, format = "%d/%m/%Y") }
ent$sd <- parse_d(ent$start)
ent$ed <- parse_d(ent$end)
ent$key <- ent$sd
ent$key[is.na(ent$key)] <- ent$ed[is.na(ent$key)]
ent <- ent[!is.na(ent$key), , drop = FALSE]
ent <- ent[order(ent$key, decreasing = TRUE), , drop = FALSE]

yr <- function(d) as.integer(format(d, "%Y"))
disp <- function(sd, ed) {
  y1 <- yr(sd); y2 <- if (!is.na(ed)) yr(ed) else NA
  if (!is.na(y2) && y2 != y1) paste0(min(y1, y2), "–", max(y1, y2)) else as.character(y1)
}
he <- function(x) { x <- ifelse(is.na(x), "", x); x <- gsub("&", "&amp;", x); x <- gsub("<", "&lt;", x); gsub(">", "&gt;", x) }
# escape, strip **bold**, and turn markdown [text](url) into real links
mdl <- function(x) {
  x <- he(x)
  x <- gsub("\\*\\*", "", x)
  gsub("\\[([^]]+)\\]\\(([^) ]+)\\)", '<a href="\\2" target="_blank" rel="noopener">\\1</a>', x)
}

catcol <- c(research_projects = "#6e5f48", education = "#6e5f48", grants = "#c08a3e",
            meetings = "#5b8a72", posters = "#7fa8c9", leadership_experience = "#b5685f",
            experience = "#8a7a9e", publications = "#9e6b8a")
catlab <- c(research_projects = "Position", education = "Education", grants = "Award / grant",
            meetings = "Talk", posters = "Poster", leadership_experience = "Leadership",
            experience = "Experience", publications = "Publication")

items <- character(0); last_year <- NA; side <- "left"
for (i in seq_len(nrow(ent))) {
  r <- ent[i, ]
  y <- yr(r$key)
  if (is.na(last_year) || y != last_year) {
    items <- c(items, sprintf('<div class="vtl-year"><span>%d</span></div>', y)); last_year <- y
  }
  col <- catcol[[r$section]]; if (is.null(col) || is.na(col)) col <- "#6e5f48"
  lab <- catlab[[r$section]]; if (is.null(lab) || is.na(lab)) lab <- r$section
  title <- if (!is.na(r$title) && nchar(r$title) > 0) r$title else r$event
  meta <- paste(Filter(function(z) !is.na(z) && nchar(z) > 0, c(r$institution, r$loc)), collapse = " · ")
  show_desc <- r$section %in% c("research_projects", "education", "grants") && !is.na(r$description_1) && nchar(r$description_1) > 0
  card <- sprintf('<div class="vtl-card"><span class="vtl-date">%s &middot; %s</span><h4>%s</h4>%s%s</div>',
                  disp(r$sd, r$ed), he(lab), mdl(title),
                  if (nchar(meta) > 0) sprintf('<p class="vtl-meta">%s</p>', he(meta)) else "",
                  if (show_desc) sprintf('<p class="vtl-desc">%s</p>', mdl(r$description_1)) else "")
  items <- c(items, sprintf('<div class="vtl-item vtl-%s"><span class="vtl-dot" style="background:%s"></span>%s</div>', side, col, card))
  side <- if (side == "left") "right" else "left"
}

# Begin the timeline at the very bottom (oldest) with birth
items <- c(items, '<div class="vtl-year"><span>1993</span></div>')
items <- c(items, sprintf('<div class="vtl-item vtl-%s"><span class="vtl-dot" style="background:#6e5f48"></span><div class="vtl-card"><span class="vtl-date">23 September 1993 &middot; Born</span><h4>Born in London</h4></div></div>', side))

css <- '<style>
.vtl-intro{color:#666;margin-bottom:1.4em;}
.vtl{position:relative;max-width:780px;margin:1em auto 3em;}
.vtl::before{content:"";position:absolute;left:50%;top:0;bottom:0;width:2px;background:#e7ddcf;transform:translateX(-50%);}
.vtl-year{position:relative;text-align:center;margin:1.4em 0 .7em;z-index:2;}
.vtl-year span{background:#6e5f48;color:#fff;padding:3px 14px;border-radius:14px;font-size:.82em;font-weight:600;letter-spacing:.02em;}
.vtl-item{position:relative;width:50%;padding:.45em 2em;box-sizing:border-box;}
.vtl-left{left:0;text-align:right;}
.vtl-right{left:50%;text-align:left;}
.vtl-dot{position:absolute;top:1em;width:12px;height:12px;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 1.5px #d59874;z-index:2;}
.vtl-left .vtl-dot{right:-7px;}
.vtl-right .vtl-dot{left:-7px;}
.vtl-card{display:inline-block;text-align:left;background:#fff;border:1px solid #ece4d8;border-radius:7px;padding:.55em .8em;box-shadow:0 1px 5px rgba(0,0,0,.06);max-width:100%;}
.vtl-card:hover{box-shadow:0 2px 10px rgba(0,0,0,.1);}
.vtl-date{display:block;font-size:.74em;color:#a98c63;font-weight:600;text-transform:uppercase;letter-spacing:.03em;}
.vtl-card h4{margin:.15em 0 .15em;font-size:.97em;line-height:1.3;color:#333;}
.vtl-meta{font-size:.8em;color:#999;margin:0 0 .15em;}
.vtl-desc{font-size:.82em;color:#666;margin:.1em 0 0;line-height:1.4;}
@media(max-width:700px){
  .vtl::before{left:18px;}
  .vtl-item{width:100%;left:0!important;text-align:left!important;padding:.45em 0 .45em 44px;}
  .vtl-left .vtl-dot,.vtl-right .vtl-dot{left:12px;right:auto;}
  .vtl-year{text-align:left;padding-left:6px;}
}
</style>'

page <- paste0('---\ntitle: "timeline"\n---\n\n', css,
               '\n<p class="vtl-intro">A timeline of my research, training, talks and awards. Scroll down to travel back through time.</p>\n',
               '<div class="vtl">\n', paste(items, collapse = "\n"), '\n</div>\n')

writeLines(page, "content/timeline/index.html")
cat("Wrote content/timeline/index.html with", nrow(ent), "events.\n")
