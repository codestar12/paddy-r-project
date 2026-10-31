# setup.R — install the packages needed for the paddy project.
# Run once after cloning:  Rscript setup.R
# (If R is missing, `make setup` installs it first via Homebrew or apt-get.)

pkgs <- c("tidyverse", "janitor", "corrplot", "patchwork", "here")

r_ver <- getRversion()
if (r_ver < "4.1") {
  cat("R >= 4.1 is required (found", r_ver, ")\n")
  quit(status = 1)
}

cat("Installing packages:", paste(pkgs, collapse = ", "), "\n")
install.packages(pkgs, repos = "https://cloud.r-project.org")
cat("Done.\n")
