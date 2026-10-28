test_that("pnaka respects the support in both tails and on the log scale", {
  q <- c(-Inf, -2, -0.1, 0, Inf)
  for (lower in c(TRUE, FALSE)) {
    expected <- if (lower) c(0, 0, 0, 0, 1) else c(1, 1, 1, 1, 0)
    expect_equal(pnaka(q, 1, 1, lower.tail = lower), expected)
    expect_equal(pnaka(q, 1, 1, lower.tail = lower, log.p = TRUE),
                 log(expected))
  }
})

test_that("dnaka handles the support and density limits at zero", {
  for (logged in c(TRUE, FALSE)) {
    expected <- c(0, 0, Inf, sqrt(2 / pi), 0, 0)
    if (logged) expected <- log(expected)
    expect_equal(dnaka(c(-Inf, -1, 0, 0, 0, Inf),
                       c(1, 1, 0.25, 0.5, 1, 1), 1, log = logged),
                 expected)
    expect_equal(dnaka(0, 0.5, 4, log = logged),
                 if (logged) log(sqrt(2 / pi) / 2) else sqrt(2 / pi) / 2)
  }
})

test_that("numerical arguments recycle independently", {
  x <- seq(0.2, 2, length.out = 7)
  p <- seq(0.1, 0.9, length.out = 7)
  shape <- c(0.5, 2)
  scale <- c(1, 2, 3)
  m <- rep_len(shape, 7)
  omega <- rep_len(scale, 7)
  for (logged in c(TRUE, FALSE)) {
    expected <- log(2 * x) + dgamma(x^2, m, scale = omega / m, log = TRUE)
    expect_equal(dnaka(x, shape, scale, log = logged),
                 if (logged) expected else exp(expected))
    for (lower in c(TRUE, FALSE)) {
      expect_equal(pnaka(x, shape, scale, lower.tail = lower, log.p = logged),
                   pgamma(x^2, m, scale = omega / m,
                          lower.tail = lower, log.p = logged))
      probs <- if (logged) log(p) else p
      expect_equal(qnaka(probs, shape, scale, lower.tail = lower, log.p = logged),
                   sqrt(qgamma(probs, m, scale = omega / m,
                               lower.tail = lower, log.p = logged)))
    }
  }
  set.seed(198)
  actual <- rnaka(7, shape, scale)
  set.seed(198)
  expected <- sqrt(rgamma(7, m)) / sqrt(m) * sqrt(omega)
  expect_equal(actual, expected)

  # Parameters longer than n must be truncated before recycling.
  set.seed(198)
  actual <- rnaka(4, c(1, 2), 1:5)
  set.seed(198)
  expect_equal(actual, sqrt(rgamma(4, rep_len(c(1, 2), 4))) /
                 sqrt(rep_len(c(1, 2), 4)) * sqrt(1:4))
})

test_that("empty inputs and zero draws are supported", {
  for (fun in list(dnaka, pnaka, qnaka)) {
    expect_identical(fun(numeric(), 1, 1), numeric())
    expect_identical(fun(0.5, numeric(), 1), numeric())
    expect_identical(fun(0.5, 1, numeric()), numeric())
  }
  expect_identical(rnaka(0, 1, 1), numeric())
  expect_identical(rnaka(numeric(), 1, 1), numeric())
  expect_error(rnaka(-1, 1, 1), "non-negative integer")
  expect_error(rnaka(1.5, 1, 1), "non-negative integer")
  expect_error(rnaka(NA_real_, 1, 1), "non-negative integer")
})

test_that("invalid parameters and flags have clear errors", {
  for (fun in list(dnaka, pnaka, qnaka, rnaka)) {
    for (bad in list(NA_real_, NaN, Inf, -Inf, 0, -1, "1", 1i)) {
      expect_error(fun(1, bad, 1), "valid parameter vectors")
      expect_error(fun(1, 1, bad), "valid parameter vectors")
    }
  }
  for (bad in list(NA, logical(), c(TRUE, FALSE))) {
    expect_error(dnaka(1, 1, 1, log = bad), "logical scalar")
    for (fun in list(pnaka, qnaka)) {
      expect_error(fun(0.5, 1, 1, log.p = bad), "logical scalar")
      expect_error(fun(0.5, 1, 1, lower.tail = bad), "logical scalar")
    }
  }
})

test_that("missing quantiles and probabilities propagate", {
  for (fun in list(dnaka, pnaka, qnaka)) {
    result <- fun(c(NA_real_, NaN), 1, 1)
    expect_true(is.na(result[1]))
    expect_true(is.nan(result[2]))
  }
})

