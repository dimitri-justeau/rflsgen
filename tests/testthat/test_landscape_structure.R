test_that("landscape_structure", {
  cls_1 <- flsgen_create_class_structure("class 1", patch_areas=c(10, 100, 1000))
  cls_2 <- flsgen_create_class_structure("class 2", patch_areas=c(20, 200, 2000))
  ls_struct <- flsgen_create_landscape_structure(200, 200, list(cls_1, cls_2))
  testthat::expect_equal(class(cls_1), "FlsgenClassStructure")
  testthat::expect_equal(class(ls_struct), "FlsgenLandscapeStructure")
  testthat::expect_equal(ls_struct$nbCols, 200)
  testthat::expect_equal(ls_struct$nbRows, 200)
  testthat::expect_length(ls_struct$classes, 2)

})
