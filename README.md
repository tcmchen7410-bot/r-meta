# r-meta-analysis

`r-meta-analysis` is a Codex skill for executing reproducible conventional, frequentist network, and component network meta-analyses in R. It uses eight R packages directly: [`meta`](https://cran.r-project.org/package=meta), [`netmeta`](https://cran.r-project.org/package=netmeta), [`viscomp`](https://cran.r-project.org/package=viscomp), [`nmaplateplot`](https://cran.r-project.org/package=nmaplateplot), [`robvis`](https://cran.r-project.org/package=robvis), [`RobustVis`](https://cran.r-project.org/package=RobustVis), [`magick`](https://cran.r-project.org/package=magick), and [`ggplot2`](https://cran.r-project.org/package=ggplot2).

The skill runs analysis code rather than only suggesting it. Each run preserves the fitted object, executed R plan, package settings, console output, session information, and requested tables and figures.

## What it supports

### Conventional pairwise meta-analysis

- Binary outcomes (risk ratio, odds ratio, and risk difference)
- Continuous outcomes (mean difference, standardized mean difference, and ratio of means)
- Generic inverse-variance effects, correlations, incidence rates, single proportions, and single means
- Common-effect and random-effects models
- Subgroup, cumulative, influence, leave-one-out, sensitivity, and meta-regression workflows
- Forest, funnel, Baujat, L'Abbe, radial, drapery, and bubble plots
- Small-study-effect tests, trim-and-fill, BLUP, NNT, import helpers, and the complete installed `meta` export surface
- Three-level models, GLMMs, penalised logistic regression, Hartung-Knapp and Kenward-Roger inference, IVhet inference, and prediction-distribution clinical-importance probabilities through model arguments
- Built-in `meta` risk-of-bias objects and displays
- RevMan 5-compatible defaults through a hard lock on `settings.meta("RevMan5")`

### Frequentist network meta-analysis

- Direct and indirect comparison of three or more competing interventions in one connected evidence network
- Generic contrast-based synthesis with `netmeta()` and binary network models with `netmetabin()`
- Arm-level and pairwise data preparation while retaining multi-arm trial correlations
- Network geometry, connectivity, graphs, forest plots, radial plots, league tables, and matrices
- Treatment ranking, rankograms, partial orders, and Hasse diagrams
- Node splitting, design-by-treatment decomposition, net heat plots, contribution matrices, evidence flow, and path-based diagnostics when available
- Network meta-regression, subgroup analysis, additive component NMA, disconnected-network tools, and package conversion helpers
- Every function exported by the installed `netmeta` version, plus registered S3 methods through their standard generics
- Default network graph follows `netgraph(net2)` using the package layout, with blue network edges and tightly cropped 600 dpi PDF/PNG/TIFF output
- Compact RR/RD league plate: upper triangle shows risk ratios, lower triangle shows risk differences, and both triangles use text cells with `text_size = 2.8`; the device dimensions scale with the number of treatments so every result cell keeps a consistent landscape rectangle instead of stretching small networks across a fixed wide canvas

### Component network meta-analysis

- Decomposition of multi-component interventions such as `A+B+C` into component effects
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

## Packages and responsibilities

| Package | Role |
|---|---|
| `meta` | Conventional pairwise meta-analysis and RevMan 5-style defaults |
| `netmeta` | Frequentist network meta-analysis, diagnostics, ranking, and CNMA estimation |
| `viscomp` | Exploratory component-frequency and component-combination graphics |
| `nmaplateplot` | Compact graphical league tables, including combined RR/RD plates |
| `robvis` | Standard risk-of-bias traffic-light and summary figures |
| `RobustVis` | ROBUST-RCT risk-of-bias visualization |
| `magick` | Lossless exact-white trimming and multi-format image writing |
| `ggplot2` | Plot objects and supporting graphical output |

League-plate dimensions are computed from the treatment count (`n`): width
`3.0 + 0.85n` inches and height `1.0 + 0.46n` inches. The fixed allowance
accommodates the P-value/SUCRA legends; the remaining area scales with the
league table. Explicit `width` or `height` values still override either default.

## Requirements

- R 4.1 or newer
- Required for conventional analysis: `meta`
- Required for network and component-model estimation: `netmeta`
- Required for component visualization: `viscomp`
- Required for plate-plot league figures: `nmaplateplot`
- Optional for risk-of-bias figures: `robvis`, `RobustVis`, `ggplot2`

Install dependencies before running the skill:

```r
install.packages(c("meta", "netmeta", "viscomp", "nmaplateplot", "robvis", "RobustVis", "magick", "ggplot2"))
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
