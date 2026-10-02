if (!requireNamespace("viscomp", quietly = TRUE)) {
  stop("Package 'viscomp' is required for this example.")
}

data("nmaMACE", package = "viscomp")
result <- nmaMACE

component_model <- netcomb(result)
description <- viscomp::compdesc(result, sep = "+", heatmap = FALSE)
component_heat <- viscomp::heatcomp(result, sep = "+", random = TRUE)

artifacts <- list(
  additive_component_model = component_model,
  component_frequency = description$frequency,
  component_crosstable = description$crosstable,
  component_heat = component_heat
)

ggplot2::ggsave(
  file.path(output_dir, "component_heat.pdf"),
  plot = component_heat
)
