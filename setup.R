# setup.R — install R and the packages needed for the paddy project.
# Run once after cloning:
#   Rscript setup.R
#
# If R is missing, the script tries to install it:
#   - Debian/Ubuntu: sudo apt-get install -y r-base
#   - macOS (Homebrew): brew install r

pkgs <- c("tidyverse", "janitor", "corrplot", "patchwork", "here")

# If R is missing, install it (Linux via apt, macOS via Homebrew):
if (Sys.which("Rscript") == "") {
  cat("R is not installed. Attempting to install R...\n")
  if (.Platform$OS.type == "unix" && Sys.which("apt-get") != "") {
    ok <- system("sudo apt-get update -qq && sudo apt-get install -y -qq r-base") == 0
  } else if (.Platform$OS.type == "unix" && Sys.which("brew") != "") {
    ok <- system("brew install r") == 0
  } else {
    ok <- FALSE
  }
  if (!ok || Sys.which("Rscript") == "") {
    cat("\nR could not be installed automatically.\n")
    cat("Install R >= 4.1 manually, then run:  Rscript setup.R\n")
    quit(status = 1)
  }
}

new_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(new_pkgs) > 0) {
  cat("Installing packages:", paste(new_pkgs, collapse = ", "), "\n")
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", quiet = TRUE)
} else {
  cat("All packages already installed.\n")
}
