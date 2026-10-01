# Plan recipes

Use these as starting points, then match the user's estimand and RevMan settings.

## Binary

```r
result <- metabin(event.e, n.e, event.c, n.c, studlab = study, data = data,
                  sm = "RR", method = "MH", common = TRUE, random = TRUE)
```

## Continuous

```r
result <- metacont(n.e, mean.e, sd.e, n.c, mean.c, sd.c,
                   studlab = study, data = data, sm = "MD",
                   common = TRUE, random = TRUE)
```

## Generic inverse variance

```r
result <- metagen(TE, seTE, studlab = study, data = data,
                  sm = "OR", common = TRUE, random = TRUE)
```

## Proportion, rate, mean, and correlation

```r
result <- metaprop(event, n, studlab = study, data = data)
result <- metarate(event, time, studlab = study, data = data)
result <- metamean(n, mean, sd, studlab = study, data = data)
result <- metacor(cor, n, studlab = study, data = data)
```

## Subgroup and sensitivity

Pass a subgroup variable using the installed version's supported argument, then add downstream objects:

```r
artifacts <- list(
  leave_one_out = metainf(result),
  cumulative = metacum(result, pooled = "random"),
  bias = if (result$k >= 10) metabias(result, method.bias = "Egger") else NULL,
  trimfill = if (result$k >= 10) trimfill(result) else NULL
)
```

## Meta-regression

```r
reg <- metareg(result, ~ year + dose)
artifacts <- list(meta_regression = reg)
pdf(file.path(output_dir, "bubble.pdf"))
bubble(reg)
dev.off()
```

Before using any recipe, check the exact installed function signature and data columns.
