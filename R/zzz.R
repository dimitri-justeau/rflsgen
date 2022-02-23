.onLoad <- function(libname, pkgname) {
  # set Java parameters if none specified
  if (is.null(getOption("java.parameters"))) {
    options(java.parameters = "-Xmx4g")
  }
  # Check that Java version is at least 8
  .jinit()
  jv <- .jcall("java/lang/System", "S", "getProperty", "java.runtime.version")
  if(substr(jv, 1L, 2L) == "1.") {
    jvn <- as.numeric(paste0(strsplit(jv, "[.]")[[1L]][1:2], collapse = "."))
    if(jvn < 1.8) stop("Java >= 8 is needed for this package but not available")
  }
  # Download flsgen jar if not already downloaded
  jar_path <- file.path(libname, pkgname, "java", "flsgen-1.1.0.jar")
  if (!file.exists(jar_path)) {
    old_options <- options(timeout = max(1000, getOption("timeout")))
    on.exit(options(old_options))
    utils::download.file("https://github.com/dimitri-justeau/flsgen/releases/download/v1.1.0/flsgen-1.1.0.jar", destfile = jar_path)
  }
  .jpackage(pkgname, lib.loc = libname)
  J("java.lang.System")$setProperty("EPSG-HSQL.directory", tempdir())
}
