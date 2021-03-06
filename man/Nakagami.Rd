% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nakagami.R
\name{Nakagami}
\alias{Nakagami}
\alias{dnaka}
\alias{pnaka}
\alias{qnaka}
\alias{rnaka}
\title{The Nakagami Density}
\usage{
dnaka(x, shape, scale, log = FALSE)

pnaka(q, shape, scale, lower.tail = TRUE, log.p = FALSE)

qnaka(p, shape, scale, lower.tail = TRUE, log.p = FALSE)

rnaka(n, shape, scale)
}
\arguments{
\item{x, q}{vector of quantiles.}

\item{shape}{vector of shape parameters greater than \code{1/2}.}

\item{scale}{vector of positive scale parameters.}

\item{log, log.p}{logical; if \code{TRUE}, probabilities \code{p} are given as \code{log(p)}.}

\item{lower.tail}{logical; if \code{TRUE} (default), probabilities are
\eqn{P[X \le x]} otherwise, \eqn{P[X > x]}.}

\item{p}{vector of probabilities.}

\item{n}{number of observations. If \code{length(n) > 1}, the length is taken to
be the number required.}
}
\value{
\code{dnaka} gives the density, \code{pnaka} gives the distribution function,
\code{qnaka} gives the quantile function and \code{rnaka} generates random deviates.

The length of the result is determined by \code{n} for \code{rnaka}, and is the
maximum of the lengths of the numerical arguments for the other functions.

The numerical arguments other than \code{n} are recycled to the length of the
result.
}
\description{
Density, distribution function, quantile function and random generation for
the Nakagami distribution with parameters \code{shape} and \code{scale}.
}
\details{
The Nakagami distribution with shape \eqn{m} and scale \eqn{\Omega} has
density \deqn{2m^m/{\Gamma(m)\Omega^m} x^(2m-1)e^(-m/\Omega x^2)} for
\eqn{x \ge 0}, \eqn{m \ge 1/2} and \eqn{\Omega > 0}.

If \eqn{Y} is \link[stats:GammaDist]{Gamma} distributed with \eqn{shape = m} and
\eqn{rate = m/\Omega} then \eqn{X = \sqrt Y} is Nakagami distributed
with \eqn{shape = m} and \eqn{scale = \Omega}.
}
\references{
Nakagami, N. 1960. "The M-Distribution, a General Formula of
Intensity of Rapid Fading." In Statistical Methods in Radio Wave
Propagation: Proceedings of a Symposium Held at the University of
California, edited by William C. Hoffman, 3-36. Permagon Press.
}
\seealso{
The \link[stats:GammaDist]{Gamma} distribution is closed related to the
Nakgami distribution.
}
