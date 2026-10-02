---
name: r-meta-analysis
description: Execute reproducible pairwise, frequentist network, and component network meta-analysis in R with meta, netmeta, and viscomp, plus robvis and RobustVis risk-of-bias visualization. Use for RevMan 5-compatible analyses, network synthesis, additive component models, component visual exploration, ranking, inconsistency, contribution, meta-regression, subgroup, diagnostics, sensitivity, publication-bias, and ROBUST-RCT workflows. Do not use for diagnostic-test-accuracy models unless another package is explicitly authorized.
---

# R `meta`, `netmeta`, and `viscomp` Analysis

Run the analysis instead of merely drafting code. Use the bundled executor so each run preserves the exact plan, R objects, settings, console output, session information, and generated files.

## Workflow

1. Inspect input files. Identify the outcome type, effect measure, arm structure, unit of analysis, follow-up, zero-event studies, multi-arm studies, subgroups, and requested model. Never invent study values.
2. Read [references/revman-compatibility.md](references/revman-compatibility.md) before claiming agreement with RevMan. Ask only for choices that materially alter results and cannot be inferred from supplied RevMan output.
3. Route conventional pairwise work through [references/function-map.md](references/function-map.md) and [references/plan-recipes.md](references/plan-recipes.md). For network meta-analysis, read [references/netmeta.md](references/netmeta.md). For multi-component interventions, also read [references/component-nma.md](references/component-nma.md). For version-sensitive arguments inspect installed help and `formals()`; supplied manuals may describe newer versions than installed packages.
4. Run `scripts/list_capabilities.R` whenever complete package coverage or an unfamiliar function is requested. The executor attaches `meta` and, when installed, `netmeta` and `viscomp`; therefore a plan may call every exported function in the installed versions. Registered S3 methods remain available through their generics.
5. Create a self-contained `plan.R` in the user's output folder. The executor hard-locks `settings.meta("RevMan5")` before sourcing it and rejects any plan that changes that preset. This lock governs `meta`; it does not make a network analysis RevMan-compatible. `netmeta` settings may be changed explicitly when scientifically justified and are captured in the output.
6. Execute:

   ```bash
   Rscript /path/to/r-meta-analysis/scripts/meta_exec.R plan.R output-directory
   ```

7. Inspect `console.txt`, `result_summary.txt`, tables, network connectivity, direct evidence, and every plot. Resolve validity-affecting warnings and report remaining assumptions.

## Plan contract

The plan may call any exported `meta`, installed `netmeta`, or installed `viscomp` function. It must assign the primary fitted object to `result`. Put additional fitted or diagnostic objects in a named list `artifacts`. The executor injects `output_dir`, `plan_file`, `package_exports()`, and `optional_package_exports()`.

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

For a network, validate connectedness and treatment coding before fitting. Preserve multi-arm correlations, declare the reference treatment and effect direction, and distinguish direct, indirect, and network estimates. Do not describe `netmeta` output as RevMan 5 output.

For component NMA, fit the standard intervention network with `netmeta()`, estimate additive or interaction component models with `netcomb()` / related `netmeta` functions, and pass the standard `netmeta` object to `viscomp` for visual exploration. Do not pass a `netcomb` object to `viscomp` functions that explicitly require class `netmeta`.

## Statistical invariants

- Always use the executor's hard-locked `settings.meta("RevMan5")`; never call `settings.meta()` inside a plan to select another preset.
- Match the target RevMan version's effect measure, model, pooling method, tau estimator, CI method, continuity correction, zero-event handling, subgroup tests, and precision before comparing results.
- Do not run funnel-asymmetry tests with fewer than 10 studies unless explicitly requested as exploratory; label them unreliable.
- Handle multi-arm studies with `pairwise()` or an explicitly justified method. Never silently duplicate controls.
- Preserve modeled and displayed scales, and state both.
- A rounded forest plot match is not sufficient. When RevMan output exists, compare unrounded study effects, SEs, weights, pooled effects, heterogeneity, and totals.
- For network meta-analysis, evaluate the transitivity assumption from clinical and methodological effect modifiers before interpreting consistency statistics.
- Do not rank treatments without reporting uncertainty, network connectivity, and effect direction. Ranking is descriptive, not proof of superiority.
- Never construct independent pairwise rows from a multi-arm study in a way that discards within-study correlation. Use arm-level workflows or valid correlated contrasts.
- Component names and separators must be consistent across every intervention label; a component is not identifiable merely because it appears in the data.
- Compare additive component-model fit with the full intervention model and examine interactions when additivity is implausible. `viscomp` graphics are exploratory and do not replace the fitted component model.

## Deliverables

Return the executed plan, `result.rds`, console and session logs, captured `meta` and (when used) `netmeta` settings, requested tables and plots, and a short methods note listing every consequential setting. Separate primary, component-model, subgroup, sensitivity, inconsistency, ranking, and exploratory visualization results.
