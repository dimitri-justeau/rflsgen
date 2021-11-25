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

#' Landscape raster generator
#'
#' @description Generate landscape raster from landscape structure
#'
#' @import rJava
#'
#' @details The input landscape structure must be either specified as a JSON-formatted string
#'  (structure_str parameter) or as a JSON file (structure_file parameter)
#'
#' @param structure_str JSON-formatted string describing the landscape structure to generate
#' @param structure_file JSON file containing the landscape structure to generate
#' @param output Path of output raster file (temporary file by default)
#' @param terrain_file Path of input terrain raster file, if NULL a terrain is generated with the diamond-square algorithm
#' @param roughness Roughness factor (or H), between 0 and 1 (only need when terrain_file is NULL)
#' @param terrain_dependency Terrain dependency factor for landscape generation, between 0 and 1
#' @param min_distance Minimum distance between patches of a same class
#' @param connectivity Connectivity definition in the regular square grid (4 or 8)."
#' @param x X position (geographical coordinates) of the top-left output raster pixel
#' @param y Y position (geographical coordinates) of the top-left output raster pixel
#' @param resolution Spatial resolution (geographical units) of the output raster (i.e. pixel dimension)
#' @param epsg EPSG identifier of the output projection
#' @param max_try Maximum number of trials for landscape generation
#' @param max_try_patch Maximum number of trials for patch generation
#'
#' @return A raster object
#'
#' @examples
#'   \dontrun{
#'     json <- "{
#'       \"nbRows\" : 200,
#'       \"nbCols\" : 200,
#'       \"classes\" : [
#'         {
#'           \"name\" : \"Class A\",
#'           \"NP\" : [1, 10],
#'           \"AREA\" : [300, 4000],
#'           \"CA\" : [1000, 5000],
#'           \"MESH\" : [225, 225]
#'         },
#'         {
#'           \"name\" : \"Class B\",
#'           \"NP\" : [2, 8],
#'           \"AREA\" : [200, 4000],
#'           \"PLAND\" : [40, 40]
#'         },
#'         {
#'           \"name\" : \"Class C\",
#'            \"NP\" : [5, 7],
#'            \"AREA\" : [800, 1200]
#'         }
#'       ]
#'     }"
#'     structure <- flsgen_structure(targets_str = json)
#'     landscape <- flsgen_generate(structure_str = structure)
#'   }
#'
#' @export
#'
flsgen_generate <- function(structure_str, structure_file, output=tempfile(fileext=".tif"), terrain_file=NULL,
                            roughness=0.5, terrain_dependency=0.5, min_distance=2, connectivity=4,
                            x=0, y=0, resolution=0.0001, epsg="EPSG:4326", max_try=2, max_try_patch=10) {
  # Check arguments
  if (missing(structure_str)) {
    if (missing(structure_file)) {
      stop("Either structure_str or structure_file must be used in generate_landscape_raster function to specify user targets")
    }
    structure_str <- paste(readLines(structure_file, warn=FALSE), collapse="")
  } else {
    if (!missing(structure_file)) {
      stop("Either structure_str or structure_file must be used in generate_landscape_raster function to specify user targets, not both")
    }
  }
  checkmate::assert_int(min_distance, lower=1)
  checkmate::assert_int(max_try, lower=1)
  checkmate::assert_int(max_try_patch, lower=1)
  checkmate::assert_number(roughness, lower=0, upper=1)
  checkmate::assert_number(terrain_dependency, lower=0, upper=1)
  checkmate::assert_number(x)
  checkmate::assert_number(y)
  checkmate::assert_number(connectivity)
  checkmate::assert_choice(connectivity, c(4, 8))
  checkmate::assert_number(resolution)
  checkmate::assert_string(epsg)
  checkmate::assert_string(output)
  checkmate::assert_string(structure_str)

  # Generate landscape raster using flsgen jar
  reader <- .jnew("java.io.StringReader", structure_str)
  struct <- J("org.flsgen.solver.LandscapeStructure")$fromJSON(reader)
  if (connectivity == 4) {
    neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  } else {
    if (connectivity == 8) {
      neigh <- J("org.flsgen.grid.neighborhood.Neighborhoods")$HEIGHT_CONNECTED
    }
  }
  if (min_distance == 1) {
    if (connectivity == 4) {
      buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
    } else {
      if (connectivity == 8) {
        buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$HEIGHT_CONNECTED
      }
    }
  } else {
    if (min_distance == 2) {
      if (connectivity == 4) {
        buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$TWO_WIDE_FOUR_CONNECTED
      } else {
        if (connectivity == 8) {
          buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$TWO_WIDE_HEIGHT_CONNECTED
        }
      }
    } else {
      if (connectivity == 4) {
        buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$K_WIDE_FOUR_CONNECTED(as.integer(min_distance))
      } else {
        if (connectivity == 8) {
          buffer <- J("org.flsgen.grid.neighborhood.Neighborhoods")$K_WIDE_HEIGHT_CONNECTED(as.integer(min_distance))
        }
      }
    }
  }
  grid <- .jnew("org.flsgen.grid.regular.square.RegularSquareGrid", struct$getNbRows(), struct$getNbCols())
  terrain <- .jnew("org.flsgen.solver.Terrain", grid)
  if (is.null(terrain_file)) {
    .jcall(terrain, "V", "generateDiamondSquare", roughness)
  } else {
    .jcall(terrain, "V", "loadFromRaster", terrain_file)
  }
  generator <- .jnew("org.flsgen.solver.LandscapeGenerator", struct, .jcast(neigh, "org/flsgen/grid/neighborhood/INeighborhood"), .jcast(buffer, "org/flsgen/grid/neighborhood/INeighborhood"), terrain)
  if (.jcall(generator, "Z", "generate", terrain_dependency, as.integer(max_try), as.integer(max_try_patch))) {
    .jcall(generator, "V", "exportRaster", x, y, resolution, epsg, output)
    return(raster::raster(output))
  } else {
    stop("Could not generate a raster satisfying the input landscape structure")
  }
}
