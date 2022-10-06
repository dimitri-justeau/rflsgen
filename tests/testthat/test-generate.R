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
