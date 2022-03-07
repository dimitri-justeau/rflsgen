## ---- warning=FALSE, message=FALSE,eval=FALSE---------------------------------
#  library(raster)
#  
#  path <- system.file("extdata", "copernicus_nc_grande_terre_closed_and_open_forests.tif", package = "rflsgen")
#  existing_landscape <- raster(path)
#  plot(existing_landscape)

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  # The default memory allocated to the JVM by rJava is 512mb, which will be insufficient
#  # as the input raster is large (3297x2724). We increase it with the following line.
#  options(java.parameters = "-Xmx4g")
#  library(rflsgen)
#  
#  struct <- flsgen_extract_structure_from_raster(path, c(0, 1), connectivity = 8)

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  dem_path <- system.file("extdata", "dem_nc_grande_terre_100.tif", package = "rflsgen")
#  r <- flsgen_generate(struct, terrain_file = dem_path, terrain_dependency = 0.9,
#                       epsg = "EPSG:3163", connectivity=8,
#                       resolution_x = 105.4308639672429422,
#                       resolution_y = 105.4037645741556588,
#                       x = 159615, y = 467655)
#  plot(r)

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  dem <- raster(dem_path)
#  values(dem) <- -values(dem)
#  r <- flsgen_generate(struct, terrain_file = dem, terrain_dependency = 0.9,
#                       epsg = "EPSG:3163", connectivity=8,
#                       resolution_x = 105.4308639672429422,
#                       resolution_y = 105.4037645741556588,
#                       x = 159615, y = 467655)

