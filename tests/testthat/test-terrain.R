test_that("flsgen_terrain", {
  terrain <- rflsgen::flsgen_terrain(200, 200)
  testthat::expect_s4_class(terrain, class = "RasterLayer")
})
