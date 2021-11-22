test_that("generate_fractal_terrain", {
  terrain <- rflsgen::flsgen_terrain(200, 200)
  testthat::expect_s4_class(terrain, class = "RasterLayer")
})
