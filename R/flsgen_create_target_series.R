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


#' From a base landscape target object, create a series of landscape targets,
#' with one target for one class varying according to a specified sequence.
#'
#' @details Either the class name of id must be given to identify the class to
#' use for generating the series.
#'
#' @description Create a series of landscape targets, with one target for one class
#' varying according to a specified sequence.
#'
#' @param landscape_targets Number of rows
#' @param class_name Name of the class for the varying target
#' @param class_id Index of the class for the varying target
#' @param target_key Varying target key
#' @param sequence sequence (list) of targets for the varying target
#'
#' @return A list of landscape targets
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 10), AREA=c(0, 1000))
#'     cls_2 <- flsgen_create_class_targets("class 2", AREA=c(0, 1000))
#'     ls_targets <- flsgen_create_landscape_targets(200, 200, list(cls_1, cls_2))
#'     target_series <- flsgen_create_target_series(ls_targets, class_name="class 2",
#'                                                  target_key="NP", sequence=seq(1, 10, by=1))
#'   }
#' @export
#'
flsgen_create_target_series <- function(landscape_targets, class_name=NULL, class_id=NULL,
                          target_key, sequence) {
  checkmate::check_class(landscape_targets, c("FlsgenLandscapeTargets"))
  if (is.null(class_id)) {
    checkmate::check_string(class_name)
    i <- which(vapply(landscape_targets$classes, function(c) {c$name == class_name}, FALSE))
  }
  checkmate::check_vector(i, len = 1)
  checkmate::check_string(target_key)
  checkmate::check_choice(target_key, CLASS_LEVEL_TARGETS)
  checkmate::check_list(sequence)
  gen_target <- function(v) {
    if (is.numeric(v)) {
      v <- c(v, v)
    } else {
      checkmate::assert_vector(v, len = 2)
    }
    targets <- landscape_targets
    targets$classes[[i]][[target_key]] <- v
    return(targets)
  }
  return(lapply(sequence, gen_target))
}
