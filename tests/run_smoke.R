args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
this_file <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = TRUE)
skill_dir <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)
runner <- file.path(skill_dir, "scripts", "meta_exec.R")
plan <- file.path(skill_dir, "tests", "smoke_plan.R")
out <- tempfile("r-meta-analysis-smoke-")

status <- system2("Rscript", c(runner, plan, out))
if (!identical(status, 0L)) stop("Smoke analysis failed.")

expected <- c(
  "forest.pdf", "forest.png", "forest.tiff",
  "analysis_executed.R", "statistics.csv"
)
missing <- expected[!file.exists(file.path(out, expected))]
if (length(missing)) stop("Missing smoke-test outputs: ", paste(missing, collapse = ", "))
empty <- expected[file.info(file.path(out, expected))$size <= 0]
if (length(empty)) stop("Empty smoke-test outputs: ", paste(empty, collapse = ", "))
actual <- list.files(out, all.files = FALSE, no.. = TRUE)
if (!setequal(actual, expected)) {
  stop("Output directory must contain exactly five deliverables; found: ", paste(actual, collapse = ", "))
}

for (image_file in c("forest.png", "forest.tiff")) {
  image <- magick::image_read(file.path(out, image_file))
  trimmed <- magick::image_trim(image)
  info <- magick::image_info(image)
  trim_info <- magick::image_info(trimmed)
  if (!identical(info$width, trim_info$width) ||
      !identical(info$height, trim_info$height)) {
    stop(image_file, " still contains a removable outer border.")
  }
}

executed <- readLines(file.path(out, "analysis_executed.R"), warn = FALSE)
required_code <- c(
  "library(meta)",
  "library(magick)",
  "invisible(meta::settings.meta(\"RevMan5\"))"
)
if (!all(required_code %in% executed)) {
  stop("analysis_executed.R does not contain the required reproducibility preamble.")
}
if (any(grepl("render_width_in|rows_gr|trim_fuzz|fontsize\\s*=|fontfamily\\s*=|fs\\.[A-Za-z]+\\s*=", executed))) {
  stop("analysis_executed.R overrides forest defaults.")
}

statistics <- utils::read.csv(file.path(out, "statistics.csv"), check.names = FALSE)
if (!all(c("row_type", "model", "effect_measure", "estimate", "lower_95", "upper_95") %in% names(statistics))) {
  stop("statistics.csv is missing required columns.")
}
if (!any(statistics$row_type == "pooled")) stop("statistics.csv has no pooled result.")

cat("Smoke test passed. Output:", out, "\n")
