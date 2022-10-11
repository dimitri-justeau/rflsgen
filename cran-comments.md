## rflsgen 1.2.0

CRAN team complained about the size of the tarball, exceeding 5MB. To fix this:

* We reduced the spatial resolution of example data to fix this issue;

* We used pdf instead of html for documentation.

## rflsgen 0.1.2

Configure Geotools to store its temporary EPSG database in R session's temporary directory.

## rflsgen 0.1.1

This second release fixes the problems reported by the CRAN Team:

* Java minimum version (>= 8) was not specified in DESCRIPTION.

* Check Java version (>= 8) at runtime, following CRAN's *Writing R Extensions* manual.
