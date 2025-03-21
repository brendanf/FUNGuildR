# FUNGuildR 0.3.0

* NEMAGuild is (temporarily?) offline.
* `funguild_assign()` and `get_funguild_db()` now return additional columns
  "guid" and "mbNumber" from the new version of FUNGuild
* `get_funguild_db()` now returns the database as-is, without changing spaces to
  underscores in the species name, or adding the search key. The current
  `funguild_assign()` should still work with old locally cached databases, but
  older versions will not work with new cached databases.
* Species names in the *taxon* column of `funguild_assign()` output now have a
  space instead of an underscore between the genus and species epithets.
* Added function `funguild_query()` to submit queries to the FUNGuild web API.
  It also works with a locally cached database.
* `funguild_assign()` now accepts Sintax ("`k:`", "`p:`"...) or Unite ("`k__`,
  "`p__`", ...) style taxonomy strings.
* `funguild_assign()` now works in many cases when the *Taxonomy* column
  contains only genus or species names. The most complete results will still be 
  achieved when the whole taxonomy string is included.
* Fixed a bug where `funguild_assign()` incorrectly returned order- or
  family-level guild annotations even when genus- or species-level annotations
  were available.

# FUNGuildR 0.2.0

* Update default FUNGuild URL to use new version of FUNguild database (as
  in `Guilds_v1.1.py`) and correctly parse new database format.
* Added a `tax_col` argument to `funguild_assign`/`nemaguild_assign` to allow
  use of a taxonomy column with a name other than "`Taxonomy`".
* Fixed warning when using tidyr >= 1.0.0
* Added a `NEWS.md` file to track changes to the package.
