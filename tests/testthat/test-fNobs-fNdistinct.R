context("fNobs and fNdistinct")

rm(list = ls())

x <- rnorm(100)
xNA <- x
xNA[sample.int(100,20)] <- NA
f <- as.factor(sample.int(10, 100, TRUE))
data <- fsubset(wlddev, iso3c %in% c("BLZ","IND","USA","SRB","GRL"))
g <- GRP(droplevels(data$iso3c))
dataNA <- na_insert(data)
m <- as.matrix(data)
mNA <- as.matrix(dataNA)

Nobs <- function(x) sum(!is.na(x))
Ndistinct <- function(x, na.rm = FALSE) {
  if(na.rm) return(length(unique(x[!is.na(x)])))
  return(length(unique(x)))
}

# fNobs

test_that("fNobs performs like Nobs (defined above)", {
  expect_equal(fNobs(NA), as.double(Nobs(NA)))
  expect_equal(fNobs(1), Nobs(1))
  expect_equal(fNobs(1:3), Nobs(1:3))
  expect_equal(fNobs(-1:1), Nobs(-1:1))
  expect_equal(fNobs(x), Nobs(x))
  expect_equal(fNobs(xNA), Nobs(xNA))
  expect_equal(fNobs(data), fNobs(m))
  expect_equal(fNobs(m), dapply(m, Nobs))
  expect_equal(fNobs(mNA), dapply(mNA, Nobs))
  expect_equal(fNobs(x, f), BY(x, f, Nobs))
  expect_equal(fNobs(xNA, f), BY(xNA, f, Nobs))
  expect_equal(fNobs(m, g), BY(m, g, Nobs))
  expect_equal(fNobs(mNA, g), BY(mNA, g, Nobs))
  expect_equal(dapply(fNobs(data, g), unattrib), BY(data, g, Nobs))
  expect_equal(dapply(fNobs(dataNA, g), unattrib), BY(dataNA, g, Nobs))
})

