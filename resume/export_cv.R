# Build the long CV: knit index.Rmd, then print the paged.js HTML to PDF.
# pagedown::chrome_print drives Chrome over its remote-debugging port, which is
# blocked in some environments; fall back to Chrome's own --print-to-pdf there.
chrome_binary <- function(){
  candidates <- c(
    Sys.getenv("CHROME_BIN"),
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
  )
  candidates <- candidates[nzchar(candidates)]
  found <- candidates[file.exists(candidates)]
  if(length(found)) found[1] else ""
}

print_with_chrome <- function(html = "index.html", pdf = "index.pdf"){
  chrome <- chrome_binary()
  if(!nzchar(chrome)) stop("No Chrome binary found; set CHROME_BIN.")
  profile <- tempfile("chrome-profile-")
  dir.create(profile)
  on.exit(unlink(profile, recursive = TRUE), add = TRUE)
  args <- c("--headless=new", "--disable-gpu", "--no-sandbox",
            paste0("--user-data-dir=", profile),
            "--virtual-time-budget=60000",
            "--run-all-compositor-stages-before-draw",
            "--no-pdf-header-footer",
            paste0("--print-to-pdf=", normalizePath(pdf, mustWork = FALSE)),
            paste0("file://", normalizePath(html)))
  # Headless Chrome writes the PDF and then sometimes lingers, so launch it in
  # the background, wait for the file to appear and stop growing, then stop it.
  pdf <- normalizePath(pdf, mustWork = FALSE)
  if(file.exists(pdf)) unlink(pdf)
  system2(chrome, shQuote(args), stdout = FALSE, stderr = FALSE, wait = FALSE)
  size <- -1
  for(i in 1:150){
    Sys.sleep(2)
    if(file.exists(pdf)){
      new_size <- file.size(pdf)
      if(new_size > 0 && identical(new_size, size)) break
      size <- new_size
    }
  }
  system2("pkill", c("-f", shQuote(profile)), stdout = FALSE, stderr = FALSE)
  if(!file.exists(pdf)) stop("Chrome did not produce ", pdf)
  message("Wrote ", pdf, " via headless Chrome")
}

export_cv <- function(){
  # Recent Chrome builds can take >10 s to open the debugging port, longer than
  # pagedown's default 20 x 0.5 s wait; allow up to a minute.
  options(pagedown.remote.maxattempts = 120)
  rmarkdown::render("index.Rmd")
  tryCatch(pagedown::chrome_print("index.html", timeout = 240),
           error = function(e){
             message("pagedown::chrome_print failed (", conditionMessage(e), "); using headless Chrome directly")
             print_with_chrome()
           })
}

export_cv()
