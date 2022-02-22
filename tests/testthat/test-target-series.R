test_that("landscape_targets", {
  cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 10), AREA=c(1, 1000))
  cls_2 <- flsgen_create_class_targets("class 2", AREA=c(0, 2000))
  ls_targets <- flsgen_create_landscape_targets(200, 200, list(cls_1, cls_2))
  target_series <- flsgen_create_target_series(ls_targets, class_name="class 2", target_key="NP", sequence=seq(1, 10, by=1))
  testthat::expect_length(target_series, 10)
  for (i in 1:10) {
    testthat::expect_equal(target_series[[i]]$classes[[2]]$NP, c(i, i))
  }
})
