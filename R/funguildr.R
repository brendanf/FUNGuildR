# By Brendan Furneaux
# Reimplementation of Guilds_v1.1.py by Zewei Song

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

#' @importFrom magrittr "%>%"
#' @export
magrittr::`%>%`

#' @importFrom magrittr "%<>%"
#' @export
magrittr::`%<>%`

#' @importFrom stats na.omit
#' @export
stats::na.omit

#' Retrieve the FUNGuild or NEMAGuild database
#'
#' The two functions are exactly the same, but have different default values for the URL.
#'
#' @param db a length 1 character string giving the URL to retrieve the database from
#'
#' @return a \link[tibble]{tibble} containing the database, which can be passed to the \code{db}
#' argument of \link{funguild_assign} and \link{nemaguild_assign}
#' @export
#'
#' @examples
#' get_funguild_db()
get_funguild_db <- function(db = 'http://www.stbates.org/funguild_db.php'){
    httr::GET(url = db) %>%
      httr::content(as = "text") %>%
      stringr::str_split("\n") %>%
      unlist %>%
      magrittr::extract(7) %>%
      stringr::str_replace("^\\[", "") %>%
      stringr::str_replace("]</body>$", "") %>%
      stringr::str_replace_all("\\} , \\{", "} \n {") %>%
      stringr::str_split("\n") %>%
      unlist %>%
      purrr::map_dfr(function(record) {
                current_record <- jsonlite::fromJSON(record)
                if (current_record$taxonomicLevel == 20) {
                  current_record$taxon <-
                    stringr::str_replace(current_record$taxon, " ", "_")
                }
                if (!is.null(current_record[["TrophicMode"]])) {
                  current_record$trophicMode <- current_record$trophicMode
                }
                if (!is.null(current_record[["growthMorphology"]])) {
                  current_record$growthForm <- current_record$growthMorphology
                }
                purrr::flatten(current_record)
              }) %>%
      dplyr::select("taxon", "taxonomicLevel", "trophicMode", "guild",
                    "growthForm", "trait", "confidenceRanking", "notes",
                    "citationSource") %>%
      dplyr::mutate(searchkey = paste0("@", stringr::str_replace(taxon, "[ _]", "@"), "@"))
  }

#' @rdname  get_funguild_db
#' @export
#' @importFrom magrittr "%>%"
get_nemaguild_db <- function(db = 'http://www.stbates.org/nemaguild_db.php') {
   get_funguild_db(db)
}

#' Assign Guilds to Organisms Based on Taxonomic Classification
#'
#' These functions have identical behavior if supplied with a database; however
#' they download the database corresponding to their name by default.
#'
#' Taxa present in the database are matched to the taxa present in the supplied
#' \code{otu_table} by exact name.
#' In the case of multiple matches, the lowest (most specific) rank is chosen.
#' No attempt is made to check or correct the classification in
#' \code{otu_table$Taxonomy}.
#'
#' @param otu_table A \code{\link[base]{data.frame}} with a \code{character}
#' column named \code{Taxonomy}, as well as any other columns.
#' Each entry should be a comma-, colon- or semicolon-delimited classification
#' of an organism.
#' See \code{\link{sample_fungi}} and \code{\link{sample_nema}} for examples.
#' A \code{character} vector, representing only the taxonomic classification,
#' is also accepted.
#'
#' @param db A \code{\link[base]{data.frame}} representing the FUNGuild or
#' NEMAGuild database, as returned by \code{\link{get_funguild_db}} or
#' \code{\link{get_nemaguild_db}}.
#' If not supplied, the default database will be downloaded.
#'
#' @return A \code{\link[tibble]{tibble}} containing all columns of \code{otu_table},
#' plus relevant columns of information from the FUNGuild or NEMAGuild database.
#' @export
#'
#' @examples
#' # sample input for nematodes
#' sample_nema
#'
#' # nemaguild_testdb is a very small subset of the full database, use only
#' # in this example!
#' nemaguild_assign(sample_nema, db = nemaguild_testdb)
#'
#' # sample input for fungi
#' sample_fungi
#'
#' # fungi_testdb is a very small subset of the full database,
#' # use only iun this example!
#' funguild_assign(sample_fungi, db = funguild_testdb)
funguild_assign <- function (otu_table, db = get_funguild_db()) {
  if (is.character(otu_table)) {
    otu_table <- tibble::tibble(Taxonomy = otu_table)
  }
  assertthat::assert_that(is.data.frame(otu_table) || dplyr::is.tbl(otu_table),
              "Taxonomy" %in% colnames(otu_table))
  otu_table$taxkey <- stringr::str_replace_all(otu_table$Taxonomy, "[_ ;,:]", "@") %>%
    paste0("@")
  all_taxkey <- unique(otu_table$taxkey) %>% na.omit()
  dplyr::select(db, taxonomicLevel, searchkey) %>%
    dplyr::mutate(taxkey = purrr::map(searchkey, stringr::str_subset, string = all_taxkey)) %>%
    tidyr::unnest() %>%
    dplyr::group_by(taxkey) %>%
    dplyr::arrange(dplyr::desc(taxonomicLevel)) %>%
    dplyr::summarize_at("searchkey", dplyr::first) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(otu_table, ., by = "taxkey") %>%
    dplyr::left_join(db, by = "searchkey", suffix = c("", ".funguild")) %>%
    dplyr::select(-taxkey, -searchkey)
}
#' @rdname funguild_assign
#' @export
nemaguild_assign <- function(otu_table, db = get_nemaguild_db()) {
   funguild_assign(otu_table, db)
}

#' Short Tables of Organisms, Used for Testing FUNGuild/NEMAGuild
#'
#' Each of these tables contains the common name (if any), scientific name, and
#' taxonomic classification of a few organisms from their respective groups
#' (e.g., Fungi or Nematoda). They provide an example of proper formatting for
#' input to \code{\link{funguild_assign}} and \code{\link{nemaguild_assign}}.
#'
#' @format A \code{\link[tibble]{tibble}} with columns \code{Common.Name}, \code{Species}, and \code{Taxonomy}
#'
#' @source Taxonomy from \href{https://www.gbif.org/}{Global Biodiversity Inventory Facility} via \code{rgbif::\link[rgbif]{name_backbone}}.
"sample_fungi"

#' @rdname sample_fungi
"sample_nema"
