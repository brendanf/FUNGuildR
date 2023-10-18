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

check_is_json <- function(response) {
  httr::warn_for_status(response)
  assertthat::assert_that(
    startsWith(response$headers$`content-type`, "application/json"),
    msg = sprintf(
      "URL '%s' gave an invalid response of type '%s'.",
      response$url,
      response$headers$`content-type`
    )
  )
  response
}

make_taxkey <- function(x) {
  out <- gsub("\\b[kpcofgs](:|__)", "", x)
  out <- gsub("[_ ;,:]", "@", out)
  paste0("@", out, "@")
}
