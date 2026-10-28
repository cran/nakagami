#' The Nakagami Density
#'
#' Density, distribution function, quantile function and random generation for
#'    the Nakagami distribution with parameters `shape` and `scale`.
#'
#' The Nakagami distribution (Nakagami, 1960) with shape \eqn{m} and scale
#'    \eqn{\Omega} has density
#'    \deqn{2m^m/{\Gamma(m)\Omega^m} x^(2m-1)e^(-m/\Omega x^2)} for
#'    \eqn{x \ge 0}, \eqn{m > 0} and \eqn{\Omega > 0}.
#'
#' If \eqn{Y} is [Gamma][stats::GammaDist] distributed with \eqn{shape = m} and
#'    \eqn{rate = m/\Omega} then \eqn{X = \sqrt Y} is Nakagami distributed
#'    with \eqn{shape = m} and \eqn{scale = \Omega}.
#'
#' Sometimes, specifically in radio channels modeling, the parameter \eqn{m} is
#'    constrained to \eqn{m \ge 1/2}, but the density is defined for any
#'    \eqn{m > 0} (Kolar et al., 2004).
#'
#' @export
#' @name Nakagami
#' @param x,q vector of quantiles.
#' @param p vector of probabilities.
#' @param n non-negative integer number of observations. If `length(n) > 1`,
#'     the length is taken to be the number required.
#' @param shape vector of positive, finite shape parameters.
#' @param scale vector of positive, finite scale parameters.
#' @param log logical; if `TRUE`, the density is returned on the log scale.
#' @param log.p logical; if `TRUE`, probabilities are given on the log scale.
#' @param lower.tail logical; if `TRUE` (default), probabilities are
#'    \eqn{P[X \le x]} otherwise, \eqn{P[X > x]}.
#' @return `dnaka` gives the density, `pnaka` gives the distribution function,
#'    `qnaka` gives the quantile function and `rnaka` generates random deviates.
#'
#'    The length of the result is determined by `n` for `rnaka`, and is the
#'    maximum of the lengths of the numerical arguments for the other functions.
#'
#'    The numerical arguments other than `n` are recycled to the length of the
#'    result. A zero-length numerical argument gives a zero-length result for
#'    `dnaka`, `pnaka` and `qnaka`.
#'
#' @references Nakagami, N. 1960. "The M-Distribution, a General Formula of
#'    Intensity of Rapid Fading." In Statistical Methods in Radio Wave
#'    Propagation: Proceedings of a Symposium Held at the University of
#'    California, edited by William C. Hoffman, 3-36. Permagon Press.
#'
#' Kolar, R., Jirik, R., & Jan, J. (2004).
#'    Estimator comparison of the Nakagami-m parameter and its
#'    application in echocardiography. Radioengineering, 13(1), 8-12.
#'
#' @seealso The [Gamma][stats::GammaDist] distribution is closely related to the
#'    Nakagami distribution.

dnaka <- function(x, shape, scale, log = FALSE) {
  check_logical_scalar(log, "log")
  args <- recycle_naka(x, shape, scale)
  x <- args$x
  shape <- args$shape
  scale <- args$scale

  # Work with a unit-rate Gamma variable to avoid squaring x or forming
  # shape / scale before rescaling. Evaluate the Jacobian on the log scale.
  out <- rep(-Inf, length(x))
  out[is.na(x)] <- x[is.na(x)]
  positive <- which(x > 0 & is.finite(x))
  log_x <- log(x[positive])
  gamma_arg <- naka_gamma_argument(x[positive], shape[positive], scale[positive])
  log_y <- gamma_arg$log_y
  y <- gamma_arg$y
  out[positive] <- log(2) + log_y - log_x +
    stats::dgamma(y, shape = shape[positive], log = TRUE)

  # If y underflows, the small-y Gamma density still has a finite log.
  small <- which(y == 0)
  out[positive[small]] <- log(2) - log_x[small] +
    shape[positive[small]] * log_y[small] - lgamma(shape[positive[small]])
  out[positive[is.infinite(y)]] <- -Inf

  zero <- which(x == 0)
  out[zero[shape[zero] < 0.5]] <- Inf
  half <- zero[shape[zero] == 0.5]
  out[half] <- (log(2) - log(pi) - log(scale[half])) / 2

  if (log) out else exp(out)
}

#' @rdname Nakagami
#' @export
pnaka <- function(q, shape, scale, lower.tail = TRUE, log.p = FALSE) {
  check_logical_scalar(log.p, "log.p")
  check_logical_scalar(lower.tail, "lower.tail")
  args <- recycle_naka(q, shape, scale)

  gamma_arg <- naka_gamma_argument(pmax(args$x, 0), args$shape, args$scale)
  log_y <- gamma_arg$log_y
  y <- gamma_arg$y
  out <- stats::pgamma(y, shape = args$shape,
                       lower.tail = lower.tail, log.p = log.p)

  # Retain representable Nakagami probabilities when the squared variable
  # is subnormal or underflows. The omitted Gamma-series terms are O(y).
  small <- which(y < .Machine$double.xmin)
  log_p <- args$shape[small] * log_y[small] - naka_lgamma1p(args$shape[small])
  out[small] <- if (lower.tail) {
    if (log.p) log_p else exp(log_p)
  } else {
    if (log.p) {
      ifelse(log_p < -log(2), log1p(-exp(log_p)), log(-expm1(log_p)))
    } else {
      -expm1(log_p)
    }
  }
  out
}

#' @rdname Nakagami
#' @export
qnaka <- function(p, shape, scale, lower.tail = TRUE, log.p = FALSE) {
  check_logical_scalar(log.p, "log.p")
  check_logical_scalar(lower.tail, "lower.tail")
  args <- recycle_naka(p, shape, scale)
  y <- stats::qgamma(args$x, shape = args$shape,
                     lower.tail = lower.tail, log.p = log.p)
  out <- sqrt(y) / sqrt(args$shape) * sqrt(args$scale)

  # A Gamma quantile can underflow although its square root is representable.
  # For subnormal y, F(y) = y^shape / Gamma(shape + 1) to working precision.
  small <- which(y < .Machine$double.xmin)
  if (length(small)) {
    p <- args$x[small]
    log_p <- if (log.p) {
      if (lower.tail) p else log(-expm1(p))
    } else {
      if (lower.tail) log(p) else log1p(-p)
    }
    interior <- is.finite(log_p)
    small <- small[interior]
    log_p <- log_p[interior]
    out[small] <- exp((log_p + naka_lgamma1p(args$shape[small])) /
      args$shape[small] / 2 +
      (log(args$scale[small]) - log(args$shape[small])) / 2)
  }
  out
}

#' @rdname Nakagami
#' @export
rnaka <- function(n, shape, scale) {
  if (length(n) != 1L) n <- length(n)
  check_naka_parameters(shape, scale)
  if (!is_nonnegative_integer(n)) {
    stop("n is not a non-negative integer", call. = FALSE)
  }
  shape <- rep_len(shape, n)
  scale <- rep_len(scale, n)
  sqrt(stats::rgamma(n = n, shape = shape)) / sqrt(shape) * sqrt(scale)
}
