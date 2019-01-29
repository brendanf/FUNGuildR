# FUNGuildR
## Look Up Guild Information for Fungi and Nematodes in R

This is a simple reimplementation of FUNGuild_v1.1.py. It queries
the [FUNGuild or NEMAGuild databases](http://www.stbates.org/guilds/app.php)
and assigns trait information based on matching to a taxonomic
classification. It does not include a copy of the FUNGuild or NEMAGuild
databases, because they are continually updated as new information is
submitted, but it does have methods to download them and store them as R
objects to speed up repeated queries or to allow local queries without
internet access.

## Usage

The main functions are `funguild_assign()` and `nemaguild_assign()`.
Each of these takes as their first argument a `data.frame`, which should contain a `character` column named "Taxonomy".
They return a version of the same `data.frame` (as a `tibble`) with additional columns "trophicMode", "guild", "growthForm", "trait", "confidenceRanking", "notes", and "citationSource".
That's it!

```r
otu_table_guilds <- funguild_assign(otu_table)
```

## Import data format
Each value in the Taxonomy column should consist of a comma-, colon-, underscore_, or semicolon-delimited list of taxa which the organism on that row belongs to.
For instance, for the common cultivated mushroom, _Agaricus bisporus_:

```
Fungi;Basidiomycota;Agaricomycetes;Agaricales;Agaricaceae;Agaricus;Agaricus bisporus
```

Such taxonomic classifications are frequently arranged from the most inclusive taxon (e.g., Kingdom) to the most specific (e.g., Species), but this is not required.
Not all taxonomic ranks are required; the algorithm returns results only for the most specific taxon which is present in the database.

## Database caching

By default, `funguild_assign()` and `nemaguild_assign()` download the appropriate database each time they are invoked.
In many analysis pipelines, where guilds need to be assigned only once, this is not a problem; because the databases are continuously updated, it is good to use the most current version.
However, if you are going to call the functions many times, or if you plan to assign guilds in a situation where you have no internet access, you can cache the database(s) locally using the functions `get_funguild_db()` and `get_nemaguild_db()`.
Each of these returns the relevant database as a `tibble`, which can be passed as the second argument to `funguild_assign()` or `nemaguild_assign()`.

```r
nema <- get_nemaguild_db()

# This isn't necessary for a single query, but it works.
otus_guild <- nemaguild_assign(otus, db = nema)

# It might be more useful in this situation
data_guilds <- lapply(many_datasets, nemaguild_assign, db = nema)

# Or you can save it for later offline use
saveRDS(nema, "nemaguild.rds")

#And then load it again
nema <- loadRDS("nemaguild.rds")
```

This strategy can also be used for reproduceable research, to store the same version of the database which was used in the original paper.
