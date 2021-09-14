is_naka_parameters <- function(shape, scale) {
  if (!is.numeric(shape) | !is.numeric(scale)) {
    return(FALSE)
  }
  if (any(shape <= 0)) {
    return(FALSE)
  }
  if (any(scale <= 0)) {
    return(FALSE)
  }
  TRUE
}

attr(is_naka_parameters, "fail") <- function(call, env) {
  paste0("shape and scale are not valid parameter vectors")
}

is_positive_integer <- function(x) {
  if (!assertthat::is.count(x)) {
    return(FALSE)
  }
  x > 0
}

attr(is_positive_integer, "fail") <- function(call, env) {
  paste0(deparse(call$x), " is not a positive integer")
}

is_logical_scalar <- function(x) length(x) == 1L & is.logical(x)

attr(is_logical_scalar, "fail") <- function(call, env) {
  paste0(deparse(call$x), " is not a logical scalar")
}
