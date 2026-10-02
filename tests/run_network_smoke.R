args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
this_file <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = TRUE)
skill_dir <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)

if (!requireNamespace("netmeta", quietly = TRUE)) {
  cat("Network smoke test skipped: package 'netmeta' is not installed.\n")
  quit(save = "no", status = 0L)
}

runner <- file.path(skill_dir, "scripts", "meta_exec.R")
plan <- file.path(skill_dir, "examples", "network_plan.R")
out <- tempfile("r-meta-analysis-network-smoke-")

status <- system2("Rscript", c(runner, plan, out))
if (!identical(status, 0L)) stop("Network smoke analysis failed.")

expected <- c(
  "result.rds", "result_summary.txt", "meta_settings.R",
  "netmeta_settings.R", "console.txt", "session_info.txt",
  "network.pdf", "network.png", "network.tiff", "plan_executed.R"
)
if (requireNamespace("nmaplateplot", quietly = TRUE)) {
  expected <- c(expected, "league_plateplot.pdf", "league_plateplot.png",
                "league_plateplot.tiff")
}
missing <- expected[!file.exists(file.path(out, expected))]
if (length(missing)) stop("Missing network outputs: ", paste(missing, collapse = ", "))

fit <- readRDS(file.path(out, "result.rds"))
if (!inherits(fit, "netmeta")) stop("Primary result is not a netmeta object.")
if (!identical(fit$reference.group, "plac")) {
  stop("Network example did not retain 'plac' as reference treatment.")
}

png_info <- magick::image_info(magick::image_read(file.path(out, "network.png")))
if (png_info$width >= 4800 || png_info$height >= 4800) {
  stop("Network image was not tightly cropped.")
}

if (requireNamespace("nmaplateplot", quietly = TRUE)) {
  plate_info <- magick::image_info(
    magick::image_read(file.path(out, "league_plateplot.png"))
  )
  if (plate_info$width >= 8500 || plate_info$height >= 6000) {
    stop("Plate plot was not tightly cropped.")
  }
  plate_ratio <- plate_info$width / plate_info$height
  if (plate_ratio < 1.85 || plate_ratio > 2.25) {
    stop("Plate plot aspect ratio does not match the reference cell geometry.")
  }
}

cat("Network smoke test passed. Output:", out, "\n")
