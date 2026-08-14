expect_engines_identical <- function(otu_table, db, tax_col = "Taxonomy") {
  expect_identical(
    funguild_assign(otu_table, db = db, tax_col = tax_col, engine = "r"),
    funguild_assign(otu_table, db = db, tax_col = tax_col, engine = "cpp")
  )
}

test_that("cpp and r engines agree on sample fungi", {
  expect_engines_identical(sample_fungi, funguild_testdb)
})

test_that("cpp and r engines agree on sample nematodes", {
  expect_engines_identical(sample_nema, nemaguild_testdb)
})

test_that("cpp and r engines agree on a character vector", {
  expect_engines_identical(sample_fungi$Taxonomy, funguild_testdb)
})

test_that("cpp and r engines agree on comma-delimited taxonomy", {
  sample2 <- sample_fungi
  sample2$Taxonomy <- chartr(";", ",", sample2$Taxonomy)
  expect_engines_identical(sample2, funguild_testdb)
})

test_that("cpp and r engines agree on colon-delimited taxonomy", {
  sample2 <- sample_fungi
  sample2$Taxonomy <- chartr(";", ":", sample2$Taxonomy)
  expect_engines_identical(sample2, funguild_testdb)
})

test_that("cpp and r engines agree with a custom taxonomy column", {
  sample2 <- sample_fungi
  names(sample2)[3] <- "classification"
  expect_engines_identical(
    sample2,
    funguild_testdb,
    tax_col = "classification"
  )
})

test_that("cpp and r engines agree on Sintax-style taxonomy", {
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
    dplyr::summarize(
      Taxonomy = paste(rank, taxon, sep = ":", collapse = ",")
    ) %>%
    dplyr::left_join(
      dplyr::select(sample_fungi, Common.Name, Species),
      .
    )
  expect_engines_identical(reformat_sintax, funguild_testdb)
})

test_that("cpp and r engines agree on Unite-style taxonomy", {
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
  reformat_unite <- reformat %>%
    dplyr::summarize(
      Taxonomy = paste(rank, taxon, sep = "__", collapse = ";")
    ) %>%
    dplyr::left_join(
      dplyr::select(sample_fungi, Common.Name, Species),
      .
    )
  expect_engines_identical(reformat_unite, funguild_testdb)
})