test_that("fNobs performs numerically stable", {
  expect_true(all_obj_equal(replicate(50, fNobs(1), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(NA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(x), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(xNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(m), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(mNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(data), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(dataNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(x, f), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(xNA, f), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(m, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(mNA, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(data, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNobs(dataNA, g), simplify = FALSE)))
})

test_that("fNobs handles special values in the right way", {
  expect_equal(fNobs(NA), 0)
  expect_equal(fNobs(NaN), 0)
  expect_equal(fNobs(Inf), 1)
  expect_equal(fNobs(-Inf), 1)
  expect_equal(fNobs(TRUE), 1)
  expect_equal(fNobs(FALSE), 1)
})

test_that("fNobs produces errors for wrong input", {
  expect_visible(fNobs("a"))
  expect_visible(fNobs(NA_character_))
  expect_visible(fNobs(mNA))
  expect_visible(fNobs(mNA, g))
  expect_error(fNobs(1:2,1:3))
  expect_error(fNobs(m,1:31))
  expect_error(fNobs(m, 1))
  expect_error(fNobs(data,1:31))
  expect_visible(fNobs(wlddev))
  expect_visible(fNobs(wlddev, wlddev$iso3c))
})



# fNdistinct

test_that("fNdistinct performs like Ndistinct (defined above)", {
  expect_equal(fNdistinct(NA), 0)
  expect_equal(fNdistinct(NA, na.rm = FALSE), 1)
  expect_equal(fNdistinct(1), Ndistinct(1, na.rm = TRUE))
  expect_equal(fNdistinct(1:3), Ndistinct(1:3, na.rm = TRUE))
  expect_equal(fNdistinct(-1:1), Ndistinct(-1:1, na.rm = TRUE))
  expect_equal(fNdistinct(1, na.rm = FALSE), Ndistinct(1))
  expect_equal(fNdistinct(1:3, na.rm = FALSE), Ndistinct(1:3))
  expect_equal(fNdistinct(-1:1, na.rm = FALSE), Ndistinct(-1:1))
  expect_equal(fNdistinct(x), Ndistinct(x, na.rm = TRUE))
  expect_equal(fNdistinct(x, na.rm = FALSE), Ndistinct(x))
  expect_equal(fNdistinct(xNA, na.rm = FALSE), Ndistinct(xNA))
  expect_equal(fNdistinct(xNA), Ndistinct(xNA, na.rm = TRUE))
  expect_equal(fNdistinct(data), fNdistinct(m))
  expect_equal(fNdistinct(m), dapply(m, Ndistinct, na.rm = TRUE))
  expect_equal(fNdistinct(m, na.rm = FALSE), dapply(m, Ndistinct))
  expect_equal(fNdistinct(mNA, na.rm = FALSE), dapply(mNA, Ndistinct))
  expect_equal(fNdistinct(mNA), dapply(mNA, Ndistinct, na.rm = TRUE))
  expect_equal(fNdistinct(x, f), BY(x, f, Ndistinct, na.rm = TRUE))
  expect_equal(fNdistinct(x, f, na.rm = FALSE), BY(x, f, Ndistinct))
  expect_equal(fNdistinct(xNA, f, na.rm = FALSE), BY(xNA, f, Ndistinct))
  expect_equal(fNdistinct(xNA, f), BY(xNA, f, Ndistinct, na.rm = TRUE))
  expect_equal(fNdistinct(m, g), BY(m, g, Ndistinct, na.rm = TRUE))
  expect_equal(fNdistinct(m, g, na.rm = FALSE), BY(m, g, Ndistinct))
  expect_equal(fNdistinct(mNA, g, na.rm = FALSE), BY(mNA, g, Ndistinct))
  expect_equal(fNdistinct(mNA, g), BY(mNA, g, Ndistinct, na.rm = TRUE))
  expect_equal(dapply(fNdistinct(data, g), unattrib), BY(data, g, Ndistinct, na.rm = TRUE))
  expect_equal(dapply(fNdistinct(data, g, na.rm = FALSE), unattrib), BY(data, g, Ndistinct))
  expect_equal(dapply(fNdistinct(dataNA, g, na.rm = FALSE), unattrib), BY(dataNA, g, Ndistinct))
  expect_equal(dapply(fNdistinct(dataNA, g), unattrib), BY(dataNA, g, Ndistinct, na.rm = TRUE))
})

test_that("fNdistinct performs numerically stable", {
  expect_true(all_obj_equal(replicate(50, fNdistinct(1), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(NA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(NA, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(x), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(x, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(xNA, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(xNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(m), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(m, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(mNA, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(mNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(data), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(data, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(dataNA, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(dataNA), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(x, f), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(x, f, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(xNA, f, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(xNA, f), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(m, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(m, g, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(mNA, g, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(mNA, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(data, g), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(data, g, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(dataNA, g, na.rm = FALSE), simplify = FALSE)))
  expect_true(all_obj_equal(replicate(50, fNdistinct(dataNA, g), simplify = FALSE)))
})

test_that("fNdistinct handles special values in the right way", {
  expect_equal(fNdistinct(NA), 0)
  expect_equal(fNdistinct(NaN), 0)
  expect_equal(fNdistinct(Inf), 1)
  expect_equal(fNdistinct(-Inf), 1)
  expect_equal(fNdistinct(TRUE), 1)
  expect_equal(fNdistinct(FALSE), 1)
  expect_equal(fNdistinct(c(TRUE,TRUE)), 1)
  expect_equal(fNdistinct(c(TRUE,FALSE)), 2)
  expect_equal(fNdistinct(c(FALSE,TRUE)), 2)
  expect_equal(fNdistinct(c(FALSE,FALSE)), 1)
  expect_equal(fNdistinct(c(NA,TRUE,TRUE,NA)), 1)
  expect_equal(fNdistinct(c(NA,TRUE,FALSE,NA)), 2)
  expect_equal(fNdistinct(c(NA,FALSE,TRUE,NA)), 2)
  expect_equal(fNdistinct(c(NA,FALSE,FALSE,NA)), 1)
  # expect_equal(max(fNdistinct(mNA > 10)), 1) # These tests are insecure to random number generation
  # expect_equal(max(fNdistinct(mNA > 10, g)), 1)
  expect_equal(fNdistinct(NA, na.rm = FALSE), 1)
  expect_equal(fNdistinct(NaN, na.rm = FALSE), 1)
  expect_equal(fNdistinct(Inf, na.rm = FALSE), 1)
  expect_equal(fNdistinct(-Inf, na.rm = FALSE), 1)
  expect_equal(fNdistinct(TRUE, na.rm = FALSE), 1)
  expect_equal(fNdistinct(FALSE, na.rm = FALSE), 1)
  expect_equal(fNdistinct(c(TRUE,TRUE), na.rm = FALSE), 1)
  expect_equal(fNdistinct(c(TRUE,FALSE), na.rm = FALSE), 2)
  expect_equal(fNdistinct(c(FALSE,TRUE), na.rm = FALSE), 2)
  expect_equal(fNdistinct(c(FALSE,FALSE), na.rm = FALSE), 1)
  expect_equal(fNdistinct(c(NA,TRUE,TRUE,NA), na.rm = FALSE), 2)
  expect_equal(fNdistinct(c(NA,TRUE,FALSE,NA), na.rm = FALSE), 3)
  expect_equal(fNdistinct(c(NA,FALSE,TRUE,NA), na.rm = FALSE), 3)
  expect_equal(fNdistinct(c(NA,FALSE,FALSE,NA), na.rm = FALSE), 2)
  # expect_equal(max(fNdistinct(mNA > 10, na.rm = FALSE)), 2)
  # expect_equal(max(fNdistinct(mNA > 10, g, na.rm = FALSE)), 2)
})

test_that("fNdistinct produces errors for wrong input", {
  expect_visible(fNdistinct("a"))
  expect_visible(fNdistinct(NA_character_))
  expect_visible(fNdistinct(mNA))
  expect_visible(fNdistinct(mNA, g))
  expect_error(fNdistinct(1:2,1:3))
  expect_error(fNdistinct(m,1:31))
  expect_error(fNdistinct(m, 1))
  expect_error(fNdistinct(data,1:31))
  expect_visible(fNdistinct(wlddev))
  expect_visible(fNdistinct(wlddev, wlddev$iso3c))
})
