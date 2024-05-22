test_that("flsgen_generate", {
  json <- "{
    \"nbRows\" : 200,
    \"nbCols\" : 200,
    \"classes\" : [
      {
        \"name\" : \"Class A\",
        \"NP\" : [1, 10],
        \"AREA\" : [300, 4000],
        \"CA\" : [1000, 5000],
        \"MESH\" : [225, 225]
      },
      {
        \"name\" : \"Class B\",
        \"NP\" : [2, 8],
        \"AREA\" : [200, 4000],
        \"PLAND\" : [40, 40]
      },
      {
        \"name\" : \"Class C\",
        \"NP\" : [5, 7],
        \"AREA\" : [800, 1200]
      }
    ]
  }"
  structure <- rflsgen::flsgen_structure(targets_str = json, nb_solutions = 2)
  landscapes <- lapply(structure, rflsgen::flsgen_generate)
  testthat::expect_vector(landscapes, size = 2)
  testthat::expect_s4_class(landscapes[[1]], class = "SpatRaster")
  testthat::expect_s4_class(landscapes[[2]], class = "SpatRaster")
  testthat::expect_error(rflsgen::flsgen_generate())
  landscapes <- flsgen_generate(structure[[1]], connectivity = 8)
  testthat::expect_s4_class(landscapes, class = "SpatRaster")
  landscapes <- flsgen_generate(structure[[1]], min_distance = 3)
  testthat::expect_s4_class(landscapes, class = "SpatRaster")
  landscapes <- flsgen_generate(structure[[1]], min_distance = 3, connectivity = 8)
  testthat::expect_s4_class(landscapes, class = "SpatRaster")
})

test_that("flsgen_generate_from_existing", {
  path <- system.file("extdata",
                      "copernicus_nc_grande_terre_closed_and_open_forests_200m.tif",
                      package = "rflsgen")
  existing_landscape <- rast(path)
  struct <- flsgen_extract_structure_from_raster(path, c(0, 1),
                                                 connectivity = 8)
  dem_path <- system.file("extdata",
                          "dem_nc_grande_terre_200m.tif",
                          package = "rflsgen")
  r <- flsgen_generate(struct, terrain_file = dem_path, terrain_dependency = 0.9,
                       epsg = "EPSG:3163", connectivity=8,
                       resolution_x = 105.4308639672429422,
                       resolution_y = 105.4037645741556588,
                       x = 159615, y = 467655)
  testthat::expect_s4_class(r, class = "SpatRaster")
  dem <- rast(dem_path)
  values(dem) <- -values(dem)
  r <- flsgen_generate(struct, terrain_file = dem, terrain_dependency = 0.9,
                       epsg = "EPSG:3163", connectivity=8,
                       resolution_x = 105.4308639672429422,
                       resolution_y = 105.4037645741556588,
                       x = 159615, y = 467655)
  testthat::expect_s4_class(r, class = "SpatRaster")
})

test_that("flsgen_generate_from_existing_wrong_dimensions", {
  path <- system.file("extdata",
                      "copernicus_nc_grande_terre_closed_and_open_forests_200m.tif",
                      package = "rflsgen")
  json <- "{
    \"nbRows\" : 200,
    \"nbCols\" : 200,
    \"classes\" : [
      {
        \"name\" : \"Class A\",
        \"NP\" : [1, 10],
        \"AREA\" : [300, 4000],
        \"CA\" : [1000, 5000],
        \"MESH\" : [225, 225]
      },
      {
        \"name\" : \"Class B\",
        \"NP\" : [2, 8],
        \"AREA\" : [200, 4000],
        \"PLAND\" : [40, 40]
      },
      {
        \"name\" : \"Class C\",
        \"NP\" : [5, 7],
        \"AREA\" : [800, 1200]
      }
    ]
  }"
  structure <- rflsgen::flsgen_structure(targets_str = json, nb_solutions = 1)
  dem_path <- system.file("extdata",
                          "dem_nc_grande_terre_200m.tif",
                          package = "rflsgen")
  testthat::expect_error(
    r <- flsgen_generate(struct, terrain_file = dem_path, terrain_dependency = 0.9,
                         epsg = "EPSG:3163", connectivity=8,
                         resolution_x = 105.4308639672429422,
                         resolution_y = 105.4037645741556588,
                         x = 159615, y = 467655)
  )
})

