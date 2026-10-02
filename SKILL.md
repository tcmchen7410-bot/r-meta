---
name: r-meta-analysis
description: Execute reproducible pairwise meta-analysis with R's meta package using RevMan 5-compatible defaults, plus robvis and RobustVis risk-of-bias visualization, diagnostics, sensitivity analyses, meta-regression, and exports. Use for binary, continuous, generic inverse-variance, correlation, incidence, proportion, single-mean, subgroup, cumulative, influence, publication-bias, and ROBUST-RCT visualization workflows. Do not use for network meta-analysis or diagnostic-test-accuracy models unless another package is explicitly authorized.
---

# R `meta` Analysis

Run the analysis instead of merely drafting code. Use the bundled executor so every run uses the locked RevMan 5 preset and produces the same five-file delivery contract.

## Workflow

1. Inspect input files. Identify the outcome type, effect measure, arm structure, unit of analysis, follow-up, zero-event studies, multi-arm studies, subgroups, and requested model. Never invent study values.
2. Read [references/revman-compatibility.md](references/revman-compatibility.md) before claiming agreement with RevMan. Ask only for choices that materially alter results and cannot be inferred from supplied RevMan output.
3. Read [references/function-map.md](references/function-map.md) to choose functions and [references/plan-recipes.md](references/plan-recipes.md) for starting code. For version-sensitive arguments inspect `formals(meta::FUNCTION)` or installed help. Run `scripts/list_capabilities.R` when complete package coverage or an unfamiliar function is requested.
4. Create a self-contained `plan.R` outside a new, empty output folder. The executor hard-locks `meta::settings.meta("RevMan5")` before sourcing it and rejects any plan that changes the global preset. Express outcome-specific RevMan choices as explicit model-function arguments. Call the injected `export_forest()` exactly once; it hard-locks `layout = "RevMan5"` and creates all three image formats.
5. Execute:

   ```bash
   Rscript /path/to/r-meta-analysis/scripts/meta_exec.R plan.R output-directory
   ```

6. Inspect `statistics.csv` and every image. Resolve validity-affecting warnings and report remaining assumptions.

## Plan contract

The plan may call any exported `meta` function. It must assign the primary fitted object to `result`. The executor injects `output_dir` and `export_forest()`.

```r
data <- read.csv("input.csv", check.names = FALSE)
result <- metabin(event.e, n.e, event.c, n.c,
                  studlab = study, data = data,
                  sm = "RR", method = "MH",
                  common = TRUE, random = TRUE)

export_forest(result, stem = "forest", output_dir = output_dir)
```

`export_forest()` draws on an oversized temporary canvas with extra safety rows, fixes `layout = "RevMan5"`, and uses `magick::image_trim(..., fuzz = 0)` to remove only pure-white margin pixels. It then adds exactly two white pixels on each edge to protect glyph ascenders and descenders from format-specific clipping. PNG, TIFF, and PDF are produced from this same 300 dpi master, so their boundaries match and remain visually tight without sacrificing text. It requires and loads `magick`. Font size, font family, and all `fs.*` arguments are intentionally omitted and rejected so `meta` always uses its own defaults. Do not pass `layout` or font arguments from a plan, and do not replace this helper with a manually sized device.

For conventional risk-of-bias data, use `robvis::rob_traffic_light()` and/or `robvis::rob_summary()`. For ROBUST-RCT step 1 or step 2 assessments, use `RobustVis::rob_bar()` and `RobustVis::rob_traffic_light()`. Read [references/risk-of-bias.md](references/risk-of-bias.md) and save returned ggplot objects.

## Statistical invariants

- Always use the executor's hard-locked `meta::settings.meta("RevMan5")`; never call `settings.meta()` inside a plan to select another preset. Forest plots must use the helper's hard-locked `layout = "RevMan5"` and the package's default font settings.
- Match the target RevMan version's effect measure, model, pooling method, tau estimator, CI method, continuity correction, zero-event handling, subgroup tests, and precision before comparing results.
- Do not run funnel-asymmetry tests with fewer than 10 studies unless explicitly requested as exploratory; label them unreliable.
- Handle multi-arm studies with `pairwise()` or an explicitly justified method. Never silently duplicate controls.
- Preserve modeled and displayed scales, and state both.
- A rounded forest plot match is not sufficient. When RevMan output exists, compare unrounded study effects, SEs, weights, pooled effects, heterogeneity, and totals.

## Deliverables

Return exactly five files: `<stem>.pdf`, `<stem>.png`, `<stem>.tiff`, `analysis_executed.R`, and `statistics.csv`. All three images share the same tightly cropped 300 dpi master. `analysis_executed.R` must be self-contained and visibly include `library(meta)`, `library(magick)`, `meta::settings.meta("RevMan5")`, the export helper, and the analysis plan. `statistics.csv` must contain study-level estimates and weights plus every fitted pooled model and heterogeneity statistics. Do not add logs, RDS files, aliases, or fixed-paper whitespace to the delivery folder.
