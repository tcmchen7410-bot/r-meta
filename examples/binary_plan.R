input_path <- Sys.getenv("META_INPUT", unset = "examples/binary_input.csv")
data <- read.csv(input_path, check.names = FALSE)

result <- metabin(event.e, n.e, event.c, n.c,
                  studlab = study, data = data,
                  sm = "RR", method = "MH",
                  common = TRUE, random = TRUE)

artifacts <- list(
  leave_one_out = metainf(result),
  cumulative = metacum(result, pooled = "random")
)

pdf(file.path(output_dir, "forest.pdf"), width = 8, height = 6)
forest(result, layout = "RevMan5")
dev.off()
