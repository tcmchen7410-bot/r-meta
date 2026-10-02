# `netmeta` routing guide

Use the installed package documentation as the executable API authority. The user-supplied `netmeta.pdf` is the 3.7-0 reference manual; an installed version may expose a different set of functions or arguments. Discover the live surface with:

```r
packageVersion("netmeta")
sort(getNamespaceExports("netmeta"))
methods(class = "netmeta")
formals(netmeta::netmeta)
```

The executor attaches `netmeta` when available, so every exported function can be called directly in `plan.R`. Use `netmeta::name` when ambiguity is possible. S3 methods such as `forest.netmeta`, `funnel.netmeta`, `radial.netmeta`, `summary.netmeta`, and `as.data.frame.netmeta` are normally reached through `forest()`, `funnel()`, `radial()`, `summary()`, and `as.data.frame()`.

## Core synthesis and data preparation

- Generic contrasts: `netmeta()`
- Binary arm data: `netmetabin()`
- Convert pairwise/arm-level data: `netpairwise()`
- Inspect treatment coding: `treats()`, `comps()`, `combinations()`
- Connected components and connectivity: `netconnection()`
- Bind networks: `netbind()`
- Bayesian/cross-NMA conversion when supported: `gemtc2netmeta()`, `crossnma2netmeta()`

## Diagnostics and inconsistency

- Design-by-treatment decomposition: `decomp.design()`
- Node splitting: `netsplit()`
- Net heat: `netheat()`, `heatplot()`
- Hat matrix and evidence flow: `hatmatrix()`, `netmeasures()`
- Contributions and distances: `netcontrib()`, `netdistance()`
- Path-based diagnostics when present: `netpath()`, `netimpact()`
- Small-study effects: `metabias()` method for network objects and comparison-adjusted `funnel()`

## Reporting, ranking, and visualization

- Network graph: `netgraph()`
- Forest and radial displays: generic `forest()`, `radial()`
- League table and matrices: `netleague()`, `netmatrix()`, `nettable()`
- Ranking: `netrank()`, `rankogram()`
- Partial orders: `netposet()`, `hasse()` and, when present, VIKOR methods

## Extensions

- Network meta-regression: `netmetareg()`
- Subgroups: generic `subgroup()` for a network object
- Additive component NMA: `netcomb()`, `netcomplex()`, `netcomparison()`, `createC()`, `discomb()`
- Settings and matrix helpers: `settings.netmeta()`, `invmat()`

## Minimal generic-contrast plan

```r
dat <- read.csv(file.path(dirname(plan_file), "network.csv"), check.names = FALSE)

result <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = dat,
  sm = "MD",
  reference.group = "Placebo",
  common = FALSE,
  random = TRUE
)

artifacts <- list(
  connectivity = netconnection(
    data = dat,
    treat1 = treat1,
    treat2 = treat2,
    studlab = studlab
  ),
  ranking = netrank(result, small.values = "desirable"),
  split = netsplit(result),
  design_decomposition = decomp.design(result)
)
```

Check signatures against the installed version before copying this recipe. Functions differ in accepted input objects across releases.

## Required interpretation checks

1. Confirm a connected treatment network or analyze disconnected components separately with an explicit rationale.
2. Preserve multi-arm covariance.
3. State the effect measure, reference treatment, model, heterogeneity estimator, and whether small values are desirable.
4. Assess clinical and methodological transitivity before statistical consistency.
5. Report direct evidence, indirect evidence, network estimates, heterogeneity, and inconsistency separately.
6. Pair rankings with uncertainty and do not equate a high P-score/SUCRA with proven clinical superiority.
