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
- Extractors: `estimates`, `ci`

## Plots

`forest`, `funnel`, `baujat`, `labbe`, `radial`, `drapery`, `bubble`.

## Remaining exported functionality

Import helpers include `read.rm5`, `read.cdir`, and `read.mtv`. Conversion and utility functions include `or2smd`, `smd2or`, `cor2z`, `z2cor`, `p2logit`, `logit2p`, `p2asin`, `asin2p`, `VE2logVR`, `logVR2VE`, `asin2ir`, `transf`, `backtransf`, `settings.meta`, `setvals`, `JAMAlabels`, `cilayout`, and `gs`.

Discover every export in the installed version with:

```r
sort(getNamespaceExports("meta"))
```

This generic route is the coverage mechanism for current and future functions not enumerated above.
