#' Landscape structure generator
#'
#' @description Generate landscape structures satisfying user targets
#'
#'
#'
generate_landscape_structure <- function(targets_str, targets_file, output_prefix, nb_solutions=1, search_strategy="DEFAULT") {
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
  struct <- .jcall(solver, "Lsolver/LandscapeStructure;", "findSolution")
  if (is.null(struct)) {
    stop("User targets cannot be satisfied")
  }
  struct_json <- .jcall(struct, "Ljava/lang/String;", "toJSON")
  return(struct_json)
}
