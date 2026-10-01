#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: Rscript meta_exec.R PLAN.R OUTPUT_DIR", call. = FALSE)

plan <- normalizePath(args[[1]], mustWork = TRUE)
output_dir <- normalizePath(args[[2]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_dir <- normalizePath(output_dir, mustWork = TRUE)

if (!requireNamespace("meta", quietly = TRUE)) stop("R package 'meta' is required.", call. = FALSE)

log_file <- file.path(output_dir, "console.txt")
zz <- file(log_file, open = "wt")
sink(zz, type = "output")
sink(zz, type = "message")
on.exit({
  while (sink.number(type = "message") > 0) sink(type = "message")
  while (sink.number(type = "output") > 0) sink(type = "output")
  close(zz)
}, add = TRUE)

cat("Plan:", plan, "\nOutput:", output_dir, "\n")
library(meta)
invisible(settings.meta("RevMan5"))
revman5_settings <- settings.meta(quietly = TRUE)

analysis_env <- new.env(parent = globalenv())
analysis_env$output_dir <- output_dir
analysis_env$plan_file <- plan
analysis_env$optional_package_exports <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) return(character())
  sort(getNamespaceExports(package))
}

ok <- tryCatch({
  sys.source(plan, envir = analysis_env, keep.source = TRUE)
  current_settings <- settings.meta(quietly = TRUE)
  if (!identical(current_settings, revman5_settings)) {
    stop("PLAN.R changed global meta settings. This skill locks settings.meta('RevMan5').")
  }
  if (!exists("result", envir = analysis_env, inherits = FALSE)) {
    stop("PLAN.R must assign the primary meta-analysis object to 'result'.")
  }
  result <- get("result", envir = analysis_env, inherits = FALSE)
  saveRDS(result, file.path(output_dir, "result.rds"))
  dput(current_settings, file = file.path(output_dir, "meta_settings.R"))
  capture.output(print(result), file = file.path(output_dir, "result_summary.txt"))
  capture.output(utils::sessionInfo(), file = file.path(output_dir, "session_info.txt"))

  if (exists("artifacts", envir = analysis_env, inherits = FALSE)) {
    artifacts <- get("artifacts", envir = analysis_env, inherits = FALSE)
    if (!is.list(artifacts) || is.null(names(artifacts))) stop("'artifacts' must be a named list.")
    saveRDS(artifacts, file.path(output_dir, "artifacts.rds"))
    for (nm in names(artifacts)) {
      capture.output(print(artifacts[[nm]]), file = file.path(output_dir, paste0("artifact_", nm, ".txt")))
    }
  }

  file.copy(plan, file.path(output_dir, "plan_executed.R"), overwrite = TRUE)
  TRUE
}, error = function(e) {
  cat("\nERROR:", conditionMessage(e), "\n")
  FALSE
})

if (!ok) quit(save = "no", status = 1L)
cat("\nAnalysis completed successfully.\n")
