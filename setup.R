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

# macOS: check that the Xcode Command Line Tools can compile packages.
# Since R >= 4.3, CRAN ships source packages only for macOS (no macOS
# binaries), so every R package on a Mac must be compiled from source.
# If the toolchain is missing or outdated, warn but let the per-package
# install below decide what to do.
clang_ok <- TRUE
if (.Platform$OS.type == "unix" && Sys.info()["sysname"] == "Darwin") {
  clang_ok <- tryCatch({
    xcrun <- Sys.which("xcrun")
    nzchar(xcrun) && system2(xcrun, c("-p", "clang"), stdout = FALSE, stderr = FALSE) == 0
  }, error = function(e) FALSE)
  if (!clang_ok) {
    cat("Note: Xcode Command Line Tools do not appear to be installed or are outdated.\n")
    cat("Since R >= 4.3, macOS packages are installed from source, so a working\n")
    cat("toolchain is required. If packages fail to install, run:\n")
    cat("    xcode-select --install\n")
    cat("If that reports they are already installed, update them:\n")
    cat("    softwareupdate --list\n")
    cat("and install any 'Command Line Tools' update it lists.\n")
    cat("Then re-run:  make setup\n\n")
  }
}

# Install packages one at a time so a failure in one package does not
# abort the rest; report any failures at the end. On macOS, install.packages
# reports source-build failures as warnings, so warnings are treated as
# failures too.
failed <- character()
for (pkg in pkgs) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("OK:", pkg, "\n")
  } else {
    cat("Installing", pkg, "...\n")
    got_warning <- character()
    ok <- tryCatch(
      withCallingHandlers(
        {install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE);
         TRUE},
        warning = function(w) {
          got_warning <<- c(got_warning, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(e) FALSE
    )
    if (isTRUE(ok) && length(got_warning) > 0) {
      ok <- FALSE
    }
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
  if (!clang_ok) {
    cat("Most likely cause: missing or outdated Xcode Command Line Tools.\n")
    cat("Install or update them (xcode-select --install, then softwareupdate --list),\n")
    cat("then re-run:  make setup\n")
  } else {
    cat("If you are on macOS, install the Xcode Command Line Tools:\n")
    cat("    xcode-select --install\n")
    cat("then re-run:  make setup\n")
  }
  quit(status = 1)
}

cat("All packages installed.\n")
