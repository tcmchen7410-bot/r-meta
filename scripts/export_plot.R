#!/usr/bin/env Rscript

# Export meta::forest() at A4 portrait width. forest.meta calculates the
# required device height from its rows, avoiding a fixed, whitespace-heavy
# canvas. PDF is vector; PNG and TIFF are rendered at the requested DPI.
export_forest <- function(x,
                          stem = "forest",
                          output_dir,
                          width_mm = 210,
                          dpi = 300,
                          rows_gr = 1,
                          fontsize = 8,
                          layout = "RevMan5",
                          ...) {
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("R package 'magick' is required for tight 300 dpi raster exports.", call. = FALSE)
  }
  if (!inherits(x, "meta")) stop("'x' must inherit from class 'meta'.", call. = FALSE)
  if (!dir.exists(output_dir)) stop("'output_dir' does not exist.", call. = FALSE)
  if (!is.numeric(width_mm) || length(width_mm) != 1L || width_mm <= 0) {
    stop("'width_mm' must be one positive number.", call. = FALSE)
  }
  if (!is.numeric(dpi) || length(dpi) != 1L || dpi <= 0) {
    stop("'dpi' must be one positive number.", call. = FALSE)
  }

  width_in <- width_mm / 25.4
  common <- list(x = x, layout = layout, width = width_in, rows.gr = rows_gr,
                 fontsize = fontsize, ...)
  paths <- c(
    pdf = file.path(output_dir, paste0(stem, ".pdf")),
    png = file.path(output_dir, paste0(stem, ".png")),
    tiff = file.path(output_dir, paste0(stem, ".tiff"))
  )

  pdf_plot <- do.call(meta::forest, c(common, list(
    file = paths[["pdf"]], args.gr = list(useDingbats = FALSE)
  )))
  height_in <- pdf_plot$figheight$total_height

  grDevices::png(paths[["png"]], width = width_in, height = height_in,
                 units = "in", res = dpi, bg = "white")
  tryCatch(
    invisible(do.call(meta::forest, common)),
    finally = grDevices::dev.off()
  )

  grDevices::tiff(paths[["tiff"]], width = width_in, height = height_in,
                  units = "in", res = dpi, compression = "lzw", bg = "white")
  tryCatch(
    invisible(do.call(meta::forest, common)),
    finally = grDevices::dev.off()
  )

  # Remove the outer blank canvas, restore the exact A4-width pixel count, and
  # write explicit resolution metadata (some native R devices omit the tag).
  target_width_px <- as.integer(round(width_in * dpi))
  density <- paste0(dpi, "x", dpi)
  for (path in paths[c("png", "tiff")]) {
    image <- magick::image_read(path)
    image <- magick::image_trim(image, fuzz = 1)
    image <- magick::image_resize(image, paste0(target_width_px, "x"))
    magick::image_write(image, path = path, density = density)
  }

  invisible(paths)
}
