#!/usr/bin/env Rscript

library(magick)

export_plot <- function(draw,
                        stem,
                        output_dir,
                        width = 8,
                        height = 8,
                        dpi = 600) {
  if (!is.function(draw)) stop("'draw' must be a zero-argument function.", call. = FALSE)
  if (!nzchar(stem)) stop("'stem' must not be empty.", call. = FALSE)
  if (!dir.exists(output_dir)) stop("'output_dir' does not exist.", call. = FALSE)

  paths <- c(
    pdf = file.path(output_dir, paste0(stem, ".pdf")),
    png = file.path(output_dir, paste0(stem, ".png")),
    tiff = file.path(output_dir, paste0(stem, ".tiff"))
  )
  master <- tempfile(fileext = ".tiff")
  on.exit(unlink(master), add = TRUE)

  grDevices::tiff(master, width = width, height = height, units = "in",
                  res = dpi, bg = "white")
  tryCatch(draw(), finally = grDevices::dev.off())

  image <- magick::image_read(master)
  image <- magick::image_trim(image)
  density <- paste0(dpi, "x", dpi)
  magick::image_write(image, paths[["png"]], format = "png", density = density)
  magick::image_write(image, paths[["tiff"]], format = "tiff",
                      density = density, compression = "lzw")

  info <- magick::image_info(image)
  grDevices::pdf(paths[["pdf"]], width = info$width[[1]] / dpi,
                 height = info$height[[1]] / dpi, useDingbats = FALSE,
                 bg = "white")
  tryCatch({
    grid::grid.newpage()
    grid::grid.raster(as.raster(image), x = grid::unit(0, "npc"),
                      y = grid::unit(0, "npc"), width = grid::unit(1, "npc"),
                      height = grid::unit(1, "npc"), just = c("left", "bottom"),
                      interpolate = FALSE)
  }, finally = grDevices::dev.off())

  invisible(paths)
}

export_ggplot <- function(plot,
                          stem,
                          output_dir,
                          width = 8,
                          height = 8,
                          dpi = 600) {
  if (!inherits(plot, c("gg", "ggplot"))) {
    stop("'plot' must be a ggplot object.", call. = FALSE)
  }
  export_plot(function() print(plot), stem, output_dir, width, height, dpi)
}

capture_ggplot <- function(expr) {
  temporary_pdf <- tempfile(fileext = ".pdf")
  grDevices::pdf(temporary_pdf)
  on.exit({
    grDevices::dev.off()
    unlink(temporary_pdf)
  }, add = TRUE)
  plot <- force(expr)
  if (!inherits(plot, c("gg", "ggplot"))) {
    stop("Expression did not return a ggplot object.", call. = FALSE)
  }
  plot
}

export_network_graph <- function(x,
                                 stem = "network",
                                 output_dir,
                                 width = 8,
                                 height = 8,
                                 dpi = 600,
                                 leader = TRUE,
                                 leader.col = "grey40",
                                 leader.lwd = 1,
                                 ...) {
  if (!inherits(x, "netmeta")) stop("'x' must inherit from class 'netmeta'.", call. = FALSE)
  dots <- list(...)
  dots[c("adj", "offset", "figure")] <- NULL

  measure_layout <- function(args) {
    temporary_pdf <- tempfile(fileext = ".pdf")
    grDevices::pdf(temporary_pdf)
    on.exit({
      grDevices::dev.off()
      unlink(temporary_pdf)
    }, add = TRUE)
    do.call(netmeta::netgraph, args)
  }

  layout <- measure_layout(c(list(x = x, figure = FALSE), dots))
  nodes <- layout$nodes
  eps <- sqrt(.Machine$double.eps)
  adj <- cbind(
    ifelse(nodes$xpos < -eps, 1, ifelse(nodes$xpos > eps, 0, 0.5)),
    ifelse(nodes$ypos < -eps, 1, ifelse(nodes$ypos > eps, 0, 0.5))
  )
  point_cex <- dots$cex.points
  if (is.null(point_cex) || !length(point_cex) || any(!is.finite(point_cex))) point_cex <- 1
  label_offset <- max(0.08, 0.025 * max(point_cex))

  final_layout <- measure_layout(
    c(list(x = x, figure = FALSE, adj = adj, offset = label_offset), dots))
  final_nodes <- final_layout$nodes

  export_plot(
    function() {
      do.call(netmeta::netgraph,
        c(list(x = x, adj = adj, offset = label_offset), dots))
      if (isTRUE(leader)) {
        dx <- final_nodes$xpos.labels - final_nodes$xpos
        dy <- final_nodes$ypos.labels - final_nodes$ypos
        distance <- sqrt(dx^2 + dy^2)
        distance[distance == 0] <- 1
        point_radius <- 0.018 * rep_len(point_cex, nrow(final_nodes))
        start_fraction <- pmin(0.8, point_radius / distance)
        graphics::segments(
          final_nodes$xpos + dx * start_fraction,
          final_nodes$ypos + dy * start_fraction,
          final_nodes$xpos + dx * 0.72,
          final_nodes$ypos + dy * 0.72,
          col = leader.col,
          lwd = leader.lwd
        )
      }
    },
    stem, output_dir, width, height, dpi
  )
}

