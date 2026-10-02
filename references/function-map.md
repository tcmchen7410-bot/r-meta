# Function map

## Primary models

- Binary: `metabin`
- Continuous: `metacont`
- Generic effect and SE: `metagen`
- Correlation: `metacor`
- Incidence counts/person-time: `metainc`
- Rates: `metarate`
- Proportions: `metaprop`
- Single means: `metamean`
- Individual participant data: `metacr`
- Multi-arm reshaping: `pairwise`, `longarm`

## Extensions and diagnostics

- Add/update/combine: `metaadd`, `metamerge`, `metabind`
- Cumulative and leave-one-out: `metacum`, `metainf`
- Meta-regression: `metareg`; plot with `bubble`
- Small-study effects: `metabias`
- Trim-and-fill: `trimfill`
- BLUP and NNT: `blup`, `nnt`
- Prediction-distribution clinical importance: `cidprop`
- Risk-of-bias objects and built-in displays: `rob`, `traffic_light`; use the `barplot()` generic for `rob` objects
- Extractors and summaries: `estimates`, `ci`, `weights`, `labels`, `summary`, `as.data.frame`

## Model capabilities controlled by arguments

These are not separate top-level functions. Inspect the relevant model function's current arguments.

- Three-level meta-analysis through clustered study labels and `cluster`
- GLMMs for binary, count, proportion, and rate outcomes
- Penalised logistic regression for rare binary outcomes
- Hartung-Knapp and Kenward-Roger random-effects inference
- IVhet common-effect inference
- Multiple between-study variance estimators and prediction-interval methods
- Clinically important benefit/harm probabilities from the prediction distribution

## Plots

`forest`, `funnel`, `baujat`, `labbe`, `radial`, `drapery`, `bubble`, and generic `barplot` / `plot` methods. In versions that export it, `forest_dims()` helps determine device dimensions.

## Remaining exported functionality

Import helpers include `read.rm5`, `read.cdir`, and `read.mtv`. Conversion and utility functions include `or2smd`, `smd2or`, `cor2z`, `z2cor`, `p2logit`, `logit2p`, `p2asin`, `asin2p`, `VE2logVR`, `logVR2VE`, `asin2ir`, `transf`, `backtransf`, `settings.meta`, `setvals`, `JAMAlabels`, `cilayout`, and `gs`.

Additional helpers include `rd`, `cilayout`, `setvals`, and version-specific methods accessed through R generics. Discover every export in the installed version with:

```r
sort(getNamespaceExports("meta"))
```

This generic route is the coverage mechanism for current and future functions not enumerated above.
