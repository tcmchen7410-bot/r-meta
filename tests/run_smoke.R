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
  "result.rds", "result_summary.txt", "meta_settings.R",
  "console.txt", "session_info.txt", "forest.pdf", "plan_executed.R"
)
missing <- expected[!file.exists(file.path(out, expected))]
if (length(missing)) stop("Missing smoke-test outputs: ", paste(missing, collapse = ", "))

fit <- readRDS(file.path(out, "result.rds"))
if (!inherits(fit, "meta")) stop("Primary result is not a meta object.")

cat("Smoke test passed. Output:", out, "\n")
