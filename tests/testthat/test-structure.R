test_that("flsgen_structure", {
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
  structure <- rflsgen::flsgen_structure(targets_str = json, nb_solutions = 5)
  testthat::expect_vector(structure, size = 5)
  testthat::expect_error(rflsgen::flsgen_structure())
})
