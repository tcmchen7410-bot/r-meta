#!/usr/bin/env Rscript

library(magick)

# Export one RevMan 5-style forest plot as tightly cropped PNG, TIFF, and PDF.
# A generous temporary canvas prevents column clipping; all final formats are
# generated from the same trimmed 300 dpi raster so their boundaries match.
export_forest <- function(x,
                          stem = "forest",
                          output_dir,
                          dpi = 300,
                          render_width_in = 16,
                          rows_gr = 1,
                          fontsize = 8,
                          trim_fuzz = 1,
                          ...) {
  if (!inherits(x, "meta")) stop("'x' must inherit from class 'meta'.", call. = FALSE)
  if (!dir.exists(output_dir)) stop("'output_dir' does not exist.", call. = FALSE)
  if (!is.numeric(dpi) || length(dpi) != 1L || dpi <= 0) {
    stop("'dpi' must be one positive number.", call. = FALSE)
  }
  if (!is.numeric(render_width_in) || length(render_width_in) != 1L || render_width_in <= 0) {
    stop("'render_width_in' must be one positive number.", call. = FALSE)
  }

  dots <- list(...)
  if ("layout" %in% names(dots)) {
    stop("'layout' is locked to 'RevMan5' by this skill.", call. = FALSE)
  }

  paths <- c(
    pdf = file.path(output_dir, paste0(stem, ".pdf")),
    png = file.path(output_dir, paste0(stem, ".png")),
    tiff = file.path(output_dir, paste0(stem, ".tiff"))
  )
  temporary_pdf <- tempfile(fileext = ".pdf")
  temporary_png <- tempfile(fileext = ".png")
  on.exit(unlink(c(temporary_pdf, temporary_png)), add = TRUE)

  common <- c(list(
    x = x,
    layout = "RevMan5",
    width = render_width_in,
    rows.gr = rows_gr,
    fontsize = fontsize
  ), dots)

  probe <- do.call(meta::forest, c(common, list(
    file = temporary_pdf,
    args.gr = list(useDingbats = FALSE)
  )))
  height_in <- probe$figheight$total_height

  grDevices::png(
    temporary_png,
    width = render_width_in,
    height = height_in,
    units = "in",
    res = dpi,
    bg = "white"
  )
  tryCatch(
    invisible(do.call(meta::forest, common)),
    finally = grDevices::dev.off()
  )

  image <- magick::image_read(temporary_png)
  image <- magick::image_trim(image, fuzz = trim_fuzz)
  density <- paste0(dpi, "x", dpi)

  magick::image_write(image, path = paths[["png"]], format = "png", density = density)
  magick::image_write(
    image,
    path = paths[["tiff"]],
    format = "tiff",
    density = density,
    compression = "lzw"
  )

  info <- magick::image_info(image)
  pdf_width_in <- info$width[[1]] / dpi
  pdf_height_in <- info$height[[1]] / dpi
  grDevices::pdf(
    paths[["pdf"]],
    width = pdf_width_in,
    height = pdf_height_in,
    useDingbats = FALSE,
    bg = "white"
  )
  tryCatch({
    grid::grid.newpage()
    grid::grid.raster(
      as.raster(image),
      x = grid::unit(0, "npc"),
      y = grid::unit(0, "npc"),
      width = grid::unit(1, "npc"),
      height = grid::unit(1, "npc"),
      just = c("left", "bottom"),
      interpolate = FALSE
    )
  }, finally = grDevices::dev.off())

  invisible(paths)
}
