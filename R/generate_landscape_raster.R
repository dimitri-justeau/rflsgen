#' Landscape raster generator
#'
#' @description Generate landscape raster from landscape structure
#'
#'
#'
generate_landscape_raster <- function(structure_str, structure_file, output=tempfile(fileext=".tif"),
                                      terrain_file=NULL, roughness=0.5, terrain_dependency=0.5, min_distance=2,
                                      x=0, y=0, resolution=0.0001, epsg="EPSG:4326", max_try=10, max_try_patch=10) {
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
  checkmate::assert_number(resolution)
  checkmate::assert_string(epsg)
  checkmate::assert_string(output)
  checkmate::assert_string(structure_str)

  # Generate landscape raster using flsgen jar
  reader <- .jnew("java.io.StringReader", structure_str)
  struct <- J("solver.LandscapeStructure")$fromJSON(reader)
  neigh <- J("grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  if (min_distance == 1) {
    buffer <- J("grid.neighborhood.Neighborhoods")$FOUR_CONNECTED
  } else {
    if (min_distance == 2) {
      buffer <- J("grid.neighborhood.Neighborhoods")$TWO_WIDE_FOUR_CONNECTED
    } else {
      buffer <- J("grid.neighborhood.Neighborhoods")$K_WIDE_FOUR_CONNECTED(as.integer(min_distance))
    }
  }
  grid <- .jnew("grid.regular.square.RegularSquareGrid", struct$nbRows, struct$nbCols)
  terrain <- .jnew("solver.Terrain", grid)
  if (is.null(terrain_file)) {
    .jcall(terrain, "V", "generateDiamondSquare", roughness)
  } else {
    .jcall(terrain, "V", "loadFromRaster", terrain_file)
  }
  generator <- .jnew("solver.LandscapeGenerator", struct, .jcast(neigh, "grid/neighborhood/INeighborhood"), .jcast(buffer, "grid/neighborhood/INeighborhood"), terrain)
  if (.jcall(generator, "Z", "generate", terrain_dependency, as.integer(max_try), as.integer(max_try_patch))) {
    .jcall(generator, "V", "exportRaster", x, y, resolution, epsg, output)
    return(raster::raster(output))
  } else {
    stop("Could not generate a raster satisfying the input landscape structure")
  }
}
