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

dbfile <- tempfile(fileext = "rds")

test_that("get_funguild_db works", {
  testthat::skip_if_offline(host = "www.stbates.org")
  db <- get_funguild_db()
  expect_is(db, "tbl_df")
  expect_gt(nrow(db), 100)
  saveRDS(db, dbfile)
})

test_that("direct assignment and stored db give same results", {
  testthat::skip_if_offline(host = "www.stbates.org")
  assignment_online <- funguild_assign(sample_fungi)
  testthat::skip_if_not(file.exists(dbfile))
  db <- readRDS(dbfile)
  assignment_local <- funguild_assign(sample_fungi, db)
  expect_identical(assignment_online, assignment_local)
})

test_that("direct query and stored db give same results", {
  testthat::skip_if_offline(host = "www.mycoportal.org")
  result_online <- funguild_query("Ectomycorrhizal*", "guild")
  testthat::skip_if_not(file.exists(dbfile))
  db <- readRDS(dbfile)
  result_local <- funguild_query("Ectomycorrhizal*", "guild", db = db)
  expect_identical(result_local, result_online)
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
