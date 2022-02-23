test_that("landscape_structure", {
  # Test 1 - basic targets NP, AREA, PLAND
  cls_1 <- flsgen_create_class_targets("class 1", NP=c(10, 10), AREA=c(100, 1000))
  cls_2 <- flsgen_create_class_targets("class 2", NP=c(10, 10), AREA=c(0, 2000), PLAND=c(20, 20))
  ls_targets <- flsgen_create_landscape_targets(300, 300, list(cls_1, cls_2))
  struct <- flsgen_structure(ls_targets)
  # Generate landscapes with 1 ha pixel to facilitate comparison with landscapemetrics
  ls <- flsgen_generate(struct, verbose = FALSE, epsg = "EPSG:3395", resolution_x = 100)
  np <- landscapemetrics::lsm_c_np(ls)
  testthat::expect_equal(np[np$class==0,]$value, 10)
  testthat::expect_equal(np[np$class==1,]$value, 10)
  pland <- landscapemetrics::lsm_c_pland(ls)
  testthat::expect_equal(pland[pland$class==1,]$value, 20)
  area <- landscapemetrics::lsm_p_area(ls)
  testthat::expect_equal(length(which(area[area$class == 0,]$value < 100)), 0)
  testthat::expect_equal(length(which(area[area$class == 0,]$value > 1000)), 0)
  testthat::expect_equal(length(which(area[area$class == 1,]$value > 2000)), 0)
  # Test 2 - AREA_MN, MESH
  cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 100), AREA=c(1, 1500),
                                       AREA_MN = c(200, 300), MESH = c(200, 300))
  ls_targets <- flsgen_create_landscape_targets(300, 300, list(cls_1))
  struct <- flsgen_structure(ls_targets, time_limit = 30)
  ls <- flsgen_generate(struct, verbose = FALSE, epsg = "EPSG:3395", resolution_x = 100)
  area_mn <- landscapemetrics::lsm_c_area_mn(ls)
  mesh <- landscapemetrics::lsm_c_mesh(ls)
  testthat::expect_true(area_mn[area_mn$class==0,]$value >= 200)
  testthat::expect_true(area_mn[area_mn$class==0,]$value <= 300)
  testthat::expect_true(mesh[mesh$class==0,]$value >= 200)
  testthat::expect_true(mesh[mesh$class==0,]$value <= 300)
  # Test 3 - LPI and SPI
  cls_1 <- flsgen_create_class_targets("class 1", NP=c(1, 100), AREA=c(1, 1500),
                                       LPI=c(1222, 1222), SPI=c(551, 551))
  ls_targets <- flsgen_create_landscape_targets(300, 300, list(cls_1))
  struct <- flsgen_structure(ls_targets, time_limit = 30)
  ls <- flsgen_generate(struct, verbose = FALSE, epsg = "EPSG:3395", resolution_x = 100)
  lpi <- landscapemetrics::lsm_c_lpi(ls)
  # In landscapemetrics the LPI is normalized to a percentage
  testthat::expect_equal(lpi[lpi$class==0,]$value, 100 * 1222 / (300 * 300))
  spi <- landscapemetrics::lsm_p_area(ls)
  testthat::expect_equal(min(spi[spi$class==0,]$value), 551)
})
