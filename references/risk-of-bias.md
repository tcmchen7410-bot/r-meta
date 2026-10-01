# Risk-of-bias visualization

## `robvis`

Use for standard risk-of-bias tools. Primary functions:

- `robvis::rob_traffic_light(data, tool, ...)`
- `robvis::rob_summary(data, tool, ...)`

Inspect installed help for accepted tools and column structure. Preserve the original assessment table and validate domain labels.

## `RobustVis`

`RobustVis` is case-sensitive and distinct from `robvis`. Version 0.1.2 implements visualization for ROBUST-RCT assessments.

- Step 1 data: first column is the study label, followed by Item 1–5 using `DY`, `PY`, `PN`, or `DN`.
- Step 2 data: first column is the study label, followed by Item 1–6 using `DH`, `PH`, `PL`, or `DL`.
- Summary bar plot: `RobustVis::rob_bar(data, step = 1)` or `step = 2`.
- Traffic-light plot: `RobustVis::rob_traffic_light(data, step = 1)` or `step = 2`.
- Bundled examples: `RobustVis::data_step1` and `RobustVis::data_step2`.

Example:

```r
rob_bar_plot <- RobustVis::rob_bar(rob_data, step = 1)
rob_light_plot <- RobustVis::rob_traffic_light(rob_data, step = 1)
ggplot2::ggsave(file.path(output_dir, "robust_bar.pdf"), rob_bar_plot,
                width = 10, height = 6)
ggplot2::ggsave(file.path(output_dir, "robust_traffic_light.pdf"), rob_light_plot,
                width = 10, height = 7)
```

For either package, save ggplot objects with `ggplot2::ggsave()`. Do not interchange their data schemas or function namespaces.
