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


#'
#' Vector of available class targets
#'
CLASS_LEVEL_TARGETS <- c(
  "NP",      # Number of patches
  "AREA",    # Area of patches
  "AREA_MN", # Mean patche area
  "CA",      # Total class area
  "PLAND",   # Proportion of landscape
  "PD",      # Patch density
  "SPI",     # Smallest patch index
  "LPI",     # Largest patch index
  "MESH",    # Effective mesh size
  "SPLI",    # Splitting index
  "NPRO",    # Net product
  "SDEN",    # Splitting density
  "COHE",    # Degree of coherence
  "DIVI"     # Degree of division
)
