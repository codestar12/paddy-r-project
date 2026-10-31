# setup.R — install R and the packages needed for the paddy project.
# Run once after cloning:
#   Rscript setup.R          (on Debian/Ubuntu: sudo apt-get install r-base)

pkgs <- c("tidyverse", "janitor", "corrplot", "patchwork", "here")

# On Debian/Ubuntu, install R first if missing:
if (Sys.which("Rscript") == "" && .Platform$OS.type == "unix") {
  cat("R is not installed. On Debian/Ubuntu run:\n  sudo apt-get update\n  sudo apt-get install -y r-base\n")
  quit(status = 1)
}

new_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(new_pkgs) > 0) {
  cat("Installing packages:", paste(new_pkgs, collapse = ", "), "\n")
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", quiet = TRUE)
} else {
  cat("All packages already installed.\n")
}
