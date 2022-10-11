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


#' Creates a set of targets for a landscape class
#'
#' @description Creates a set of targets for a landscape class, which can be
#' converted into JSON for flsgen.
#'
#' @details Note that NP and AREA targets can be set as NULL, if the class
#' targets is used within the `generate_series` function to generate landscape
#' series with varying NP and/or AREA. However, flsgen won't run is NP and
#' AREA are not set elsewhere.
#'
#' @param class_name Name of the class
#' @param NP number of patches target (must be a vector of length 2)
#' @param AREA patch area target (must be a vector of length 2)
#' @param AREA_MN mean patch area target (must be a vector of length 2)
#' @param CA total class area target (must be a vector of length 2)
#' @param PLAND proportion of landscape target (must be a vector of length 2)
#' @param PD patch density target (must be a vector of length 2)
#' @param SPI smallest patch index target (must be a vector of length 2)
#' @param LPI largest patch index target (must be a vector of length 2)
#' @param MESH effective mesh size target (must be a vector of length 2)
#' @param SPLI splitting index target (must be a vector of length 2)
#' @param NPRO net product target (must be a vector of length 2)
#' @param SDEN splitting density target (must be a vector of length 2)
#' @param COHE degree of coherence target (must be a vector of length 2)
#' @param DIVI degree of landscape division target (must be a vector of length 2)
#' @param IS_SQUARE if TRUE, the class is required to only produce square patches
#' @param ALL_DIFFERENT if TRUE, the class is required to have differently sized patches
#'
#' @return A class targets object which can be converted to JSON for flsgen
#'
#' @examples
#'   \dontrun{
#'     cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 10), AREA=c(0, 1000))
#'   }
#' @export
#'
flsgen_create_class_targets <- function(class_name, NP=NULL, AREA=NULL, AREA_MN=NULL,
                                        CA=NULL, PLAND=NULL, PD=NULL, SPI=NULL,
                                        LPI=NULL, MESH=NULL, SPLI=NULL, NPRO=NULL,
                                        SDEN=NULL, COHE=NULL, DIVI=NULL, IS_SQUARE=FALSE,
                                        ALL_DIFFERENT=FALSE) {
  checkmate::assert_string(class_name)
  class_targets <- list(
    name=class_name
  )
  for (i in CLASS_LEVEL_TARGETS) {
    if (!is.null(get(i))) {
      if (i %in% c("IS_SQUARE", "ALL_DIFFERENT")) {
        checkmate::assert_flag(get(i))
      } else {
        checkmate::assert_vector(get(i), len = 2)
      }
      class_targets[[i]] <- get(i)
    }
  }
  return(structure(class_targets, class="FlsgenClassTargets"))
}
