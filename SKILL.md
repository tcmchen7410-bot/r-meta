---
name: r-meta-analysis
description: Execute reproducible pairwise meta-analysis with R's meta package using RevMan 5-compatible defaults, plus robvis and RobustVis risk-of-bias visualization, diagnostics, sensitivity analyses, meta-regression, and exports. Use for binary, continuous, generic inverse-variance, correlation, incidence, proportion, single-mean, subgroup, cumulative, influence, publication-bias, and ROBUST-RCT visualization workflows. Do not use for network meta-analysis or diagnostic-test-accuracy models unless another package is explicitly authorized.
---

# R `meta` Analysis

Run the analysis instead of merely drafting code. Use the bundled executor so each run preserves the exact plan, R objects, settings, console output, session information, and generated files.

## Workflow

1. Inspect input files. Identify the outcome type, effect measure, arm structure, unit of analysis, follow-up, zero-event studies, multi-arm studies, subgroups, and requested model. Never invent study values.
2. Read [references/revman-compatibility.md](references/revman-compatibility.md) before claiming agreement with RevMan. Ask only for choices that materially alter results and cannot be inferred from supplied RevMan output.
3. Read [references/function-map.md](references/function-map.md) to choose functions and [references/plan-recipes.md](references/plan-recipes.md) for starting code. For version-sensitive arguments inspect `formals(meta::FUNCTION)` or installed help. Run `scripts/list_capabilities.R` when complete package coverage or an unfamiliar function is requested.
4. Create a self-contained `plan.R` in the user's output folder. The executor hard-locks `settings.meta("RevMan5")` before sourcing it and rejects any plan that changes the global preset. Express outcome-specific RevMan choices as explicit model-function arguments.
5. Execute:

   ```bash
   Rscript /path/to/r-meta-analysis/scripts/meta_exec.R plan.R output-directory
   ```

6. Inspect `console.txt`, `result_summary.txt`, tables, and every plot. Resolve validity-affecting warnings and report remaining assumptions.

## Plan contract

The plan may call any exported `meta` function. It must assign the primary fitted object to `result`. Put additional fitted or diagnostic objects in a named list `artifacts`. The executor injects `output_dir`.

```r
data <- read.csv("input.csv", check.names = FALSE)
result <- metabin(event.e, n.e, event.c, n.c,
                  studlab = study, data = data,
                  sm = "RR", method = "MH",
                  common = TRUE, random = TRUE)

artifacts <- list(
  leave_one_out = metainf(result),
  cumulative = metacum(result, pooled = "random")
)

pdf(file.path(output_dir, "forest.pdf"), width = 9, height = 7)
forest(result, layout = "RevMan5")
dev.off()
```

For conventional risk-of-bias data, use `robvis::rob_traffic_light()` and/or `robvis::rob_summary()`. For ROBUST-RCT step 1 or step 2 assessments, use `RobustVis::rob_bar()` and `RobustVis::rob_traffic_light()`. Read [references/risk-of-bias.md](references/risk-of-bias.md) and save returned ggplot objects.

## Statistical invariants

- Always use the executor's hard-locked `settings.meta("RevMan5")`; never call `settings.meta()` inside a plan to select another preset.
- Match the target RevMan version's effect measure, model, pooling method, tau estimator, CI method, continuity correction, zero-event handling, subgroup tests, and precision before comparing results.
- Do not run funnel-asymmetry tests with fewer than 10 studies unless explicitly requested as exploratory; label them unreliable.
- Handle multi-arm studies with `pairwise()` or an explicitly justified method. Never silently duplicate controls.
- Preserve modeled and displayed scales, and state both.
- A rounded forest plot match is not sufficient. When RevMan output exists, compare unrounded study effects, SEs, weights, pooled effects, heterogeneity, and totals.

## Deliverables

Return the executed plan, `result.rds`, console and session logs, requested tables and plots, and a short methods note listing every consequential setting. Separate primary, subgroup, sensitivity, and exploratory results.
