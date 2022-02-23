# rflsgen 1.0.0

* Rely on flsgen-1.1.0, which fixes several bug, improve performances, provide two new indices (AREA_MN, mean patch area and NON_FOCAL_PLAND, which is PLAND applied to the non-focal class), implement variable neighborhood for more flexible distance between patches in landscape generation, masking, landscape extraction from existing rasters, and more fine tuning.

* Implement helper functions to facilitate the creation of targets.

* Add the possibility to use a mask input raster.

* Add a function to extract a landscape structure from an existing raster.

* Add vignettes: use cases, list and description of all targets, and frequently asked questions.

* Create a pkgdown site.

# rflsgen 0.1.2

* According to CRAN requirements, configure Geotools to store its temporary EPSG database in R session's temporary directory.

# rflsgen 0.1.1

* Update `DESCRIPTION`: add `URL`, `BugReports`, and specify the required minimum Java version (>= 8) in `SystemRequirements`.

* Check system's Java version on runtime (>= 8), following CRAN's *Writing R Extensions* manual.

# rflsgen 0.1.0

Initial release of `rflgen`
