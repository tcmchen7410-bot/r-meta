# RevMan compatibility

The executor hard-locks `meta::settings.meta("RevMan5")` and fails if a plan changes the global settings. This fixes the package-wide defaults to RevMan 5 behavior. Exact numerical equality still requires the outcome-specific arguments and input data to match the RevMan analysis.

Record and match:

- RevMan version, outcome type, effect measure, and analysis model;
- Mantel-Haenszel, inverse-variance, or Peto pooling;
- common-effect and/or random-effects selection;
- tau-squared estimator and random-effects confidence-interval method;
- continuity correction, its amount, and which studies receive it;
- double-zero studies, multi-arm trials, and missing SD handling;
- subgroup pooling and subgroup-difference tests;
- displayed precision versus underlying values.

For binary outcomes start with `method="MH"` and the requested `sm`. For continuous outcomes match `sm`, pooled-SD assumptions, and any imputation. For generic inverse variance use `metagen(TE, seTE, ...)` on RevMan's analysis scale.

Validate in this order: study effect and SE, study weight, pooled effect and CI, Q/df/p, I-squared, tau-squared, and subgroup totals. Explain differences instead of tuning settings merely to match rounded headlines.
