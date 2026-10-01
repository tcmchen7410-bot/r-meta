# r-meta-analysis Codex Skill

A Codex skill that executes reproducible pairwise meta-analysis workflows with R's [`meta`](https://cran.r-project.org/package=meta) package. Global defaults are hard-locked with `settings.meta("RevMan5")`. The skill also supports conventional risk-of-bias figures with [`robvis`](https://cran.r-project.org/package=robvis) and ROBUST-RCT step 1/2 figures with [`RobustVis`](https://cran.r-project.org/package=RobustVis).

## Features

- Binary, continuous, generic inverse-variance, correlation, incidence, rate, proportion, and single-mean meta-analysis
- Common-effect and random-effects models
- Subgroups, cumulative analysis, leave-one-out analysis, meta-regression, small-study-effect tests, trim-and-fill, BLUP, and NNT
- Forest, funnel, Baujat, L'Abbe, radial, drapery, and bubble plots
- RevMan import helpers and the complete installed `meta` namespace through a generic execution plan
- `robvis` traffic-light and summary plots
- `RobustVis` ROBUST-RCT bar and traffic-light plots
- Reproducibility bundle containing the executed plan, RDS objects, settings, console output, session information, and figures

## Requirements

- R 4.1 or newer
- `meta`
- Optional: `robvis`, `RobustVis`, and `ggplot2`

Install dependencies explicitly in R when needed:

```r
install.packages(c("meta", "robvis", "RobustVis", "ggplot2"))
```

The skill never installs or upgrades packages during an analysis run.

## Install as a Codex skill

Clone this repository into your Codex skills directory so that `SKILL.md` is located at:

```text
~/.codex/skills/r-meta-analysis/SKILL.md
```

Then invoke it with `$r-meta-analysis` or ask Codex to run a RevMan-compatible meta-analysis.

## Direct execution

Create a plan that assigns the primary model to `result`, then run:

```bash
Rscript scripts/meta_exec.R plan.R output-directory
```

See [`examples/binary_plan.R`](examples/binary_plan.R) and the instructions in [`SKILL.md`](SKILL.md).

## RevMan compatibility

The executor forces `settings.meta("RevMan5")` and rejects plans that change the global settings. Exact equality with a specific RevMan result additionally requires identical data, effect measure, model, continuity correction, zero-event handling, subgroup behavior, and other outcome-specific choices. See [`references/revman-compatibility.md`](references/revman-compatibility.md).

## Validate

```bash
Rscript tests/run_smoke.R
Rscript scripts/list_capabilities.R
```

## Repository status

No license has been selected. Add an appropriate license before accepting external contributions or redistributing the repository.
