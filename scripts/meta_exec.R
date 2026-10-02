#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: Rscript meta_exec.R PLAN.R OUTPUT_DIR", call. = FALSE)

plan <- normalizePath(args[[1]], mustWork = TRUE)
output_dir <- normalizePath(args[[2]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_dir <- normalizePath(output_dir, mustWork = TRUE)

all_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", all_args, value = TRUE)
if (length(file_arg) != 1L) stop("Cannot locate meta_exec.R.", call. = FALSE)
runner_file <- normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
helper_file <- file.path(dirname(runner_file), "export_plot.R")
if (!file.exists(helper_file)) stop("Missing scripts/export_plot.R.", call. = FALSE)

if (!requireNamespace("meta", quietly = TRUE)) stop("R package 'meta' is required.", call. = FALSE)
if (!requireNamespace("magick", quietly = TRUE)) stop("R package 'magick' is required.", call. = FALSE)

log_file <- tempfile(fileext = ".txt")
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
library(magick)
netmeta_available <- requireNamespace("netmeta", quietly = TRUE)
if (netmeta_available) suppressPackageStartupMessages(library(netmeta))
viscomp_available <- requireNamespace("viscomp", quietly = TRUE)
if (viscomp_available) suppressPackageStartupMessages(library(viscomp))
invisible(meta::settings.meta("RevMan5"))
revman5_settings <- meta::settings.meta(quietly = TRUE)

analysis_env <- new.env(parent = globalenv())
analysis_env$output_dir <- output_dir
analysis_env$plan_file <- plan
sys.source(helper_file, envir = analysis_env, keep.source = TRUE)
analysis_env$package_exports <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("R package '", package, "' is required but not installed.", call. = FALSE)
  }
  sort(getNamespaceExports(package))
}
analysis_env$optional_package_exports <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) return(character())
  sort(getNamespaceExports(package))
}

