context("Assertions")

test_that("is_naka_parameters works", {
  expect_true(is_naka_parameters(3, 2))
  expect_true(is_naka_parameters(c(3, 1, 3), c(4, 5)))
  expect_false(is_naka_parameters(lm, 2))
  expect_false(is_naka_parameters(lm, list()))
  expect_false(is_naka_parameters(-1, 1))
  expect_false(is_naka_parameters(1.1, -1.1))
  expect_false(is_naka_parameters(c(3, 0, 3), c(4, 1, 5)))
})

test_that("is_positive_integer works", {
  expect_false(is_positive_integer(-1))
  expect_false(is_positive_integer(0))
  expect_false(is_positive_integer(17.1))
  expect_false(is_positive_integer(c(1, 2, 3)))
  expect_false(is_positive_integer("haha"))
  expect_false(is_positive_integer(lm))
  expect_true(is_positive_integer(1))
  expect_true(is_positive_integer(10))
})

test_that("is_logical_scalar works", {
  expect_false(is_logical_scalar(-1))
  expect_false(is_logical_scalar(17))
  expect_false(is_logical_scalar(c(TRUE, TRUE, FALSE)))
  expect_false(is_logical_scalar("haha"))
  expect_false(is_logical_scalar(lm))
  expect_true(is_logical_scalar(TRUE))
  expect_true(is_logical_scalar(FALSE))
})
