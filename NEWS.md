# FUNGuildR (development version)

* NEMAGuild is (temporarily?) offline.
* `funguild_assign()` and `get_funguild_db()` now return additional columns
  "guid" and "mbNumber" from the new version of FUNGuild

# FUNGuildR 0.2.0

* Update default FUNGuild URL to use new version of FUNguild database (as
  in `Guilds_v1.1.py`) and correctly parse new database format.
* Added a `tax_col` argument to `funguild_assign`/`nemaguild_assign` to allow
  use of a taxonomy column with a name other than "`Taxonomy`".
* Fixed warning when using tidyr >= 1.0.0
* Added a `NEWS.md` file to track changes to the package.
