# Component network meta-analysis with `netmeta` and `viscomp`

`netmeta` and `viscomp` have different roles:

- `netmeta` fits the intervention network and estimates additive or interaction component network meta-analysis (CNMA) models.
- `viscomp` visualizes how components and component combinations occur and how intervention-level network estimates behave. Its graphics are exploratory; they do not estimate the CNMA model.

The installed API is authoritative. Check it before writing a plan:

```r
packageVersion("netmeta")
packageVersion("viscomp")
sort(getNamespaceExports("netmeta"))
sort(getNamespaceExports("viscomp"))
formals(netmeta::netcomb)
```

## Data contract

- Encode each multi-component intervention using one consistent separator, normally `+`.
- Use stable, unambiguous component names. Trim whitespace and normalize aliases before fitting.
- Keep a component dictionary in the analysis output.
- Preserve study and multi-arm structure when constructing contrasts.
- Include a meaningful inactive/reference intervention; do not assume that absence of named active components is always equivalent to placebo or usual care.

## Integrated workflow

1. Fit the standard full-intervention NMA as a `netmeta` object.
2. Check connectivity, transitivity, heterogeneity, inconsistency, and treatment coding.
3. Fit an additive CNMA with `netcomb()`; use `netcomplex()`, `netcomparison()`, `createC()`, or `discomb()` only when their model assumptions match the question and installed signatures.
4. Compare the additive model with the standard intervention model, including the Q difference reported by `netcomb`. A significant difference warns against simple additivity.
5. Consider prespecified component interactions when scientifically justified and estimable. Avoid data-driven interaction fishing.
6. Run `viscomp` on the original standard `netmeta` object, not the `netcomb` result.
7. Report component-model estimates separately from visual summaries based on intervention-level estimates.

## `viscomp` export map

- `compdesc()`: component frequencies, co-occurrence cross-table, optional heat map
- `compGraph()`: component co-occurrence network graph
- `heatcomp()`: component and pairwise-component heat plot
- `loccos()`: leaving-one-component-combination-out scatter plot
- `denscomp()`: density or violin display for selected combinations
- `specc()`: violin plots for components, combinations, or component-count groups
- `watercomp()`: waterfall plot comparing interventions that differ by a component combination
- `rankheatplot()`: component P-score heat plot across multiple outcomes

All eight functions require component-coded intervention names. With the exception of `rankheatplot()` (list of network models), they operate on one `netmeta` model.

## Reusable plan skeleton

```r
dat <- read.csv(file.path(dirname(plan_file), "component_network.csv"), check.names = FALSE)

result <- netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = dat,
  sm = "OR",
  reference.group = "UC",
  common = TRUE,
  random = TRUE,
  small.values = "desirable"
)

component_model <- netcomb(result)
component_description <- viscomp::compdesc(result, sep = "+", heatmap = FALSE)

artifacts <- list(
  additive_component_model = component_model,
  component_frequency = component_description$frequency,
  component_crosstable = component_description$crosstable
)

plots <- list(
  heat = viscomp::heatcomp(result, sep = "+"),
  violin = viscomp::specc(result, sep = "+", combination = c("A", "B"))
)

for (nm in names(plots)) {
  ggplot2::ggsave(
    file.path(output_dir, paste0("component_", nm, ".pdf")),
    plot = plots[[nm]]
  )
}
```

Treat this as a structure, not a universal model specification. Confirm effect direction, model, reference intervention, component separator, and function signatures for every dataset.

## Interpretation safeguards

- Component effects are conditional on the additivity or interaction structure being correctly specified.
- Components that always occur together are not separately identifiable.
- Sparse component combinations can produce visually persuasive but unstable summaries.
- `viscomp` groups intervention-level network effects by component presence; it does not isolate causal component effects.
- Rankings and P-scores must be accompanied by uncertainty and should not be interpreted as proof of superiority.
