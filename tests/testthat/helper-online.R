# Skip tests that hit the FUNGuild web API when that endpoint is down.
# Host reachability is not enough: mycoportal.org may respond while
# /funguild/services/api/db_return.php returns 404 or non-JSON.

skip_if_funguild_api_unavailable <- function() {
  url <- formals(FUNGuildR::funguild_query)$db
  host <- httr::parse_url(url)$hostname
  testthat::skip_if_offline(host = host)

  resp <- tryCatch(
    httr::GET(
      url,
      query = list(qField = "taxon", qText = "Agaricus"),
      httr::timeout(10)
    ),
    error = function(e) NULL
  )
  available <- !is.null(resp) &&
    httr::status_code(resp) < 400 &&
    isTRUE(grepl(
      "json",
      resp$headers[["content-type"]],
      ignore.case = TRUE
    ))
  testthat::skip_if_not(
    available,
    sprintf("FUNGuild API at %s is unavailable", host)
  )
}
