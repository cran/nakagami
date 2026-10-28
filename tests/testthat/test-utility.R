test_that("recycling preserves independent cycles and zero lengths", {
  expect_equal(recycle_naka(1:7, 1:2, 1:3),
               list(x = 1:7, shape = rep_len(1:2, 7), scale = rep_len(1:3, 7)))
  expect_equal(recycle_naka(numeric(), 1, 1),
               list(x = numeric(), shape = numeric(), scale = numeric()))
})
