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

# On macOS, compiling packages needs the Xcode Command Line Tools:
if (.Platform$OS.type == "unix" && Sys.info()["sysname"] == "Darwin" &&
    nzchar(Sys.which("xcode-select")) && !file.exists("/Library/Developer/CommandLineTools")) {
  cat("Xcode Command Line Tools are missing - R packages cannot be compiled.\n")
  cat("Install them by running (in a terminal):\n")
  cat("    xcode-select --install\n")
  cat("Accept the license dialog, then re-run:  make setup\n")
  quit(status = 1)
}

# Install packages one at a time so a failure in one package does not
# abort the rest; report any failures at the end.
failed <- character()
for (pkg in pkgs) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("OK:", pkg, "\n")
  } else {
    cat("Installing", pkg, "...\n")
    ok <- tryCatch(
      {install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE);
       TRUE},
      error = function(e) FALSE
    )
    if (isTRUE(ok)) {
      cat("OK:", pkg, "\n")
    } else {
      cat("FAILED:", pkg, "\n")
      failed <- c(failed, pkg)
    }
  }
}

if (length(failed) > 0) {
  cat("\nThe following packages could not be installed:", paste(failed, collapse = ", "), "\n")
  cat("If you are on macOS, install the Xcode Command Line Tools first:\n")
  cat("    xcode-select --install\n")
  cat("then re-run:  make setup\n")
  quit(status = 1)
}

cat("All packages installed.\n")
