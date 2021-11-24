.onLoad <- function(libname, pkgname) {
  # Download flsgen jar if not already downloaded
  jar_path <- file.path(libname, pkgname, "java", "flsgen-1.0-SNAPSHOT.jar")
  if (!file.exists(jar_path)) {
    old_options <- options(timeout = max(1000, getOption("timeout")))
    on.exit(options(old_options))
    utils::download.file("https://github.com/dimitri-justeau/flsgen/releases/download/1.0b/flsgen-1.0-SNAPSHOT.jar", destfile = jar_path)
  }
  .jpackage(pkgname, lib.loc = libname)
}
