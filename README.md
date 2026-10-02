# r-meta-analysis

`r-meta-analysis` is a Codex skill for executing reproducible conventional, frequentist network, and component network meta-analyses in R. It combines the complete installed export surfaces of [`meta`](https://cran.r-project.org/package=meta), [`netmeta`](https://cran.r-project.org/package=netmeta), and [`viscomp`](https://cran.r-project.org/package=viscomp) with risk-of-bias visualization from [`robvis`](https://cran.r-project.org/package=robvis) and [`RobustVis`](https://cran.r-project.org/package=RobustVis).

The skill runs analysis code rather than only suggesting it. Each run preserves the fitted object, executed R plan, package settings, console output, session information, and requested tables and figures.

## What it supports

### Conventional pairwise meta-analysis

- Binary, continuous, generic inverse-variance, correlation, incidence, rate, proportion, and single-mean outcomes
- Common-effect and random-effects models
- Subgroup, cumulative, influence, leave-one-out, sensitivity, and meta-regression workflows
- Forest, funnel, Baujat, L'Abbe, radial, drapery, and bubble plots
- Small-study-effect tests, trim-and-fill, BLUP, NNT, import helpers, and the complete installed `meta` export surface
- Three-level models, GLMMs, penalised logistic regression, Hartung-Knapp and Kenward-Roger inference, IVhet inference, and prediction-distribution clinical-importance probabilities through model arguments
- Built-in `meta` risk-of-bias objects and displays
- RevMan 5-compatible defaults through a hard lock on `settings.meta("RevMan5")`

### Frequentist network meta-analysis

- Generic contrast-based synthesis with `netmeta()`
- Binary network models with `netmetabin()`
- Arm-level and pairwise data preparation with `netpairwise()`
- Network geometry, connectivity, graphs, forest plots, radial plots, league tables, and matrices
- Treatment ranking, rankograms, partial orders, and Hasse diagrams
- Node splitting, design-by-treatment decomposition, net heat plots, contribution matrices, evidence flow, and path-based diagnostics when available
- Network meta-regression, subgroup analysis, additive component NMA, disconnected-network tools, and package conversion helpers
- Every function exported by the installed `netmeta` version, plus registered S3 methods through their standard generics
- Matching 600 dpi PDF/PNG/TIFF output for every network figure, with exact-white trimming and outward, point-size-aware labels that do not cover network nodes

### Component network meta-analysis

- Additive and interaction-aware CNMA estimation with `netmeta::netcomb()` and related component-model functions
- Model comparison between full intervention NMA and additive component models
- All eight `viscomp` tools: component description, co-occurrence graph, component heat plot, leaving-one-combination-out scatter plot, density/violin plots, waterfall plot, and multi-outcome rank heat plot
- Explicit separation between fitted component effects and exploratory visual summaries of intervention-level NMA estimates
- Matching tightly cropped PDF/PNG/TIFF output for every `viscomp` figure without overriding package-default typography

### Risk of bias

- `robvis` traffic-light and weighted summary figures
- `RobustVis` ROBUST-RCT bar and traffic-light figures

## Important statistical boundary

The RevMan 5 lock applies only to conventional analyses performed by `meta`. RevMan 5 does not define the calculations or defaults for a `netmeta` network meta-analysis. Network results must therefore be reported as `netmeta` results, with their own reference treatment, effect direction, heterogeneity assumptions, transitivity assessment, and consistency diagnostics.

## Requirements

- R 4.1 or newer
- Required for conventional analysis: `meta`
- Required for network and component-model estimation: `netmeta`
- Required for component visualization: `viscomp`
- Required for plate-plot league figures: `nmaplateplot`
- Optional for risk-of-bias figures: `robvis`, `RobustVis`, `ggplot2`

Install dependencies before running the skill:

```r
install.packages(c("meta", "netmeta", "viscomp", "nmaplateplot", "robvis", "RobustVis", "ggplot2"))
```

The executor never installs or upgrades packages during an analysis.

## Installation

Clone the repository so that the skill entry point is located at:

```text
~/.codex/skills/r-meta-analysis/SKILL.md
```

Invoke it explicitly with `$r-meta-analysis`, or ask Codex to perform a conventional or network meta-analysis.

## Execution contract

Create a `plan.R` file that assigns the primary fitted object to `result`. Additional models or diagnostics belong in a named `artifacts` list. The executor supplies `output_dir`, `plan_file`, `package_exports()`, and `optional_package_exports()`.

```bash
Rscript scripts/meta_exec.R plan.R output-directory
```

Examples:

- [`examples/binary_plan.R`](examples/binary_plan.R): conventional binary pairwise meta-analysis
- [`examples/network_plan.R`](examples/network_plan.R): generic-contrast frequentist network meta-analysis
- [`examples/component_nma_plan.R`](examples/component_nma_plan.R): additive CNMA plus `viscomp` visualization

Detailed routing is documented in [`SKILL.md`](SKILL.md), [`references/function-map.md`](references/function-map.md), [`references/netmeta.md`](references/netmeta.md), and [`references/component-nma.md`](references/component-nma.md).

## Complete-function coverage

Package APIs change over time. Rather than freezing a partial function list, the skill discovers the installed API dynamically:

```r
sort(getNamespaceExports("meta"))
sort(getNamespaceExports("netmeta"))
sort(getNamespaceExports("viscomp"))
```

`scripts/list_capabilities.R` reports versions and every export from `meta`, `netmeta`, `viscomp`, `robvis`, and `RobustVis`. A plan may call any reported export. Functions documented only in a newer manual become available automatically after the corresponding package version is installed.

## Reproducibility outputs

The executor writes:

- `result.rds`
- `result_summary.txt`
- `artifacts.rds` and text summaries when supplied
- `meta_settings.R`
- `netmeta_settings.R` when a network object is produced
- `console.txt`
- `session_info.txt`
- `plan_executed.R`
- Any tables and figures created by the plan

## Validation

```bash
Rscript tests/run_smoke.R
Rscript tests/run_network_smoke.R
Rscript tests/run_component_smoke.R
Rscript scripts/list_capabilities.R
```

## Contact

Guang Chen

Email: `tcm_chen7410@163.com`

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
