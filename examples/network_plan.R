data <- data.frame(
  studlab = c("Trial 1", "Trial 2", "Trial 3", "Trial 4"),
  treat1 = c("A", "A", "B", "A"),
  treat2 = c("B", "C", "C", "B"),
  TE = c(-0.30, -0.55, -0.20, -0.25),
  seTE = c(0.15, 0.18, 0.14, 0.16)
)

result <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = data,
  sm = "MD",
  reference.group = "A",
  common = FALSE,
  random = TRUE,
  small.values = "desirable"
)

artifacts <- list(
  ranking = netrank(result, small.values = "desirable"),
  design_decomposition = decomp.design(result)
)

grDevices::pdf(file.path(output_dir, "network.pdf"), width = 7, height = 7)
netgraph(result)
grDevices::dev.off()
