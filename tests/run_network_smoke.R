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
  "network.pdf", "plan_executed.R"
)
missing <- expected[!file.exists(file.path(out, expected))]
if (length(missing)) stop("Missing network outputs: ", paste(missing, collapse = ", "))

fit <- readRDS(file.path(out, "result.rds"))
if (!inherits(fit, "netmeta")) stop("Primary result is not a netmeta object.")

cat("Network smoke test passed. Output:", out, "\n")
