# Recycle each argument independently, before combining parameters.
recycle_naka <- function(x, shape, scale) {
  check_naka_parameters(shape, scale)
  if (is.null(x)) x <- numeric()
  if (!(is.numeric(x) || is.logical(x))) {
    stop("quantiles and probabilities must be numeric", call. = FALSE)
  }
  args <- list(x = x, shape = shape, scale = scale)
  sizes <- lengths(args)
  n <- if (any(sizes == 0L)) 0L else max(sizes)
  lapply(args, rep_len, length.out = n)
}

# Prefer direct arithmetic for precision near the Gamma mean. Fall back to
# logarithms when an intermediate square overflows or underflows.
naka_gamma_argument <- function(x, shape, scale) {
  log_y <- 2 * log(x) + log(shape) - log(scale)
  y <- (x / sqrt(scale))^2 * shape
  extreme <- which(y == 0 | is.infinite(y))
  y[extreme] <- exp(log_y[extreme])
  list(y = y, log_y = log_y)
}

# Compensate for rounding in 1 + x. At x below machine precision, use the
# derivative of log Gamma at 1 (minus Euler's constant).
naka_lgamma1p <- function(x) {
  out <- lgamma(1 + x)
  small <- which(x < 1e-4)
  delta <- (1 + x[small]) - 1
  slope <- rep(-0.5772156649015329, length(small))
  nonzero <- which(delta > 0)
  slope[nonzero] <- out[small[nonzero]] / delta[nonzero]
  out[small] <- x[small] * slope
  out
}
