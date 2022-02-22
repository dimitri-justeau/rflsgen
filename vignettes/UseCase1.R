## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  library(rflsgen)

## ---- eval=FALSE--------------------------------------------------------------
#  shrubland <- class_targets("shrubland", NP = c(9, 9), AREA = c(500, 50000), PLAND = c(30, 30))
#  savanna <- class_targets("savanna", NP = c(12, 12), AREA = c(500, 50000), PLAND = c(15, 15))
#  forest <- class_targets("forest", NP = c(4, 4), AREA = c(500, 50000), PLAND = c(15, 15))
#  ls_targets <- landscape_targets(300, 300, list(shrubland, savanna, forest))

## ---- eval=FALSE--------------------------------------------------------------
#  structure <- flsgen_structure(ls_targets, search_strategy = "RANDOM")

## ---- eval=FALSE--------------------------------------------------------------
#  structure_df <- jsonlite::fromJSON(structure)
#  for (i in 1:nrow(structure_df$classes)) {
#    cat(paste(structure_df$classes[i,]$name, ":",
#              "\n\t number of patches", structure_df$classes[i,]$NP,
#              "\n\t smallest patch size", structure_df$classes[i,]$SPI,
#              "\n\t largest patch size", structure_df$classes[i,]$LPI, "\n\n"))
#  }

## ---- eval=FALSE--------------------------------------------------------------
#  landscape <- flsgen_generate(structure)
#  plot(landscape)

## ---- eval=FALSE--------------------------------------------------------------
#  td_seq <- seq(0, 1, by=0.1)
#  landscapes <- lapply(td_seq, function(td) {
#    flsgen_generate(structure, roughness = 0.2, terrain_dependency = td, min_distance = 4)
#  })

## ---- echo=FALSE,  warning=FALSE, message=FALSE, eval=FALSE-------------------
#  library(rasterVis)
#  library(RColorBrewer)
#  landscapes <- lapply(landscapes, function(r) {
#    r <- ratify(r)
#    rat <- levels(r)[[1]]
#    rat$landcover <- c("non-habitat", "shrubland", "savanna", "forest")
#    levels(r) <- rat
#    return(r)
#  })
#  s <- stack(landscapes)
#  cols <- colorRampPalette(brewer.pal(9,"YlGn"))
#  levelplot(
#    s,
#    scales=list(draw=FALSE),
#    names.attr=paste0("td=", td_seq),
#    col.regions=cols,
#    xlab=NULL, ylab=NULL,
#    main="Fixed composition, varying spatial configuration"
#  )

## ---- warning=FALSE,message=FALSE, eval=FALSE---------------------------------
#  library(landscapemetrics)
#  # Number of patches for landscape 2 (td=0.1)
#  np_landscape_2 <- lsm_c_np(landscapes[[2]])
#  np_landscape_2[np_landscape_2$class > -1,]
#  
#  # Number of patches for landscape 10 (td=0.9)
#  np_landscape_10 <- lsm_c_np(landscapes[[10]])
#  np_landscape_10[np_landscape_10$class > -1,]
#  
#  # Proportion of landscape for landscape 3 (td=0.2)
#  pland_landscape_3 <- lsm_c_pland(landscapes[[3]])
#  pland_landscape_3[pland_landscape_3$class > -1,]
#  
#  # Proportion of landscape for landscape 9 (td=0.8)
#  pland_landscape_9 <- lsm_c_pland(landscapes[[9]])
#  pland_landscape_9[pland_landscape_9$class > -1,]

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  library(NLMR)
#  mrf <- nlm_mosaicfield(300, 300)
#  plg <- nlm_planargradient(300, 300)
#  edg <- nlm_edgegradient(300, 300)
#  dg <- nlm_distancegradient(300, 300, origin = c(20, 20, 20, 20))
#  rand <- nlm_random(300, 300)
#  fbm <- nlm_fbm(300, 300)
#  terrains <- c(mrf, plg, edg, dg, rand, fbm)
#  landscapes <- lapply(terrains, function(t) {
#    flsgen_generate(structure, terrain_file = t, terrain_dependency = 0.8, min_distance = 4)
#  })

## ---- echo=FALSE,  warning=FALSE, message=FALSE, eval=FALSE-------------------
#  landscapes <- lapply(landscapes, function(r) {
#    r <- ratify(r)
#    rat <- levels(r)[[1]]
#    rat$landcover <- c("non-habitat", "shrubland", "savanna", "forest")
#    levels(r) <- rat
#    return(r)
#  })
#  s <- stack(landscapes)
#  cols <- colorRampPalette(brewer.pal(9,"YlGn"))
#  levelplot(
#    s,
#    scales=list(draw=FALSE),
#    names.attr=c("Mosaic random field", "Planar gradient", "Edge gradient", "Distance gradient", "Random", "Fractional brownian motion"),
#    col.regions=cols,
#    xlab=NULL, ylab=NULL,
#    main="Fixed composition, varying spatial configuration"
#  )

