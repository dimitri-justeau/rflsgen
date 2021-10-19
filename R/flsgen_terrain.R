#' Fractal terrain generator
#'
#' @description Fractal terrain generation with the Diamond-Square algorithm
#'
#'
flsgen_terrain <- function(width, height, output=tempfile(fileext=".tif"), roughness=0.5, x=0, y=0, resolution=0.0001, epsg="EPSG:4326") {
  # Check arguments
  checkmate::assert_int(width, lower=1)
  checkmate::assert_int(height, lower=1)
  checkmate::assert_number(roughness, lower=0, upper=1)
  checkmate::assert_number(x)
  checkmate::assert_number(y)
  checkmate::assert_number(resolution)
  checkmate::assert_string(epsg)
  checkmate::assert_string(output)
  # Generate fractal terrain using flsgen jar
  grid <- .jnew("grid.regular.square.RegularSquareGrid", as.integer(height), as.integer(width))
  terrain <- .jnew("solver.Terrain", grid)
  .jcall(terrain, "V", "generateDiamondSquare", roughness)
  .jcall(terrain, "V", "exportRaster", x, y, resolution, epsg, output)
  return(raster::raster(output))
}
