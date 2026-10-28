is_naka_parameters <- function(shape, scale) {
  is.numeric(shape) && is.numeric(scale) &&
    all(is.finite(shape) & shape > 0) &&
    all(is.finite(scale) & scale > 0)
}

check_naka_parameters <- function(shape, scale) {
  if (!is_naka_parameters(shape, scale)) {
    stop("shape and scale are not valid parameter vectors", call. = FALSE)
  }
}

is_nonnegative_integer <- function(x) {
  is.numeric(x) && length(x) == 1L && is.finite(x) &&
    x >= 0 && x == floor(x)
}

is_logical_scalar <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}

check_logical_scalar <- function(x, name) {
  if (!is_logical_scalar(x)) {
    stop(paste(name, "is not a logical scalar"), call. = FALSE)
  }
}