as_nmaplateplot <- function(x, pooled = c("random", "common")) {
  if (!inherits(x, "netmeta")) stop("'x' must inherit from class 'netmeta'.", call. = FALSE)
  pooled <- match.arg(pooled)
  suffix <- if (pooled == "random") "random" else "common"
  get_matrix <- function(prefix) x[[paste0(prefix, ".", suffix)]]

  te_network <- get_matrix("TE")
  lower_network <- get_matrix("lower")
  upper_network <- get_matrix("upper")
  p_network <- get_matrix("pval")
  te_direct <- get_matrix("TE.direct")
  lower_direct <- get_matrix("lower.direct")
  upper_direct <- get_matrix("upper.direct")
  p_direct <- get_matrix("pval.direct")

  ratio_measure <- x$sm %in% c("OR", "RR", "ROM", "DOR", "HR")
  bt <- function(z) if (ratio_measure) exp(z) else z
  n <- nrow(te_network)
  upper_index <- upper.tri(te_network)
  lower_index <- lower.tri(te_network)
  combine <- function(network, direct, diagonal = 0) {
    ans <- matrix(NA_real_, n, n, dimnames = dimnames(network))
    ans[upper_index] <- bt(network)[upper_index]
    ans[lower_index] <- bt(direct)[lower_index]
    diag(ans) <- diagonal
    as.data.frame(ans, check.names = FALSE)
  }
  combine_p <- function(network, direct) {
    ans <- matrix(NA_real_, n, n, dimnames = dimnames(network))
    ans[upper_index] <- network[upper_index]
    ans[lower_index] <- direct[lower_index]
    diag(ans) <- 0
    as.data.frame(ans, check.names = FALSE)
  }

  ranking <- netmeta::netrank(
    x,
    small.values = x$small.values,
    common = pooled == "common",
    random = pooled == "random"
  )[[paste0("ranking.", suffix)]]
  list(
    Point_estimates = combine(te_network, te_direct),
    Interval_estimates_LB = combine(lower_network, lower_direct),
    Interval_estimates_UB = combine(upper_network, upper_direct),
    Pvalues = combine_p(p_network, p_direct),
    Treatment_specific_values = data.frame(
      Trt_ID = seq_along(x$trts),
      Trt_abbrv = x$trts,
      Value_Upper = as.numeric(ranking[x$trts]),
      stringsAsFactors = FALSE
    )
  )
}

export_nmaplateplot <- function(x,
                                stem = "league_plateplot",
                                output_dir,
                                pooled = c("random", "common"),
                                width = 10,
                                height = 10,
                                dpi = 600,
                                ...) {
  if (!requireNamespace("nmaplateplot", quietly = TRUE)) {
    stop("R package 'nmaplateplot' is required.", call. = FALSE)
  }
  pooled <- match.arg(pooled)
  nma_result <- as_nmaplateplot(x, pooled)
  dots <- list(...)
  if (is.null(dots$null_value_zero)) {
    is_zero_null <- !(x$sm %in% c("OR", "RR", "ROM", "DOR", "HR"))
    dots$null_value_zero <- rep(is_zero_null, 2)
  }
  if (is.null(dots$lower_better)) {
    dots$lower_better <- rep(identical(x$small.values, "desirable"), 2)
  }
  if (is.null(dots$max_substring)) dots$max_substring <- max(nchar(x$trts))
  if (is.null(dots$upper_diagonal_name)) dots$upper_diagonal_name <- "Network meta-analysis"
  if (is.null(dots$lower_diagonal_name)) dots$lower_diagonal_name <- "Direct evidence"
  plate <- do.call(nmaplateplot::plateplot, c(list(nma_result = nma_result), dots))
  export_ggplot(plate, stem, output_dir, width, height, dpi)
}

# Export one RevMan 5-style forest plot as tightly cropped PNG, TIFF, and PDF.
# Forest typography and layout come entirely from settings.meta("RevMan5") and
# meta::forest() defaults. The device height follows the study count, and the
# final files are made from one losslessly trimmed 600 dpi master.
export_forest <- function(x,
                          stem = "forest",
                          output_dir,
                          ...) {
  if (!inherits(x, "meta")) stop("'x' must inherit from class 'meta'.", call. = FALSE)
  if (!dir.exists(output_dir)) stop("'output_dir' does not exist.", call. = FALSE)

  dots <- list(...)
  nondefault_args <- names(dots)[names(dots) %in% c(
    "layout", "width", "height", "rows.gr", "fontsize", "fontfamily"
  ) | grepl("^fs\\.", names(dots))]
  if (length(nondefault_args)) {
    stop("Forest layout, dimensions, rows, and fonts must use meta defaults; remove: ",
         paste(nondefault_args, collapse = ", "), call. = FALSE)
  }

  dpi <- 600
  estimated_height <- (x$k + 9) * 0.28 + 1.0
  longest_label <- max(nchar(as.character(x$studlab)), na.rm = TRUE)
  label_allowance <- max(0, longest_label - 20) * 0.18
  model_allowance <- if (isTRUE(x$common) && isTRUE(x$random)) 2 else 0
  device_width <- 10 + label_allowance + model_allowance
  export_plot(
    function() invisible(do.call(meta::forest, c(list(x = x), dots))),
    stem, output_dir, device_width, estimated_height, dpi
  )
}