ok <- tryCatch({
  sys.source(plan, envir = analysis_env, keep.source = TRUE)
  current_settings <- meta::settings.meta(quietly = TRUE)
  if (!identical(current_settings, revman5_settings)) {
    stop("PLAN.R changed global meta settings. This skill locks settings.meta('RevMan5').")
  }
  if (!exists("result", envir = analysis_env, inherits = FALSE)) {
    stop("PLAN.R must assign the primary meta-analysis object to 'result'.")
  }
  result <- get("result", envir = analysis_env, inherits = FALSE)

  artifacts <- NULL
  if (exists("artifacts", envir = analysis_env, inherits = FALSE)) {
    artifacts <- get("artifacts", envir = analysis_env, inherits = FALSE)
    if (!is.list(artifacts) || is.null(names(artifacts))) {
      stop("'artifacts' must be a named list.")
    }
  }

  executed_code <- c(
    "#!/usr/bin/env Rscript",
    "",
    "library(meta)",
    "library(magick)",
    "if (requireNamespace(\"netmeta\", quietly = TRUE)) library(netmeta)",
    "if (requireNamespace(\"viscomp\", quietly = TRUE)) library(viscomp)",
    "invisible(meta::settings.meta(\"RevMan5\"))",
    paste0("output_dir <- ", deparse(output_dir)),
    paste0("plan_file <- ", deparse(plan)),
    "dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)",
    "",
    "# Export helper executed by the analysis runner",
    readLines(helper_file, warn = FALSE),
    "",
    "# Analysis plan",
    readLines(plan, warn = FALSE)
  )
  writeLines(executed_code, file.path(output_dir, "analysis_executed.R"), useBytes = TRUE)

  is_pairwise_meta <- inherits(result, "meta") && !inherits(result, "netmeta")

  if (!is_pairwise_meta) {
    saveRDS(result, file.path(output_dir, "result.rds"))
    dput(current_settings, file = file.path(output_dir, "meta_settings.R"))
    if (netmeta_available) {
      dput(netmeta::settings.netmeta(quietly = TRUE),
           file = file.path(output_dir, "netmeta_settings.R"))
    }
    capture.output(print(result), file = file.path(output_dir, "result_summary.txt"))
    capture.output(utils::sessionInfo(), file = file.path(output_dir, "session_info.txt"))
    if (!is.null(artifacts)) {
      saveRDS(artifacts, file.path(output_dir, "artifacts.rds"))
      for (nm in names(artifacts)) {
        capture.output(print(artifacts[[nm]]),
                       file = file.path(output_dir, paste0("artifact_", nm, ".txt")))
      }
    }
    file.copy(plan, file.path(output_dir, "plan_executed.R"), overwrite = TRUE)
    flush(zz)
    file.copy(log_file, file.path(output_dir, "console.txt"), overwrite = TRUE)
  } else {

  bt <- function(value) {
    if (is.null(value)) return(numeric())
    if (!isTRUE(result$backtransf)) return(as.numeric(value))
    tryCatch(
      as.numeric(meta::backtransf(value, sm = result$sm)),
      error = function(e) as.numeric(value)
    )
  }
  study_rows <- data.frame(
    row_type = "study",
    study = result$studlab,
    model = NA_character_,
    effect_measure = result$sm,
    estimate = bt(result$TE),
    lower_95 = bt(result$lower),
    upper_95 = bt(result$upper),
    weight_percent = NA_real_,
    p_value = NA_real_,
    k = NA_integer_,
    Q = NA_real_, Q_df = NA_real_, Q_p = NA_real_,
    tau2 = NA_real_, I2_percent = NA_real_,
    stringsAsFactors = FALSE
  )
  pooled_rows <- list()
  add_model <- function(name, te, lower, upper, p_value, weight) {
    if (!length(te) || is.na(te)) return(NULL)
    data.frame(
      row_type = "pooled",
      study = "Overall",
      model = name,
      effect_measure = result$sm,
      estimate = bt(te), lower_95 = bt(lower), upper_95 = bt(upper),
      weight_percent = 100, p_value = p_value, k = result$k,
      Q = result$Q, Q_df = result$df.Q, Q_p = result$pval.Q,
      tau2 = result$tau2, I2_percent = result$I2,
      stringsAsFactors = FALSE
    )
  }
  if (isTRUE(result$common)) {
    study_common <- study_rows
    study_common$model <- "common"
    study_common$weight_percent <- 100 * result$w.common / sum(result$w.common)
    pooled_rows[["common"]] <- add_model(
      "common", result$TE.common, result$lower.common, result$upper.common,
      result$pval.common, result$w.common
    )
    study_rows <- study_common
  }
  if (isTRUE(result$random)) {
    study_random <- study_rows
    study_random$model <- "random"
    study_random$weight_percent <- 100 * result$w.random / sum(result$w.random)
    if (isTRUE(result$common)) study_rows <- rbind(study_rows, study_random) else study_rows <- study_random
    pooled_rows[["random"]] <- add_model(
      "random", result$TE.random, result$lower.random, result$upper.random,
      result$pval.random, result$w.random
    )
  }
  statistics <- do.call(rbind, c(list(study_rows), pooled_rows))
  utils::write.csv(statistics, file.path(output_dir, "statistics.csv"), row.names = FALSE, na = "")

  images <- list.files(output_dir, pattern = "\\.(pdf|png|tiff)$", full.names = FALSE)
  stems <- sub("\\.(pdf|png|tiff)$", "", images)
  if (length(images) != 3L || length(unique(stems)) != 1L) {
    stop("A run must create exactly one matching PDF/PNG/TIFF image set.")
  }
  }
  TRUE
}, error = function(e) {
  cat("\nERROR:", conditionMessage(e), "\n")
  FALSE
})

if (!ok) quit(save = "no", status = 1L)
cat("\nAnalysis completed successfully.\n")
