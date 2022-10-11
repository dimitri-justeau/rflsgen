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

#' Fractal terrain generator
#'
#' @description Fractal terrain generation with the diamond-square algorithm
#'
#' @import rJava
#' @import terra
#'
#' @param width Width (in pixels) of output raster
#' @param height Height (in pixels) of output raster
#' @param roughness Roughness factor (or H), between 0 and 1
#' @param x X position (geographical coordinates) of the top-left output raster pixel
#' @param y Y position (geographical coordinates) of the top-left output raster pixel
#' @param resolution Spatial resolution (geographical units) of the output raster (i.e. pixel dimension)
#' @param epsg EPSG identifier of the output projection
#'
#' @return A terra::rast object
#'
#' @examples
#'   \dontrun{
#'     terrain <- flsgen_terrain(200, 200)
#'   }
#'
#' @export
#'
flsgen_terrain <- function(width, height, roughness=0.5, x=0, y=0, resolution=0.0001, epsg="EPSG:4326") {
  # Check arguments
  checkmate::assert_int(width, lower=1)
  checkmate::assert_int(height, lower=1)
  checkmate::assert_number(roughness, lower=0, upper=1)
  checkmate::assert_number(x)
  checkmate::assert_number(y)
  checkmate::assert_number(resolution)
  checkmate::assert_string(epsg)
  # Generate fractal terrain using flsgen jar
  grid <- .jnew("org.flsgen.grid.regular.square.RegularSquareGrid", as.integer(height), as.integer(width))
  terrain <- .jnew("org.flsgen.solver.Terrain", grid)
  .jcall(terrain, "V", "generateDiamondSquare", roughness)
  raster_data <- .jcall(terrain, "[D", "getData")
  terrain_raster <- terra::rast(xmin = x, xmax = x + (width * resolution),
                                ymax = y, ymin = y - (height * resolution),
                                crs = epsg, nrows = height, ncols = width,
                                nlyrs = 1)
  values(terrain_raster) <- raster_data
  .jgc()
  return(terrain_raster)
}
