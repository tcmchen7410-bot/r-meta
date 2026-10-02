args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
this_file <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = TRUE)
skill_dir <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)

if (!requireNamespace("netmeta", quietly = TRUE) ||
    !requireNamespace("viscomp", quietly = TRUE)) {
  cat("Component smoke test skipped: netmeta and viscomp are required.\n")
  quit(save = "no", status = 0L)
}

expected_viscomp_exports <- c(
  "compdesc", "compGraph", "denscomp", "heatcomp", "loccos",
  "rankheatplot", "specc", "watercomp"
)
missing_exports <- setdiff(expected_viscomp_exports, getNamespaceExports("viscomp"))
if (length(missing_exports)) {
  stop("Missing expected viscomp exports: ", paste(missing_exports, collapse = ", "))
}

runner <- file.path(skill_dir, "scripts", "meta_exec.R")
plan <- file.path(skill_dir, "examples", "component_nma_plan.R")
out <- tempfile("r-meta-analysis-component-smoke-")

status <- system2("Rscript", c(runner, plan, out))
if (!identical(status, 0L)) stop("Component NMA smoke analysis failed.")

expected <- c(
  "result.rds", "artifacts.rds", "result_summary.txt", "meta_settings.R",
  "netmeta_settings.R", "console.txt", "session_info.txt",
  "component_heat.pdf", "component_heat.png", "component_heat.tiff",
  "plan_executed.R"
)
missing <- expected[!file.exists(file.path(out, expected))]
if (length(missing)) stop("Missing component outputs: ", paste(missing, collapse = ", "))

artifacts <- readRDS(file.path(out, "artifacts.rds"))
if (!inherits(artifacts$additive_component_model, "netcomb")) {
  stop("The additive component model is not a netcomb object.")
}

png_info <- magick::image_info(magick::image_read(file.path(out, "component_heat.png")))
if (png_info$width >= 4800 || png_info$height >= 4800) {
  stop("Component image was not tightly cropped.")
}

cat("Component NMA smoke test passed. Output:", out, "\n")
