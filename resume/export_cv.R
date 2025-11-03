export_cv <- function(){
  rmarkdown::render("index.Rmd")
  pagedown::chrome_print("index.html")
}

export_cv()
