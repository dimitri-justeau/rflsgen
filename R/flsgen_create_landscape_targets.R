# Copyright (c) 2021, Dimitri Justeau-Allaire
#
# Institut Agronomique neo-Caledonien (IAC), 98800 Noumea, New Caledonia
# AMAP, Univ Montpellier, CIRAD, CNRS, INRA, IRD, Montpellier, France
#
# This file is part of rflsgen
#
# rflsgen is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# rflsgen is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with rflsgen  If not, see <https://www.gnu.org/licenses/>.

#' Creates a set of targets for a landscape
#'
#' @description Creates a set of targets for a landscape, which can be
#' converted into JSON for flsgen.
#'
#' @details The class targets must be created prior to the call to this function
#'
#' @param nb_rows Number of rows
#' @param nb_cols Number of columns
#' @param classes list of class targets
#' @param mask_raster mask raster (path or raster object)
#' @param NON_FOCAL_PLAND PLAND (proportion of landscape) target on the non-focal land-use class
#'
#' @details Either nb_rows and nb_cols, or mask_raster must be specified. The dimensions
#' of the landscape are deduced from the mask raster if it is used.
#'
#' @return A landscape targets object which can be converted to JSON for flsgen
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 10), AREA=c(0, 1000))
#'     cls_2 <- flsgen_create_class_targets("class 2", NP=c(1, 10), AREA=c(0, 1000))
#'     ls_targets <- flsgen_create_landscape_targets(200, 200, list(cls_1, cls_2))
#'   }
#' @export
#'
flsgen_create_landscape_targets <- function(nb_rows, nb_cols, classes, mask_raster=NULL, NON_FOCAL_PLAND=NULL) {
  if (!is.null(classes)) {
    checkmate::assert_list(classes)
    u <- unique(lapply(classes, function(c) {c$name}))
    if (length(u) != length(classes)) {
      stop("The class names are not unique")
    }
  }
  base_targets <- list(
    classes = classes
  )
  if (is.null(mask_raster)) {
    checkmate::assert_int(nb_rows, lower=1)
    checkmate::assert_int(nb_cols, lower=1)
    base_targets$nbRows <- nb_rows
    base_targets$nbCols <- nb_cols
  } else {
    if (inherits(mask_raster, "Raster")) {
      if (nchar(filename(mask_raster)) > 0) {
        mask_raster <- filename(mask_raster)
      } else {
        file_name <- tempfile(fileext = ".tif")
        writeRaster(mask_raster, file_name)
        mask_raster <- file_name
      }
    }
    base_targets$maskRasterPath <- mask_raster
  }
  if (!is.null(NON_FOCAL_PLAND)) {
    base_targets$NON_FOCAL_PLAND <- NON_FOCAL_PLAND

  }
  return(structure(base_targets, class="FlsgenLandscapeTargets"))
}
