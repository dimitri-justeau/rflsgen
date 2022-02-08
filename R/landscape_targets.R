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
#'
#' @return A landscape targets object which can be converted to JSON for flsgen
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- class_targets("class 1", NP=c(1, 10), AREA=c(0, 1000))
#'     cls_2 <- class_targets("class 2", NP=c(1, 10), AREA=c(0, 1000))
#'     ls_targets <- landscape_targets(200, 200, list(cls_1, cls_2))
#'   }
#' @export
#'
landscape_targets <- function(nb_rows, nb_cols, classes) {
  checkmate::assert_int(nb_rows, lower=1)
  checkmate::assert_int(nb_cols, lower=1)
  if (!is.null(classes)) {
    checkmate::assert_list(classes)
    u <- unique(lapply(classes, function(c) {c$name}))
    if (length(u) != length(classes)) {
      stop("The class names are not unique")
    }
  }
  base_targets <- list(
    nbRows=nb_rows,
    nbCols=nb_cols,
    classes = classes
  )
  return(structure(base_targets, class="FlsgenLandscapeTargets"))
}
