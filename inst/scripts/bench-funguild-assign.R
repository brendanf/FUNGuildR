#!/usr/bin/env Rscript
# Timing comparison for funguild_assign() engines.
# Not run by R CMD check.
#
# Usage:
#   Rscript inst/scripts/bench-funguild-assign.R [db.rds] [n_unique]
#
# db.rds     optional path to a cached FUNGuild database (RDS). If omitted,
#            the database is downloaded with get_funguild_db().
# n_unique   number of unique taxonomy strings to match (default 2000).

args <- commandArgs(trailingOnly = TRUE)
db_path <- if (length(args) >= 1L) args[[1L]] else NULL
n_unique <- if (length(args) >= 2L) as.integer(args[[2L]]) else 2000L

if (!is.null(db_path) && nzchar(db_path)) {
  db <- readRDS(db_path)
} else {
  message("Downloading FUNGuild database...")
  db <- FUNGuildR::get_funguild_db()
}

base_tax <- FUNGuildR::sample_fungi$Taxonomy
# Unique taxonomies stress the matcher; row repeats do not.
otu <- data.frame(
  Taxonomy = paste0(
    rep(base_tax, length.out = n_unique),
    "@uniq",
    seq_len(n_unique)
  ),
  stringsAsFactors = FALSE
)

message(
  "Matching ",
  n_unique,
  " unique taxonomies against ",
  nrow(db),
  " database rows"
)

t_cpp <- system.time(
  FUNGuildR::funguild_assign(otu, db = db, engine = "cpp")
)
t_r <- system.time(
  FUNGuildR::funguild_assign(otu, db = db, engine = "r")
)

print(t_cpp)
print(t_r)
if (requireNamespace("bench", quietly = TRUE)) {
  print(bench::mark(
    cpp = FUNGuildR::funguild_assign(otu, db = db, engine = "cpp"),
    r = FUNGuildR::funguild_assign(otu, db = db, engine = "r"),
    check = FALSE
  ))
}
