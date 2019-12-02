## General points:

# Check that log, log.p and lower.tail works as expected:
#  1. Should return 1 - X and log(X) appropriatly.
#  2. Should log-probs for q.
#  2. Should throw error when the input isn't scalar.

# Check type correctness of the input parameters.

# Check recycling:
#  1. Length of output equals max(x, shape, scale) for d, p, q
#  2. Length of output always equals `n` for r.

context("Nakagami")

test_that("dnaka: log works", {
  expect_equal(
    log(dnaka(x, shape = shape, scale = scale)),
    dnaka(x, shape = shape, scale = scale, log = TRUE)
  )
})

test_that("dnaka: Integral agrees with pnaka at 0.5", {
  lhs <- integrate(dnaka,
    lower = 0, upper = 0.5,
    shape = shape, scale = scale
  )$value
  rhs <- pnaka(0.5, shape = shape, scale = scale)
  expect_equal(lhs, rhs)
})

test_that("dnaka: Integrates to 1", {
  lhs <- integrate(dnaka,
    lower = 0, upper = Inf,
    shape = shape, scale = scale
  )$value
  rhs <- 1
  expect_equal(lhs, rhs)
})

test_that("dnaka: Recycling works", {
  lhs <- length(dnaka(x, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(x), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(dnaka(1:10 / 11, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(1:10 / 11), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(dnaka(x, shape = shapes, scale = scales, log = TRUE))
  rhs <- max(length(shapes), length(x), length(scales))
  expect_equal(lhs, rhs)
})

test_that("dnaka: log must be scalar", {
  expect_error(dnaka(x, shape = shape, scale = scale, log = c(TRUE, FALSE)),
    regexp = "log is not a logical scalar"
  )
  expect_error(dnaka(x, shape = shape, scale = scale, log = "TRUE"),
    regexp = "log is not a logical scalar"
  )
  expect_silent(dnaka(x, shape = shape, scale = scale, log = TRUE))
})

test_that("pnaka: log.p works", {
  expect_equal(
    log(pnaka(q, shape = shape, scale = scale)),
    pnaka(q, shape = shape, scale = scale, log.p = TRUE)
  )
})

test_that("pnaka: lower.tail works", {
  expect_equal(
    1 - pnaka(q, shape = shape, scale = scale),
    pnaka(q, shape = shape, scale = scale, lower.tail = FALSE)
  )
})

test_that("pnaka: lower.tail and log.p works together", {
  expect_equal(
    log(1 - pnaka(q, shape = shape, scale = scale)),
    pnaka(q,
      shape = shape, scale = scale, lower.tail = FALSE,
      log.p = TRUE
    )
  )
})

test_that("pnaka: Recycling works", {
  lhs <- length(pnaka(q, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(q), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(pnaka(1:10 / 11, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(1:10 / 11), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(pnaka(q, shape = shapes, scale = scales, log.p = TRUE))
  rhs <- max(length(shapes), length(q), length(scales))
  expect_equal(lhs, rhs)
})

test_that("pnaka: log.p must be scalar", {
  expect_error(pnaka(q, shape = shape, scale = scale, log.p = c(TRUE, FALSE)),
    regexp = "log.p is not a logical scalar"
  )
  expect_error(pnaka(q, shape = shape, scale = scale, log.p = "TRUE"),
    regexp = "log.p is not a logical scalar"
  )
  expect_silent(pnaka(q, shape = shape, scale = scale, log.p = TRUE))
})

test_that("pnaka: lower.tails must be scalar", {
  expect_error(pnaka(q,
    shape = shape, scale = scale,
    lower.tail = c(TRUE, FALSE)
  ),
  regexp = "lower.tail is not a logical scalar"
  )
  expect_error(pnaka(q, shape = shape, scale = scale, lower.tail = "TRUE"),
    regexp = "lower.tail is not a logical scalar"
  )
  expect_silent(pnaka(q, shape = shape, scale = scale, lower.tail = TRUE))
})

test_that("qnaka: log.p works", {
  expect_equal(
    qnaka(p, shape = shape, scale = scale),
    qnaka(log(p), shape = shape, scale = scale, log.p = TRUE)
  )
})

test_that("qnaka: lower.tail works", {
  expect_equal(
    qnaka(p, shape = shape, scale = scale),
    qnaka(1 - p, shape = shape, scale = scale, lower.tail = FALSE)
  )
})

test_that("qnaka: lower.tail and log.p works together", {
  expect_equal(
    qnaka(p, shape = shape, scale = scale),
    qnaka(log(1 - p),
      shape = shape, scale = scale,
      lower.tail = FALSE, log.p = TRUE
    )
  )
})

test_that("qnaka: Recycling works", {
  lhs <- length(qnaka(p, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(p), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(qnaka(p = 1:10 / 11, shape = shapes, scale = scales))
  rhs <- max(length(shapes), length(1:10 / 11), length(scales))
  expect_equal(lhs, rhs)

  lhs <- length(qnaka(log(p), shape = shapes, scale = scales, log.p = TRUE))
  rhs <- max(length(shapes), length(p), length(scales))
  expect_equal(lhs, rhs)
})

test_that("qnaka: log.p must be scalar", {
  expect_error(qnaka(p, shape = shape, scale = scale, log.p = c(TRUE, FALSE)),
    regexp = "log.p is not a logical scalar"
  )
  expect_error(qnaka(p, shape = shape, scale = scale, log.p = "TRUE"),
    regexp = "log.p is not a logical scalar"
  )
  expect_silent(qnaka(log(p), shape = shape, scale = scale, log.p = TRUE))
})

test_that("qnaka: lower.tails must be scalar", {
  expect_error(qnaka(p,
    shape = shape, scale = scale,
    lower.tail = c(TRUE, FALSE)
  ),
  regexp = "lower.tail is not a logical scalar"
  )
  expect_error(qnaka(p, shape = shape, scale = scale, lower.tail = "TRUE"),
    regexp = "lower.tail is not a logical scalar"
  )
  expect_silent(qnaka(p, shape = shape, scale = scale, lower.tail = TRUE))
})

test_that("qnaka: Is the inverse of pnaka", {
  expect_equal(
    pnaka(qnaka(p, shape = shape, scale = scale),
      shape = shape,
      scale = scale
    ),
    p
  )
  expect_equal(
    qnaka(pnaka(q, shape = shape, scale = scale),
      shape = shape,
      scale = scale
    ),
    q
  )
})

test_that("rnaka: length(n) works", {
  set.seed(313)
  lhs <- rnaka(4, shape = shape, scale = scale)
  set.seed(313)
  rhs <- rnaka(LETTERS[1:4], shape = shape, scale = scale)
  expect_equal(lhs, rhs)
})

test_that("qnaka: Recycling works", {
  lhs <- length(rnaka(10, shape = shapes, scale = scales))
  rhs <- 10
  expect_equal(lhs, rhs)
})
