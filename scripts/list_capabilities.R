#!/usr/bin/env Rscript

packages <- c("meta", "netmeta", "viscomp", "nmaplateplot", "robvis", "RobustVis")
for (pkg in packages) {
  cat("\n##", pkg, "\n")
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("NOT INSTALLED\n")
    next
  }
  cat("Version:", as.character(utils::packageVersion(pkg)), "\n")
  cat(paste(sort(getNamespaceExports(pkg)), collapse = "\n"), "\n")
}
