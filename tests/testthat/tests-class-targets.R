test_that("class_targets", {
  cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 10), AREA=c(1, 1000), MESH=c(200, 200))
  testthat::expect_equal(class(cls_1), "FlsgenClassTargets")
  testthat::expect_equal(cls_1$NP, c(1, 10))
  testthat::expect_equal(cls_1$AREA, c(1, 1000))
  testthat::expect_equal(cls_1$MESH, c(200, 200))
  testthat::expect_error(class_targets("cls", NP="what?"))
})
