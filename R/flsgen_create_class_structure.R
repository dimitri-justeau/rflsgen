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


#' Creates a predefined landscape class structure that can be converted as
#' JSON input for flsgen generate.
#'
#' @description Creates a predefined landscape class structure that can be
#'  converted as JSON input for flsgen generate.
#'
#' @param class_name Name of the class
#' @param patch_areas Vector of patch areas
#' @param is_square If true, all patches are required to be squares
#'
#' @return A landscape class structure
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- flsgen_class_structure("class 1", c(10, 100, 1000))
#'   }
#'
#' @export
flsgen_create_class_structure <- function(class_name, patch_areas, is_square=FALSE) {
  checkmate::assert_string(class_name)
  checkmate::assert_vector(patch_areas, min.len = 1)
  class_structure <- list(
    name=class_name,
    AREA=patch_areas,
    IS_SQUARE=is_square
  )
  return(structure(class_structure, class="FlsgenClassStructure"))
}
