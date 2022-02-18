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

#' Creates a predefined landscape structure that can be converted as JSON
#' Input for flsgen generate
#'
#' @description Creates a predefined landscape structure that can be converted as JSON
#' converted as JSON Input for flsgen generate.
#'
#' @details The class structures must be created prior to the call to this function
#'
#' @param nb_rows Number of rows
#' @param nb_cols Number of columns
#' @param classes list of class structures
#'
#' @return A landscape structure object which can be converted to JSON for
#' flsgen generate
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- flsgen_class_structure("class 1", c(10, 100, 1000))
#'     cls_2 <- flsgen_class_structure("class 2", c(20, 200, 2000))
#'     ls_struct <- flsgen_landscape_structure(200, 200, list(cls_1, cls_2))
#'   }
#'
#' @export
flsgen_landscape_structure <- function(nb_rows, nb_cols, classes) {
  checkmate::assert_int(nb_rows, lower=1)
  checkmate::assert_int(nb_cols, lower=1)
  if (!is.null(classes)) {
    checkmate::assert_list(classes)
    u <- unique(lapply(classes, function(c) {c$name}))
    if (length(u) != length(classes)) {
      stop("The class names are not unique")
    }
  }
  lstruct <- list(
    nbRows=nb_rows,
    nbCols=nb_cols,
    classes = classes
  )
  return(structure(lstruct, class="FlsgenLandscapeStructure"))
}

#' Loads a predefined landscape structure from an existing raster
#'
#' @description Loads a predefined landscape structure from an existing raster
#'
#' @param raster_path path of the rasterfile
#' @param focal_classes vector of integers representing the raster values of
#' the focal classes to extract the structure from
#' @param connectivity Connectivity definition in the regular square grid (4 or 8)."

#'
#' @return A JSON landscape structure that can be used with flsgen generate
#'
#' @examples
#'   \dontrun{
#'     ls_struct <- flsgen_landscape_structure_from_raster(raster_path, c(0, 1, 2))
#'   }
#'
#' @export
flsgen_landscape_structure_from_raster <- function(raster_path, focal_classes, connectivity=4) {
  checkmate::assert_string(raster_path)
  checkmate::assert_vector(focal_classes, min.len = 1)
  checkmate::assert(file.exists(raster_path))
  checkmate::assert_choice(connectivity, c(4, 8))
  if (connectivity == 4) {
    neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  } else {
    if (connectivity == 8) {
      neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$HEIGHT_CONNECTED
    }
  }
  struct <- J("org.flsgen.solver.LandscapeStructure")$fromRaster(
    raster_path,
    .jarray(as.integer(focal_classes)),
    neigh
  )
  return(struct$toJSON())
}
