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

#' Extracts a landscape structure from an existing raster
#'
#' @description Extracts a landscape structure from an existing raster
#'
#' @param raster_file raster object or path of the raster
#' @param focal_classes vector of integers representing the raster values of
#' the focal classes to extract the structure from
#' @param connectivity Connectivity definition in the regular square grid (4 or 8)."
#'
#' @import rJava
#' @import raster
#'
#' @return A JSON landscape structure that can be used with flsgen generate
#'
#' @examples
#'   \dontrun{
#'     ls_struct <- flsgen_extract_structure_from_raster(raster_path, c(0, 1, 2))
#'   }
#'
#' @export
flsgen_extract_structure_from_raster <- function(raster_file, focal_classes, connectivity=4) {
  checkmate::assert_vector(focal_classes, min.len = 1)
  checkmate::assert_choice(connectivity, c(4, 8))
  if (inherits(raster_file, "Raster")) {
    if (nchar(filename(raster_file)) > 0) {
      raster_file <- filename(raster_file)
    } else {
      file_name <- tempfile(fileext = ".tif")
      writeRaster(raster_file, file_name)
      raster_file <- file_name
    }
  } else {
    checkmate::assert_string(raster_file)
    checkmate::assert(file.exists(raster_file))
  }
  if (connectivity == 4) {
    neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  } else {
    if (connectivity == 8) {
      neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$HEIGHT_CONNECTED
    }
  }
  struct <- J("org.flsgen.solver.LandscapeStructure")$fromRaster(
    raster_file,
    .jarray(as.integer(focal_classes)),
    neigh
  )
  .jgc()
  return(struct$toJSON())
}
