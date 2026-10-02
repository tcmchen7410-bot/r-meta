data(Senn2013, package = "netmeta")

result <- netmeta::netmeta(
  TE, seTE, treat1, treat2, studlab,
  data = Senn2013,
  sm = "MD",
  reference = "plac"
)

artifacts <- list(
  ranking = netrank(result, small.values = "desirable"),
  design_decomposition = decomp.design(result)
)

export_network_graph(
  result,
  stem = "network",
  output_dir = output_dir
)

if (requireNamespace("nmaplateplot", quietly = TRUE)) {
  data("ad12.rr.rd", package = "nmaplateplot")
  export_nmaplateplot_data(
    ad12.rr.rd,
    stem = "league_plateplot",
    output_dir = output_dir
  )
}
