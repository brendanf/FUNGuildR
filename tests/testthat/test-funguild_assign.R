test_that("nemaguild_assign does not regress", {
  expect_known_value(
    nemaguild_assign(sample_nema, db = nemaguild_testdb),
    file = "nemaguild",
    update = FALSE
  )
})

test_that("funguild_assign does not regress", {
  expect_known_value(
    funguild_assign(sample_fungi, db = funguild_testdb),
    file = "funguild",
    update = FALSE
  )
})

test_that("funguild_assign accepts a character vector", {
  expect_known_value(
    funguild_assign(sample_fungi$Taxonomy, db = funguild_testdb),
    file = "funguild_char",
    update = FALSE
  )
})

test_that("get_funguild_db works", {
  testthat::skip_if_offline(host = "www.stbates.org")
  assignment <- funguild_assign(sample_fungi)
  expect_is(assignment, "tbl_df")
})

sample2 <- sample_fungi
sample2$Taxonomy <- chartr(";", ",", sample2$Taxonomy)
test_that("funguild_assign accepts a comma delimited tax column", {
  expect_known_value(
    funguild_assign(sample2, db = funguild_testdb),
    file = "funguild_comma",
    update = FALSE
  )
})

sample2$Taxonomy <- chartr(",", ":", sample2$Taxonomy)
test_that("funguild_assign accepts a comma delimited tax column", {
  expect_known_value(
    funguild_assign(sample2, db = funguild_testdb),
    file = "funguild_colon",
    update = FALSE
  )
})

names(sample2)[3] <- "classification"
test_that("funguild_assign accepts a nonstandard taxonomy column", {
  expect_known_value(
    funguild_assign(sample2, db = funguild_testdb, tax_col = "classification"),
    file = "funguild_tax_col",
    update = FALSE
  )
})



names(sample2)[3] <- "classification"
test_that("funguild_assign accepts a nonstandard taxonomy column in a character", {
  expect_known_value(
    funguild_assign(sample_fungi$Taxonomy, db = funguild_testdb, tax_col = "tax"),
    file = "funguild_tax_col_char",
    update = FALSE
  )
})
