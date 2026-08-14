test_that("funguild_query works with a local database", {
  result <- funguild_query("Symbiotroph", "trophicMode", funguild_testdb)
  expect_gt(nrow(result), 0)
  expect_true(all(grepl("Symbiotroph", result$trophicMode, ignore.case = TRUE)))
})

test_that("funguild_query errors informatively when the API is unreachable", {
  err <- tryCatch(
    funguild_query("Agaricus", "taxon", db = "http://127.0.0.1:1"),
    error = identity
  )
  expect_s3_class(err, "error")
  msg <- conditionMessage(err)
  expect_match(msg, "unavailable")
  expect_match(msg, "get_funguild_db\\(\\)")
  expect_match(msg, "db argument")
  expect_match(msg, "funguild_query\\(\"Agaricus\", \"taxon\", db = db\\)")
})

test_that("funguild_query errors informatively on HTTP API failures", {
  fake <- structure(
    list(
      url = "https://mycoportal.org/funguild/services/api/db_return.php",
      status_code = 404L,
      headers = list(`content-type` = "text/html")
    ),
    class = "response"
  )
  err <- tryCatch(
    FUNGuildR:::check_funguild_api_response(fake, "Agaricus", "taxon"),
    error = identity
  )
  expect_s3_class(err, "error")
  msg <- conditionMessage(err)
  expect_match(msg, "HTTP 404")
  expect_match(msg, "get_funguild_db\\(\\)")
  expect_match(msg, "funguild_query\\(\"Agaricus\", \"taxon\", db = db\\)")
})

test_that("funguild_query errors informatively on non-JSON API responses", {
  fake <- structure(
    list(
      url = "https://mycoportal.org/funguild/services/api/db_return.php",
      status_code = 200L,
      headers = list(`content-type` = "text/html")
    ),
    class = "response"
  )
  err <- tryCatch(
    FUNGuildR:::check_funguild_api_response(fake, "Agaricus", "taxon"),
    error = identity
  )
  expect_s3_class(err, "error")
  msg <- conditionMessage(err)
  expect_match(msg, "invalid response of type 'text/html'")
  expect_match(msg, "get_funguild_db\\(\\)")
})
