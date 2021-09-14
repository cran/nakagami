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
#' @param n number of observations. If `length(n) > 1`, the length is taken to
#'     be the number required.
#' @param shape vector of positive shape parameters.
#' @param scale vector of positive scale parameters.
#' @param log,log.p logical; if `TRUE`, probabilities `p` are given as `log(p)`.
#' @param lower.tail logical; if `TRUE` (default), probabilities are
#'    \eqn{P[X \le x]} otherwise, \eqn{P[X > x]}.
#' @return `dnaka` gives the density, `pnaka` gives the distribution function,
#'    `qnaka` gives the quantile function and `rnaka` generates random deviates.
#'
#'    The length of the result is determined by `n` for `rnaka`, and is the
#'    maximum of the lengths of the numerical arguments for the other functions.
#'
#'    The numerical arguments other than `n` are recycled to the length of the
#'    result.
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
#' @seealso The [Gamma][stats::GammaDist] distribution is closed related to the
#'    Nakgami distribution.

dnaka <- function(x, shape, scale, log = FALSE) {
  assertthat::assert_that(is_logical_scalar(log))
  assertthat::assert_that(is_naka_parameters(shape, scale))

  rate <- suppress_olw(shape / scale)

  if (!log) {
    suppress_olw(2 * x * stats::dgamma(
      x = x^2,
      shape = shape,
      rate = rate,
      log = FALSE
    ))
  } else {
    suppress_olw(log(x) + log(2) + stats::dgamma(
      x = x^2,
      shape = shape,
      rate = rate,
      log = TRUE
    ))
  }
}

#' @rdname Nakagami
#' @export
pnaka <- function(q, shape, scale, lower.tail = TRUE, log.p = FALSE) {
  assertthat::assert_that(is_naka_parameters(shape, scale))
  assertthat::assert_that(is_logical_scalar(log.p))
  assertthat::assert_that(is_logical_scalar(lower.tail))
  rate <- suppress_olw(shape / scale)

  stats::pgamma(
    q = q^2,
    shape = shape,
    rate = rate,
    lower.tail = lower.tail,
    log.p = log.p
  )
}

#' @rdname Nakagami
#' @export
qnaka <- function(p, shape, scale, lower.tail = TRUE, log.p = FALSE) {
  assertthat::assert_that(is_naka_parameters(shape, scale))
  assertthat::assert_that(is_logical_scalar(log.p))
  assertthat::assert_that(is_logical_scalar(lower.tail))
  rate <- suppress_olw(shape / scale)

  if (!log.p) {
    stats::qgamma(
      p = p,
      shape = shape,
      rate = rate,
      lower.tail = lower.tail
    ) ^ (1 / 2)
  } else {
    stats::qgamma(
      p = p,
      shape = shape,
      rate = rate,
      lower.tail = lower.tail,
      log.p = TRUE
    ) ^ (1 / 2)
  }
}

#' @rdname Nakagami
#' @export
rnaka <- function(n, shape, scale) {
  if (length(n) > 1) n <- length(n)

  assertthat::assert_that(is_naka_parameters(shape, scale))
  assertthat::assert_that(is_positive_integer(n))

  rate <- suppress_olw(shape / scale)

  sqrt(stats::rgamma(
    n = n,
    shape = shape,
    rate = rate
  ))
}
