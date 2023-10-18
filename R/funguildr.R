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
#' @importFrom magrittr "%<>%"
#' @importFrom stats na.omit
#' @importFrom dplyr .data
NULL

#' Retrieve the FUNGuild or NEMAGuild database
#'
#' The two functions are exactly the same, but have different default values
#' for the URL.
#'
#' @param db a length 1 character string giving the URL to retrieve the database
#'     from
#'
#' @return a [`tibble::tibble`] containing the database, which can be passed
#'     to the `db` argument of [funguild_assign()] and
#'     [nemaguild_assign()]
#' @export
#'
#' @examples
#' get_funguild_db()
#' @references Nguyen NH, Song Z, Bates ST, Branco S, Tedersoo L, Menke J,
#' Schilling JS, Kennedy PG. 2016. *FUNGuild: An open annotation tool for
#' parsing fungal community datasets by ecological guild*. Fungal Ecology
#' 20:241–248.
get_funguild_db <- function(db = 'http://www.stbates.org/funguild_db_2.php'){
  taxon <- NULL # pass R CMD check
    httr::GET(url = db) %>%
      httr::content(as = "text") %>%
      stringr::str_split("\n") %>%
      unlist %>%
      magrittr::extract(7) %>%
      stringr::str_replace("^\\[", "") %>%
      stringr::str_replace("]</body>$", "") %>%
      stringr::str_replace_all("\\} ?, ?\\{", "} \n {") %>%
      stringr::str_split("\n") %>%
      unlist %>%
      purrr::map_dfr(
        function(record) {
          current_record <- jsonlite::fromJSON(record)
          if (!is.null(current_record[["TrophicMode"]])) {
            current_record$trophicMode <- current_record$TrophicMode
          }
          if (!is.null(current_record[["growthMorphology"]])) {
            current_record$growthForm <- current_record$growthMorphology
          }
          purrr::flatten(current_record)
        }
      ) %>%
      dplyr::select("taxon", "guid", "mbNumber", "taxonomicLevel", "trophicMode",
                    "guild", "confidenceRanking", "growthForm", "trait", "notes",
                    "citationSource")
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
#' `otu_table` by exact name.
#' In the case of multiple matches, the lowest (most specific) rank is chosen.
#' No attempt is made to check or correct the classification in
#' `otu_table$Taxonomy`.
#'
#' @param otu_table A `data.frame` with a `character`
#' column named "`Taxonomy`" (or another name as specified in
#' `tax_col`), as well as any other columns.
#' Each entry in "`otu_table$Taxonomy`" should be a comma-, colon-,
#' underscore-, or semicolon-delimited classification of an organism.
#' Rank indicators as given by Sintax ("`k:`", "`p:`"...) or Unite ("`k__`,
#' "`p__`", ...) are also allowed.
#' See [`sample_fungi`] and [`sample_nema`] for examples.
#' A `character` vector, representing only the taxonomic classification,
#' is also accepted.
#' @param tax_col A `character` string, optionally giving an alternate
#' column name in `otu_table` to use instead of `otu_table$Taxonomy`.
#'
#' @param db A `data.frame` representing the FUNGuild or
#' NEMAGuild database, as returned by [get_funguild_db()] or
#' [get_nemaguild_db()].
#' If not supplied, the default database will be downloaded.
#'
#' @return A [`tibble::tibble`] containing all columns of
#' `otu_table`, plus relevant columns of information from the FUNGuild or
#' NEMAGuild database.
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
#' # use only in this example!
#' funguild_assign(sample_fungi, db = funguild_testdb)
#' @references Nguyen NH, Song Z, Bates ST, Branco S, Tedersoo L, Menke J,
#' Schilling JS, Kennedy PG. 2016. *FUNGuild: An open annotation tool for
#' parsing fungal community datasets by ecological guild*. Fungal Ecology
#' 20:241–248.
funguild_assign <- function(otu_table, db = get_funguild_db(),
                            tax_col = "Taxonomy") {
  if (is.character(otu_table)) {
    otu_table <- tibble::tibble(otu_table)
    names(otu_table) <- tax_col
  }
  assertthat::assert_that(is.data.frame(otu_table),
                          tax_col %in% colnames(otu_table))
  otu_table$taxkey <- make_taxkey(otu_table[[tax_col]])
  all_taxkey <- unique(otu_table$taxkey) %>% na.omit()
  `.` <- taxon <- taxkey <- searchkey <- taxonomicLevel <- NULL # to pass R CMD check
  db <- dplyr::mutate(
    db,
    searchkey = paste0("@", stringr::str_replace(taxon, "[ _]", "@"), "@")
  )
  dplyr::select(db, taxonomicLevel, searchkey) %>%
    dplyr::mutate(
      taxkey = purrr::map(searchkey, stringr::str_subset, string = all_taxkey)
    ) %>%
    tidyr::unnest(cols = taxkey) %>%
    dplyr::group_by(taxkey) %>%
    dplyr::arrange(dplyr::desc(taxonomicLevel)) %>%
    dplyr::summarize_at("searchkey", dplyr::first) %>%
    dplyr::ungroup() %>%
    dplyr::mutate_all(as.character) %>%
    dplyr::left_join(otu_table, ., by = "taxkey") %>%
    dplyr::left_join(db, by = "searchkey", suffix = c("", ".funguild")) %>%
    dplyr::select(-taxkey, -searchkey)
}
#' @rdname funguild_assign
#' @export
nemaguild_assign <- function(otu_table, db = get_nemaguild_db(),
                             tax_col = "Taxonomy") {
  funguild_assign(otu_table, db, tax_col)
}

#' Return entries in the FUNGuild database which match search terms
#'
#' @param text A `character` string giving the text to search for. The "`%`" and
#'     "`*`" characters can be used as wildcards.
#' @param field A `character` string giving the field of the database to search
#'     for the query `text`. Should be one of `c("taxon", "guid", "mbNumber",
#'     "trophicMode", "guild", "growthForm", "trait")`.
#' @param db Either a `character` string giving the base URL of the FUNGuild
#'     web API, or a `data.frame` containing a cached copy of the database,
#'     as returned by [get_funguild_db()].
#'
#' @return A [`tibble::tibble`] containing all the entried from the database
#'     which match the query.
#' @export
#'
#' @examples
#'
#' funguild_query("Symbiotroph", "trophicMode", funguild_testdb)
#' @references Nguyen NH, Song Z, Bates ST, Branco S, Tedersoo L, Menke J,
#' Schilling JS, Kennedy PG. 2016. *FUNGuild: An open annotation tool for
#' parsing fungal community datasets by ecological guild*. Fungal Ecology
#' 20:241–248.
funguild_query <- function(
  text,
  field = c("taxon", "guid", "mbNumber", "trophicMode", "guild", "growthForm",
            "trait"),
  db = "https://mycoportal.org/funguild/services/api/db_return.php"
) {
  assertthat::assert_that(assertthat::is.string(text))
  field <- match.arg(field)
  if (is.data.frame(db)) return(funguild_query_local(text, field, db))
  assertthat::assert_that(assertthat::is.string(db))
  # if (file.exists(db)) return(funguild_query_file(text, field, db))
  httr::GET(db, query = list(qField = field, qText = text)) %>%
    check_is_json() %>%
    httr::content() %>%
    purrr::map_dfr(tibble::as_tibble)
}

funguild_query_local <- function(text, field, db) {
  # function isn't exported, so arguments have already been checked

  # the query accepts * and % as wildcards. convert to regex equivalent
  text <- gsub("*", ".*", text, fixed = TRUE)
  text <- gsub("%", ".*", text, fixed = TRUE)
  # anchor beginning and end of query
  text <- sprintf("^%s$", text)
  dplyr::filter(db, grepl(text, .data[[field]], ignore.case = TRUE))
}

#' Short Tables of Organisms, Used for Testing FUNGuild/NEMAGuild
#'
#' Each of these tables contains the common name (if any), scientific name, and
#' taxonomic classification of a few organisms from their respective groups
#' (e.g., Fungi or Nematoda). They provide an example of proper formatting for
#' input to [funguild_assign()] and [nemaguild_assign()].
#'
#' @format A [`tibble::tibble`] with columns `Common.Name`, `Species`, and `Taxonomy`
#'
#' @source Taxonomy from [Global Biodiversity Inventory Facility](https://www.gbif.org/) via [rgbif::name_backbone()].
"sample_fungi"


#' @rdname sample_fungi
"sample_nema"

#' Short Extracts of the FUNGuild and NEMAGuild Databases
#'
#' These are used in the examples for [funguild_assign()]/[nemaguild_assign()];
#' They are incomplete and should not be used for any purpose beyond testing.
#'
#' @source FUNGuild and NEMAGuild databases, <http://www.stbates.org>.
#' @references Nguyen NH, Song Z, Bates ST, Branco S, Tedersoo L, Menke J,
#' Schilling JS, Kennedy PG. 2016. *FUNGuild: An open annotation tool for
#' parsing fungal community datasets by ecological guild*. Fungal Ecology
#' 20:241–248.
"funguild_testdb"
#' @rdname funguild_testdb
"nemaguild_testdb"
