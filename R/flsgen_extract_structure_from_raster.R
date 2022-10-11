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
#' @param raster_file terra::rast object or path of the raster
#' @param focal_classes vector of integers representing the raster values of
#' the focal classes to extract the structure from
#' @param connectivity Connectivity definition in the regular square grid (4 or 8)."
#'
#' @import rJava
#' @import terra
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
  if (!inherits(raster_file, "SpatRaster")) {
    raster_file <- terra::rast(raster_file)
  }
  nb_rows <- nrow(raster_file)
  nb_cols <- ncol(raster_file)
  no_data_cells <- which(is.na(raster_file[,])) - 1
  no_data_value <-terra::NAflag(raster_file)
  s <- terra::sources(raster_file)[[1]]
  if (connectivity == 4) {
    neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  } else {
    if (connectivity == 8) {
      neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$HEIGHT_CONNECTED
    }
  }
  struct <- J("org.flsgen.solver.LandscapeStructure")$fromRasterData(
    .jarray(as.integer(values(raster_file))),
    as.integer(nb_rows),
    as.integer(nb_cols),
    as.integer(no_data_value),
    .jarray(as.integer(focal_classes)),
    neigh,
    s
  )
  .jgc()
  return(struct$toJSON())
}
