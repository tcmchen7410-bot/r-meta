data <- data.frame(
  study = c("Trial A", "Trial B", "Trial C"),
  event.e = c(12, 8, 20), n.e = c(100, 80, 120),
  event.c = c(18, 14, 25), n.c = c(100, 80, 120)
)

result <- metabin(event.e, n.e, event.c, n.c,
                  studlab = study, data = data,
                  sm = "RR", method = "MH",
                  common = TRUE, random = TRUE)

artifacts <- list(leave_one_out = metainf(result))

pdf(file.path(output_dir, "forest.pdf"), width = 8, height = 6)
forest(result, layout = "RevMan5")
dev.off()
