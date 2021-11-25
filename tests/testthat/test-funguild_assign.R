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
  result_online <- funguild_query("ectomycorrhizal*", "guild")
  testthat::skip_if_not(file.exists(dbfile))
  db <- readRDS(dbfile)
  result_local <- funguild_query("ectomycorrhizal*", "guild", db = db)
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

test_that("funguild_assign accepts a nonstandard taxonomy column in a character", {
  expect_known_value(
    funguild_assign(sample_fungi$Taxonomy, db = funguild_testdb, tax_col = "tax"),
    file = "funguild_tax_col_char",
    update = FALSE
  )
})

rankabbrevs <- c("k", "p", "c", "o", "f", "g", "s")
reformat <- sample_fungi %>%
  tidyr::separate(Taxonomy, into = rankabbrevs, sep = ";") %>%
  tidyr::pivot_longer(
    cols = !!rankabbrevs,
    names_to = "rank",
    values_to = "taxon"
  ) %>%
  dplyr::group_by_all() %>%
  dplyr::ungroup(rank, taxon)
reformat_sintax <- reformat %>%
  dplyr::summarize(Taxonomy = paste(rank, taxon, sep = ":", collapse = ",")) %>%
  dplyr::left_join(dplyr::select(sample_fungi, Common.Name, Species), .)
reformat_unite <- reformat %>%
  dplyr::summarize(Taxonomy = paste(rank, taxon, sep = "__", collapse = ";")) %>%
  dplyr::left_join(dplyr::select(sample_fungi, Common.Name, Species), .)

test_that("sintax-style taxonomy works", {
  expect_equal(
    funguild_assign(sample_fungi$Taxonomy, db = funguild_testdb) %>%
      dplyr::select(-"Taxonomy"),
    funguild_assign(reformat_sintax$Taxonomy, db = funguild_testdb) %>%
      dplyr::select(-"Taxonomy")
  )
})

test_that("unite-style taxonomy works", {
  expect_equal(
    funguild_assign(sample_fungi$Taxonomy, db = funguild_testdb) %>%
      dplyr::select(-"Taxonomy"),
    funguild_assign(reformat_unite$Taxonomy, db = funguild_testdb) %>%
      dplyr::select(-"Taxonomy")
  )
})