test_that("the Gamma transformation avoids intermediate overflow and underflow", {
  # Shape 1 is Rayleigh; shape 1/2 is a scaled half-normal.
  expect_equal(pnaka(2e154, 1, 1e308), -expm1(-4))
  expect_equal(pnaka(2e154, 1, 1e308, lower.tail = FALSE, log.p = TRUE), -4)
  expect_equal(dnaka(2e154, 1, 1e308, log = TRUE),
               log(4) - 154 * log(10) - 4)
  expect_equal(dnaka(1e-200, 0.25, 1, log = TRUE),
               log(2) + 0.25 * log(0.25) - lgamma(0.25) + 100 * log(10))
  expect_equal(dnaka(1e-200, 0.25, 1) / 1e100,
               2 * 0.25^0.25 / gamma(0.25))
  expect_equal(qnaka(0.5, 0.25, 1e308) / 1e154,
               sqrt(qgamma(0.5, 0.25) / 0.25))
  expect_equal(pnaka(1e-200, 0.5, 1) / 1e-200, sqrt(2 / pi))
  expect_equal(pnaka(1e-200, 0.5, 1, log.p = TRUE),
               log(1e-200) + log(sqrt(2 / pi)))
  expect_equal(pnaka(1e-200, 0.5, 1, lower.tail = FALSE, log.p = TRUE) / 1e-200,
               -sqrt(2 / pi))
  expect_equal(qnaka(0, 1e308, 1), 0)
  expect_equal(qnaka(1, 1e308, 1, lower.tail = FALSE), 0)
  expect_equal(qnaka(1e-200, 0.5, 1) / 1e-200, sqrt(pi / 2))
  expect_equal(qnaka(log(1e-200), 0.5, 1, log.p = TRUE) / 1e-200,
               sqrt(pi / 2))
  expect_equal(qnaka(log1p(-1e-200), 0.5, 1,
                     lower.tail = FALSE, log.p = TRUE) / 1e-200,
               sqrt(pi / 2))
})

test_that("half-normal and Rayleigh identities hold across scales", {
  z <- c(0.1, 0.5, 1, 2, 4)
  probs <- c(0.01, 0.1, 0.5, 0.9, 0.99)
  for (scale in c(1e-300, 1, 1e300)) {
    x <- z * sqrt(scale)
    expect_equal(dnaka(x, 0.5, scale, log = TRUE),
                 log(2) + dnorm(z, log = TRUE) - log(scale) / 2)
    expect_equal(pnaka(x, 0.5, scale), 2 * pnorm(z) - 1)
    expect_equal(pnaka(x, 0.5, scale, lower.tail = FALSE, log.p = TRUE),
                 log(2) + pnorm(z, lower.tail = FALSE, log.p = TRUE))
    expect_equal(qnaka(probs, 0.5, scale) / sqrt(scale),
                 qnorm((probs + 1) / 2))
    expect_equal(pnaka(x, 1, scale, log.p = TRUE), log(-expm1(-z^2)))
    expect_equal(pnaka(x, 1, scale, lower.tail = FALSE, log.p = TRUE), -z^2)
    expect_equal(qnaka(probs, 1, scale) / sqrt(scale), sqrt(-log1p(-probs)))
  }
})

test_that("large shapes retain precision at the Gamma mean", {
  for (shape in c(1e24, 1e32, 1e100)) {
    expect_equal(pnaka(1, shape, 1), 0.5)
    expect_equal(dnaka(1, shape, 1, log = TRUE),
                 (log(2 / pi) + log(shape)) / 2)
  }
})

test_that("underflow fallbacks retain accuracy for very small shapes", {
  shape <- 1e-20
  log_p <- -1000 * shape
  log_q <- (-1000 - 0.5772156649015329 - log(shape)) / 2
  expect_equal(log(qnaka(log_p, shape, 1, log.p = TRUE)), log_q)
  expect_equal(pnaka(exp(log_q), shape, 1, log.p = TRUE) / log_p, 1)
  expect_equal(pnaka(exp(log_q), shape, 1, lower.tail = FALSE) / -log_p, 1)
})

test_that("non-numeric quantiles and probabilities are rejected", {
  for (fun in list(dnaka, pnaka, qnaka)) {
    for (bad in list("foo", list(1), factor("1"), 1i)) {
      expect_error(fun(bad, 1, 1), "must be numeric")
    }
    expect_equal(fun(c(FALSE, TRUE), 1, 1), fun(c(0, 1), 1, 1))
    expect_identical(fun(NULL, 1, 1), numeric())
  }
})
