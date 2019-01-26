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
      dplyr::select(taxon, taxonomicLevel, trophicMode, guild, growthForm,
             trait, confidenceRanking, notes, citationSource) %>%
      dplyr::mutate(searchkey = paste0("@", stringr::str_replace(taxon, " ", "@"), "@"))
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
#' \code{otu_table} by exact name.  In the case of multiple matches, the lowest
#' (most specific) rank is chosen.  No attempt is made to check or correct the
#' classification in \code{otu_table}.
#'
#' @param otu_table A \link[base]{data.frame} with a \code{character} column named \code{Taxonomy}.
#' Each entry should be a comma-, colon- or semicolon-delimited classification
#' of an organism, from higher-ranked to lower-ranked taxa.
#' For example: \code{"Fungi;Dikarya;Basidiomycota;Agaricomycotina;Agaricomycetes;Agaricaceae;Agaricus;Agaricus bisporus"} (for the common cultivated mushroom).
#' @param db A \link[base]{data.frame} representing the FUNGuild or NEMAGuild database,
#' as returned by \link{get_funguild_db} or \link{get_nemaguild_db}.
#' If not supplied, the default database will be downloaded.
#'
#' @return A \link[tibble]{tibble} containing the original \code{otu_table},
#' plus relevant columns of information from the FUNGuild or NEMAGuild database.
#' @export
#'
#' @examples
#' test_table <- tibble::tribble(~Common.Name, ~Taxonomy,
#'                       "Button mushroom", "Agaricomycetes;Agaricales;Agaricaceae;Agaricus;Agaricus bisporus",
#'                       "Chanterelle", "Agaricomycetes;Cantharellales;Cantharellaceae;Cantharellus;Cantharellus cibarius",
#'                       "Death Cap", "Agaricomycetes;Agaricales;Amanitaceae;Amanita;Amanita phalloides",
#'                       "Beer Yeast", "Saccharomycetes; Saccharomycetales;Saccharomycetaceae;Saccharomyces; Saccharomyces cerevesiae")
#' funguild_assign(test_table)
funguild_assign <- function (otu_table, db = get_funguild_db()) {
  assertthat::assert_that(is.data.frame(otu_table) || tibble::is.tbl(otu_table),
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
