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
#' @import terra
#' @import jsonlite
#'
#' @details The input landscape structure must be either specified as a JSON-formatted string
#'  (structure_str parameter) or as a JSON file (structure_file parameter)
#'
#' @param structure_str JSON-formatted string describing the landscape structure to generate
#' @param structure_file JSON file containing the landscape structure to generate
#' @param terrain_file Path of input terrain raster file, or terra::rast object.
#'                     If NULL a terrain is generated with the diamond-square algorithm
#' @param roughness Roughness factor (or H), between 0 and 1 (only need when terrain_file is NULL)
#' @param terrain_dependency Terrain dependency factor for landscape generation, between 0 and 1
#' @param min_distance Minimum distance between patches of a same class
#' @param min_max_distance If defined, the minimum distance beween patches of a
#'                         same class is defined by a variable buffer of width between
#'                         min_distance and min_max_distance
#' @param connectivity Connectivity definition in the regular square grid (4 or 8)."
#' @param x X position (geographical coordinates) of the top-left output raster pixel
#' @param y Y position (geographical coordinates) of the top-left output raster pixel
#' @param resolution_x x spatial resolution (geographical units) of the output raster (i.e. pixel width)
#' @param resolution_y y-spatial resolution (geographical units) of the output raster (i.e. pixel height),
#'                     if null, resolution_x is used
#' @param epsg EPSG identifier of the output projection
#' @param max_try Maximum number of trials for landscape generation
#' @param max_try_patch Maximum number of trials for patch generation
#' @param verbose if TRUE print information about generation
#'
#' @return A terra::rast object
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
flsgen_generate <- function(structure_str, structure_file, terrain_file=NULL,
                            roughness=0.5, terrain_dependency=0.5, min_distance=2,
                            min_max_distance=NULL, connectivity=4, x=0, y=0,
                            resolution_x=0.0001, resolution_y=NULL, epsg="EPSG:4326",
                            max_try=2, max_try_patch=10, verbose=TRUE) {
  mask_raster <- NULL
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
    if (inherits(structure_str, "FlsgenLandscapeStructure")) {
      if (!is.null(structure_str$maskRaster)) {
        mask_raster <- structure_str$maskRaster
        structure_str$maskRaster <- NULL
      }
      for (i in 1:length(structure_str$classes)) {
        structure_str$classes[[i]] <- unclass(structure_str$classes[[i]])
      }
      structure_str <- jsonlite::toJSON(unclass(structure_str), auto_unbox = TRUE)
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
  checkmate::assert_number(resolution_x)
  if (!is.null(resolution_y)) {
    checkmate::assert_number(resolution_y)
  } else {
    resolution_y <- resolution_x
  }
  checkmate::assert_string(epsg)
  checkmate::assert_string(structure_str)
  checkmate::assert_flag(verbose)

  struct_json <- jsonlite::fromJSON(structure_str)
  nb_rows <- struct_json$nbRows
  nb_cols <- struct_json$nbCols
  no_data_cells <- c()
  no_data_value <- -3000
  if (!is.null(mask_raster)) {
    nb_rows <- nrow(mask_raster)
    nb_cols <- ncol(mask_raster)
    no_data_cells <- which(is.na(mask_raster[,])) - 1
    no_data_value <-terra::NAflag(mask_raster)
  } else {
    if (!is.null(struct_json$maskRasterPath)) {
      mask_raster <- terra::rast(struct_json$maskRasterPath)
      nb_rows <- nrow(mask_raster)
      nb_cols <- ncol(mask_raster)
      no_data_cells <- which(is.na(mask_raster[,])) - 1
      no_data_value <-terra::NAflag(mask_raster)
    }
  }

  # Generate landscape raster using flsgen jar
  struct <- J("org.flsgen.solver.LandscapeStructure")$fromJSON(
    structure_str, as.integer(nb_rows), as.integer(nb_cols), .jarray(as.integer(no_data_cells))
  )
  grid <- .jnew("org.flsgen.grid.regular.square.RegularSquareGrid", struct$getNbRows(), struct$getNbCols())
  terrain <- .jnew("org.flsgen.solver.Terrain", grid)
  if (is.null(terrain_file)) {
    .jcall(terrain, "V", "generateDiamondSquare", roughness)
  } else {
    terrain_raster <- terrain_file
    if (!inherits(terrain_file, "SpatRaster")) {
      terrain_raster <- terra::rast(terrain_file)
    }
    terrain_data <- values(terrain_raster)
    .jcall(terrain, "V", "loadFromData", .jarray(as.double(as.vector(terrain_data))))
  }
  if (is.null(min_max_distance)) {
    generator <- .jnew("org.flsgen.solver.LandscapeGenerator", struct, as.integer(connectivity), as.integer(min_distance), terrain)
  } else {
    generator <- .jnew("org.flsgen.solver.LandscapeGenerator", struct, as.integer(connectivity), as.integer(min_distance), as.integer(min_max_distance), terrain)
  }
  if (.jcall(generator, "Z", "generate", terrain_dependency, as.integer(max_try), as.integer(max_try_patch), verbose)) {
    landscape_data <- .jcall(generator, "[I", "getRasterData", as.integer(no_data_value))
    landscape_raster <- terra::rast(xmin = x, xmax = x + (nb_cols * resolution_x),
                                    ymax = y, ymin = y - (nb_rows * resolution_y),
                                    crs = epsg, nrows = nb_rows, ncols = nb_cols,
                                    nlyrs = 1)
    values(landscape_raster) <- landscape_data
    .jgc()
    return(landscape_raster)
  } else {
    .jgc()
    stop("Could not generate a raster satisfying the input landscape structure")
  }
}
