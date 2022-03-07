## ---- eval=FALSE--------------------------------------------------------------
#  library(rflsgen)
#  
#  basepath <- "<the base path for all generated landscapes>"
#  
#  mesh_seq <- seq(1000, 60000, by=250)
#  repeats <- seq(1, 10, by=1)
#  
#  # Clear and create output directories for generated landscapes
#  lapply(mesh_seq, function(mesh) {
#    path <- paste0(basepath, mesh)
#    if (dir.exists(path)) {
#      unlink(path, recursive = TRUE)
#    }
#    dir.create(path)
#  })

## ---- eval=FALSE--------------------------------------------------------------
#  meta_generate <- function(mesh) {
#    generate <- function(n) {
#      # First we create targets for our focal class
#      rainforest <- flsgen_create_class_targets(
#          "forest",
#          NP = c(1, 200), # Number of patches target
#          AREA = c(10, 500*500), # Patch area target
#          MESH = c(0.99*mesh, 1.01*mesh) # Effective mesh size target
#      )
#      # Then we create landscape targets
#      ls_targets <- flsgen_create_landscape_targets(
#          500, 500, # Dimensions of the landscape
#          list(rainforest), # Class targets
#      )
#      # Because we let a high degree of freedom in the landscape structure, it
#      # is possible to end up with structures that cannot be spatially embedded.
#      # The generation algorithm, as being stochastic, can also fail to embed
#      # structures where the focal class occupy almost all the landscape.
#      # To prevent the program from stopping, we let flsgen 20 tries to generate
#      # a landscape.
#      i <- 0;
#      repeat {
#        if (i >= 20) {
#          stop("fail")
#        }
#        i <- i + 1
#        try({
#          # We use flsgen_structure with a RANDOM search strategy to identify a
#          # landscape structure satisfying the MESH target
#          structure <- flsgen_structure(
#              ls_targets,
#              search_strategy = "RANDOM",
#              time_limit = 60
#          )
#          # We generate the landscape with flsgen_generate
#          result <- flsgen_generate(
#            structure_str = structure,
#            terrain_dependency = 0.8,
#            roughness = 0.35,
#            epsg = "EPSG:3163",
#            resolution_x = 30,
#            output = paste0(basepath, mesh, "/mesh_", mesh, "__", n, ".tif"),
#            max_try_patch = 20,
#            max_try = 2,
#            min_distance = 4
#          )
#        })
#      }
#    }
#    lapply(repeats, generate)
#  }
#  lapply(mesh_seq, meta_generate)

## ---- eval=FALSE--------------------------------------------------------------
#  library(stars)
#  library(sf)
#  
#  lapply(mesh_seq, function(mesh) {
#    path <- paste0(basepath, mesh)
#    lapply(repeats, function(n) {
#      input <- paste0(basepath, mesh, "/mesh_", mesh, "__", n, ".tif")
#      output <- paste0(basepath, mesh, "/shape_mesh_", mesh, "__", n, ".shp")
#      # Read the raster using stars
#      s <- read_stars(input)
#      # Set every non-focal cell to NA
#      s[[1]][s[[1]] != 0] = NA
#      # Convert the raster to vector with sf
#      v <- st_as_sf(s)
#      st_write(v, output)
#    })
#  })

## ---- eval=FALSE--------------------------------------------------------------
#  library(landscapemetrics)
#  library(Makurhini)
#  
#  df <- expand.grid("mesh_target" = mesh_seq, "n" = repeats)
#  df$file <- paste0(basepath, df$mesh_target, "/shape_mesh_", df$mesh_target, "__", df$n, ".shp")
#  df$mesh <- sapply(seq(1, nrow(df), by=1), function(i) {
#    cat(paste("compute MESH for", i, "\n"))
#    path <- paste0(basepath, df[i,]$mesh_target, "/mesh_", df[i,]$mesh_target, "__", df[i,]$n, ".tif")
#    lsm_c_mesh(raster(path))[2,]$value
#  })
#  
#  df$PC <- sapply(seq(1, nrow(df), by=1), function(i) {
#    shape <- st_read(df[i, ]$file)
#    if (nrow(shape) == 1) {
#      df[i, ]$mesh / (500*500*30*30/10000)
#    } else {
#      PC <- MK_dPCIIC(
#        nodes = shape,
#        distance = list(type = "centroid"),
#        metric = "PC",
#        onlyoverall = TRUE,
#        LA =500*500*30*30/10000,
#        area_unit = "ha"
#      )
#      PC[3,]$Value
#    }
#  })

## ---- eval=FALSE--------------------------------------------------------------
#  library(ggplot2)
#  
#  make_fig <- function() {
#    point_size <- 1.5
#    ggplot(data = df[df$mesh_target <= 60000,]) +
#      geom_point(alpha = 0.5, size=point_size, aes(x=mesh, y=PC)) +
#      stat_smooth(aes(x=mesh, y=PC), se=TRUE, color="deepskyblue3", alpha=0.8) +
#      labs(
#        x = expression("Effective mesh size (ha)"),
#        y = expression("Probability of connectivity")
#      ) +
#      theme_bw() +
#      theme(axis.title.x = element_text(size = 13, family = "Helvetica"),
#            axis.title.y = element_text(size = 13, family = "Helvetica"),
#            legend.position="none")
#  }
#  
#  make_fig()
#  
#  cor.test(df$mesh, df$PC, method = c("pearson"))

