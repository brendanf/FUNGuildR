# By Brendan Furneaux

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

stop_funguild_api_unavailable <- function(
  url,
  reason = NULL,
  text = NULL,
  field = NULL
) {
  detail <- ""
  if (!is.null(reason) && nzchar(reason)) {
    detail <- paste0(" (", reason, ")")
  }
  example <- paste0(
    "  db <- get_funguild_db()\n",
    "  funguild_query(text, field, db = db)"
  )
  if (!is.null(text) && !is.null(field)) {
    example <- sprintf(
      "  db <- get_funguild_db()\n  funguild_query(%s, %s, db = db)",
      paste(deparse(text), collapse = " "),
      paste(deparse(field), collapse = " ")
    )
  }
  stop(
    sprintf(
      paste0(
        "The FUNGuild web API at '%s' is unavailable%s.\n",
        "Download the database locally with get_funguild_db() and pass ",
        "it as the db argument to funguild_query(), for example:\n%s"
      ),
      url,
      detail,
      example
    ),
    call. = FALSE
  )
}

check_funguild_api_response <- function(
  response,
  text,
  field,
  url = response$url
) {
  if (httr::http_error(response)) {
    stop_funguild_api_unavailable(
      url,
      reason = paste("HTTP", httr::status_code(response)),
      text = text,
      field = field
    )
  }
  ctype <- response$headers[["content-type"]]
  if (!isTRUE(is.character(ctype) && startsWith(ctype, "application/json"))) {
    if (is.null(ctype)) {
      ctype <- "unknown"
    }
    stop_funguild_api_unavailable(
      url,
      reason = sprintf("invalid response of type '%s'", ctype),
      text = text,
      field = field
    )
  }
  response
}

make_taxkey <- function(x) {
  out <- gsub("\\b[kpcofgs](:|__)", "", x)
  out <- gsub("[_ ;,:]", "@", out)
  paste0("@", out, "@")
}
