context("Utility")

test_that("suppress_olw works", {
  expect_warning(shapes / scales)
  expect_silent(suppress_olw(shapes / scales))
  expect_warning(suppress_olw(warning("Warning")))
})
