#' Landscape structure generator
#'
#' @description Generate landscape structures satisfying user targets
#'
#'
#'
generate_landscape_structure <- function(targets_str, targets_file, nb_solutions=1, search_strategy="DEFAULT") {
  # Check arguments
  if (missing(targets_str)) {
    if (missing(targets_file)) {
      stop("Either targets_str or targets_file must be used in generate_landscape_structure function to specify user targets")
    }
    targets_str <- paste(readLines(targets_file, warn=FALSE), collapse="")
  } else {
    if (!missing(targets_file)) {
      stop("Either targets_str or targets_file must be used in generate_landscape_structure function to specify user targets, not both")
    }
  }
  checkmate::assert_int(nb_solutions, lower=1)
  checkmate::assert_choice(search_strategy, c("DEFAULT", "RANDOM", "DOM_OVER_W_DEG", "DOM_OVER_W_DEG_REF", "ACTIVITY_BASED", "CONFLICT_HISTORY", "MIN_DOM_LB", "MIN_DOM_UB"))

  # Generate landscape structure using flsgen jar
  reader <- .jnew("java.io.StringReader", targets_str)
  solver <- J("solver.LandscapeStructureSolver")$readFromJSON(reader)
  .jcall(solver, "V", "build")
  structs_json <- c()
  switch(search_strategy,
         DEFAULT = .jcall(solver, "V", "setDefaultSearch"),
         RANDOM = .jcall(solver, "V", "setRandomSearch"),
         DOM_OVER_W_DEG = .jcall(solver, "V", "setDomOverWDegSearch"),
         DOM_OVER_W_DEG_REF = .jcall(solver, "V", "setDomOverWDegRefSearch"),
         MIN_DOM_LB = .jcall(solver, "V", "setMinDomLBSearch"),
         MIN_DOM_UB = .jcall(solver, "V", "setMinDomUBSearch"),
         ACTIVITY_BASED = .jcall(solver, "V", "setActivityBasedSearch"),
         CONFLICT_HISTORY = .jcall(solver, "V", "setConflictHistorySearch")
  )
  start_time = Sys.time()
  for (i in 1:nb_solutions) {
    start_sol_time = Sys.time()
    struct <- .jcall(solver, "Lsolver/LandscapeStructure;", "findSolution")
    if (is.null(struct)) {
      if (length(structs_json) == 0) {
        stop("User targets cannot be satisfied")
      } else {
        stop("No more solutions satisfying user targets exist")
      }
    }
    cat("Landscape structure", i, "found in", as.numeric(difftime(Sys.time(), start_sol_time, unit = "s")), "s", sep = " ")
    sol <- .jcall(struct, "Ljava/lang/String;", "toJSON");
    structs_json <- append(structs_json, sol)
  }
  if (nb_solutions > 1) {
    cat("All landscape structures found in", as.numeric(difftime(Sys.time(), start_time, unit = "s")), "s", sep = " ")
  }
  return(structs_json)
}
