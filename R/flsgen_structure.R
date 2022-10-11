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

#' Landscape structure solver
#'
#' @description Find landscape structures satisfying user targets
#'
#' @import rJava
#' @import terra
#' @import jsonlite
#'
#' @details The input user targets must be either specified as a JSON-formatted
#'  string (targets_str parameter) or as a JSON file (target_file parameter).
#'
#' @param targets_str JSON-formatted string describing user targets
#' @param targets_file JSON file describing user targets
#' @param nb_solutions Number of solutions to generate
#' @param time_limit Time limit in seconds (if time_limit = 0, no time limit is set)
#' @param search_strategy Choco solver search strategy (for more details refer to Choco solver documentation:
#'  \url{https://choco-solver.org/docs/})
#'
#' @return A vector of JSON-formatted landscape structures satisfying user targets.
#'
#' @examples
#'   \dontrun{
#'     json <- "{
#'       \"nbRows\" : 200,
#'       \"nbCols\" : 200,
#  '     \"classes\" : [
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
#'   }
#' @export
#'
flsgen_structure <- function(targets_str, targets_file, nb_solutions=1, time_limit = 60, search_strategy="DEFAULT") {
  mask_raster <- NULL
  # Check arguments
  if (missing(targets_str)) {
    if (missing(targets_file)) {
      stop("Either targets_str or targets_file must be used in generate_landscape_structure function to specify user targets")
    }
    targets_str <- paste(readLines(targets_file, warn=FALSE), collapse="")
  } else {
    if (!missing(targets_file)) {
      stop("Either targets_str or targets_file must be used in generate_landscape_structure function to specify user targets, not both")
    }
    if (inherits(targets_str, "FlsgenLandscapeTargets")) {
      if (!is.null(targets_str$maskRaster)) {
        mask_raster <- targets_str$maskRaster
        targets_str$maskRaster <- NULL
      }
      for (i in 1:length(targets_str$classes)) {
        targets_str$classes[[i]] <- unclass(targets_str$classes[[i]])
      }
      targets_str <- jsonlite::toJSON(unclass(targets_str), auto_unbox = TRUE)
    }
  }
  checkmate::assert_int(nb_solutions, lower=1)
  checkmate::assert_int(time_limit, lower=0)
  checkmate::assert_choice(search_strategy, c("DEFAULT", "RANDOM", "DOM_OVER_W_DEG", "DOM_OVER_W_DEG_REF", "ACTIVITY_BASED", "CONFLICT_HISTORY", "MIN_DOM_LB", "MIN_DOM_UB"))

  json_targets <- jsonlite::fromJSON(targets_str)

  nb_rows <- 0
  nb_cols <- 0
  no_data_cells <- c()

  if (!is.null(mask_raster)) {
    nb_rows <- nrow(mask_raster)
    nb_cols <- ncol(mask_raster)
    no_data_cells <- which(is.na(mask_raster[,])) - 1
  } else {
    if (!is.null(json_targets$maskRasterPath)) {
      mask_raster <- terra::rast(json_targets$maskRasterPath)
      nb_rows <- nrow(mask_raster)
      nb_cols <- ncol(mask_raster)
      no_data_cells <- which(is.na(mask_raster[,])) - 1
    }
  }

  # Generate landscape structure using flsgen jar
  solver <- J("org.flsgen.solver.LandscapeStructureSolver")$readFromJSON(
    unclass(targets_str), as.integer(nb_rows), as.integer(nb_cols), .jarray(as.integer(no_data_cells))
  )
  .jcall(solver, "V", "build")
  structs_json <- c()
  switch(search_strategy,
         DEFAULT = .jcall(solver, "V", "setDefaultSearch"),
         RANDOM = .jcall(solver, "V", "setRandomSearch"),
         DOM_OVER_W_DEG = .jcall(solver, "V", "setDomOverWDegSearch"),
         DOM_OVER_W_DEG_REF = .jcall(solver, "V", "setDomOverWDegRefSearch"),
         MIN_DOM_LB = .jcall(solver, "V", "setMinDomLBSearch"),
         MIN_DOM_UB = .jcall(solver, "V", "setMinDomUBSearch"),
         ACTIVITY_BASED = .jcall(solver, "V", "setActivityBasedSearch"),
         CONFLICT_HISTORY = .jcall(solver, "V", "setConflictHistorySearch")
  )
  start_time = Sys.time()
  for (i in 1:nb_solutions) {
    start_sol_time = Sys.time()
    struct <- .jcall(solver, "Lorg/flsgen/solver/LandscapeStructure;", "findSolution", as.integer(time_limit))
    if (is.null(struct)) {
      if (length(structs_json) == 0) {
        if (time_limit > 0 && as.numeric(difftime(Sys.time(), start_sol_time, units = "s")) >= time_limit) {
          .jgc()
          stop("User targets could not be satisfied under the specified time limit")
        } else {
          .jgc()
          stop("User targets cannot be satisfied")
        }
      } else {
        if (time_limit > 0 && as.numeric(difftime(Sys.time(), start_sol_time, units = "s")) >= time_limit) {
          .jgc()
          stop("No more solutions satisfying user targets were found under the specified time limit")
        } else {
          .jgc()
          stop("No more solutions satisfying user targets exist")
        }
      }
    }
    cat("Landscape structure", i, "found in", as.numeric(difftime(Sys.time(), start_sol_time, units = "s")), "s\n", sep = " ")
    sol <- .jcall(struct, "Ljava/lang/String;", "toJSON");
    structs_json <- append(structs_json, sol)
  }
  if (nb_solutions > 1) {
    cat("All landscape structures found in", as.numeric(difftime(Sys.time(), start_time, units = "s")), "s\n", sep = " ")
  }
  .jgc()
  return(structs_json)
}
