#!/usr/bin/env Rscript

library(magick)

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

  paths <- c(
    pdf = file.path(output_dir, paste0(stem, ".pdf")),
    png = file.path(output_dir, paste0(stem, ".png")),
    tiff = file.path(output_dir, paste0(stem, ".tiff"))
  )
  temporary_tiff <- tempfile(fileext = ".tiff")
  on.exit(unlink(temporary_tiff), add = TRUE)

  dpi <- 600
  estimated_height <- (x$k + 9) * 0.28 + 1.0
  longest_label <- max(nchar(as.character(x$studlab)), na.rm = TRUE)
  label_allowance <- max(0, longest_label - 20) * 0.18
  model_allowance <- if (isTRUE(x$common) && isTRUE(x$random)) 2 else 0
  device_width <- 10 + label_allowance + model_allowance
  grDevices::tiff(
    filename = temporary_tiff,
    width = device_width,
    height = estimated_height,
    units = "in",
    res = dpi,
    bg = "white"
  )
  tryCatch(
    invisible(do.call(meta::forest, c(list(x = x), dots))),
    finally = grDevices::dev.off()
  )

  image <- magick::image_read(temporary_tiff)
  image <- magick::image_trim(image)
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
