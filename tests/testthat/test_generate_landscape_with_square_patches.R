test_that("landscape_with_square_patches_1", {
  cls_target_1 <- flsgen_create_class_targets("class A", NP = c(1, 10), PLAND = c(10, 20), AREA = c(0, 1000), IS_SQUARE = TRUE)
  cls_target_2 <- flsgen_create_class_targets("class B", NP = c(1, 10), PLAND = c(10, 20), AREA = c(0, 1000), IS_SQUARE = FALSE)
  ls_target <- flsgen_create_landscape_targets(300, 300, list(cls_target_1, cls_target_2))
  struct <- flsgen_structure(ls_target)
  json_struct <- jsonlite::fromJSON(struct)
  testthat::expect_true(json_struct$classes[1,]$IS_SQUARE)
  ls <- flsgen_generate(struct)
})

test_that("landscape_with_square_patches_2", {
  cls_target_1 <- flsgen_create_class_targets("class A", NP = c(1, 50),
                                              PLAND = c(30, 40),
                                              AREA = c(100, 100000),
                                              IS_SQUARE = TRUE, ALL_DIFFERENT = TRUE)
  ls_target <- flsgen_create_landscape_targets(500, 500, list(cls_target_1))
  struct <- flsgen_structure(ls_target)
  json_struct <- jsonlite::fromJSON(struct)
  testthat::expect_true(json_struct$classes[1,]$IS_SQUARE)
  ls <- flsgen_generate(struct, max_try_patch = 20, max_try = 10)
})
