# setup.R — install the packages needed for the paddy project.
# Run once after cloning:  Rscript setup.R
# (If R is missing, `make setup` installs it first via Homebrew or apt-get.)

pkgs <- c("tidyverse", "janitor", "corrplot", "patchwork", "here")

# Require R >= 4.1:
r_ver <- getRversion()
if (r_ver < "4.1") {
  cat("R >= 4.1 is required (found", r_ver, ")\n")
  quit(status = 1)
}

new_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(new_pkgs) > 0) {
  cat("Installing packages:", paste(new_pkgs, collapse = ", "), "\n")
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", quiet = TRUE)
} else {
  cat("All packages already installed.\n")
}
