
<!-- README.md is generated from README.Rmd. Please edit that file -->

# FUNGuildR

This is a simple reimplementation of FUNGuild\_v1.1.py. It queries the
[FUNGuild or NEMAGuild databases](http://www.stbates.org/guilds/app.php)
and assigns trait information based on matching to a taxonomic
classification. It does not include a copy of the FUNGuild or NEMAGuild
databases, because they are continually updated as new information is
submitted, but it does have methods to download them and store them as R
objects to speed up repeated queries or to allow local queries without
internet access.

## Installation

For the moment, `FUNGuildR` can only be installed from GitHub. To
install, be sure you have installed the
[devtools](https://cran.r-project.org/web/packages/devtools/index.html)
package, and then type

``` r
devtools::install_github("brendanf/FUNGuildR")
```

## Usage

The main functions are `funguild_assign()` and `nemaguild_assign()`.
Each of these takes as their first argument a `data.frame`, which should
contain a `character` column named “Taxonomy”. They return a version of
the same `data.frame` (as a `tibble`) with additional columns “taxon”,
“taxonomicLevel”, “trophicMode”, “guild”, “growthForm”, “trait”,
“confidenceRanking”, “notes”, and “citationSource”. That’s it\!

Here’s how it works on a sample database (scroll to see additional
columns):

``` r
sample_fungi
```

| Common.Name     | Species                  | Taxonomy                                                                                                     |
| :-------------- | :----------------------- | :----------------------------------------------------------------------------------------------------------- |
| Button mushroom | Agaricus bisporus        | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Agaricaceae;Agaricus;Agaricus bisporus                         |
| Death Cap       | Amanita phalloides       | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Amanitaceae;Amanita;Amanita phalloides                         |
| Beer Yeast      | Saccharomyces cerevisiae | Fungi;Ascomycota;Saccharomycetes;Saccharomycetales;Saccharomycetaceae;Saccharomyces;Saccharomyces cerevisiae |
| Rhizophagus     | Rhizophagus irregularis  | Fungi;Glomeromycota;Glomeromycetes;Glomerales;Glomeraceae;Rhizophagus;Rhizophagus irregularis                |
| Dry rot         | Serpula lacrymans        | Fungi;Basidiomycota;Agaricomycetes;Boletales;Serpulaceae;Serpula;Serpula lacrymans                           |
| Cryptococcus    | Cryptococcus neoformans  | Fungi;Basidiomycota;Tremellomycetes;Tremellales;Tremellaceae;Cryptococcus;Cryptococcus neoformans            |
| Dung Cannon     | Pilobolus crystallinus   | Fungi;Zygomycota;Mucoromycetes;Mucorales;Pilobolaceae;Pilobolus;Pilobolus crystallinus                       |

``` r

sample_guilds <- funguild_assign(sample_fungi)
sample_guilds
```

| Common.Name     | Species                  | Taxonomy                                                                                                     | taxon                     | taxonomicLevel | trophicMode | guild                  | growthForm                    | trait                                               | confidenceRanking | notes                                                    | citationSource                                                                                                                                                           |
| :-------------- | :----------------------- | :----------------------------------------------------------------------------------------------------------- | :------------------------ | -------------: | :---------- | :--------------------- | :---------------------------- | :-------------------------------------------------- | :---------------- | :------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Button mushroom | Agaricus bisporus        | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Agaricaceae;Agaricus;Agaricus bisporus                         | Agaricus                  |             13 | Saprotroph  | Undefined Saprotroph   | Agaricoid-Gasteroid-Secotioid | NULL                                                | Probable          | NULL                                                     | Tedersoo L, et al. 2014. Science 346:1256688 (<doi:10.1126/science.1256688>)                                                                                             |
| Death Cap       | Amanita phalloides       | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Amanitaceae;Amanita;Amanita phalloides                         | Amanita\_phalloides       |             20 | Symbiotroph | Ectomycorrhizal        | Agaricoid                     | Deadly poisonous; produces the toxin Alpha-amanitin | Probable          | common name - death cap                                  | <http://en.wikipedia.org/wiki/List_of_deadly_fungi>                                                                                                                      |
| Beer Yeast      | Saccharomyces cerevisiae | Fungi;Ascomycota;Saccharomycetes;Saccharomycetales;Saccharomycetaceae;Saccharomyces;Saccharomyces cerevisiae | Saccharomyces\_cerevisiae |             20 | Saprotroph  | Undefined Saprotroph   | Yeast                         | NULL                                                | Probable          | NULL                                                     | James TY, et al. 2006. Nature 443:818-822                                                                                                                                |
| Rhizophagus     | Rhizophagus irregularis  | Fungi;Glomeromycota;Glomeromycetes;Glomerales;Glomeraceae;Rhizophagus;Rhizophagus irregularis                | Rhizophagus               |             13 | Symbiotroph | Arbuscular Mycorrhizal | NULL                          | NULL                                                | Highly Probable   | NULL                                                     | Redecker D, et al. 2013. Mycorrhiza 23:515-531                                                                                                                           |
| Dry rot         | Serpula lacrymans        | Fungi;Basidiomycota;Agaricomycetes;Boletales;Serpulaceae;Serpula;Serpula lacrymans                           | Serpula                   |             13 | Saprotroph  | Wood Saprotroph        | Corticioid                    | Brown Rot                                           | Probable          | NULL                                                     | Tedersoo L, et al. 2014. Science 346:1256688                                                                                                                             |
| Cryptococcus    | Cryptococcus neoformans  | Fungi;Basidiomycota;Tremellomycetes;Tremellales;Tremellaceae;Cryptococcus;Cryptococcus neoformans            | Cryptococcus\_neoformans  |             20 | Pathotroph  | Animal Pathogen        | Yeast                         | NULL                                                | Highly Probable   | Likely opportunistic human pathogen (Irinyi et al. 2015) | Kurtzman CP, et al. (eds.) 2011. The Yeasts, a Taxonomic Study. Fifth Edition. Vols 1-3. Elsevier, San Diego; Irinyi L, et al. 2015. Medical Mycology 53:313-337         |
| Dung Cannon     | Pilobolus crystallinus   | Fungi;Zygomycota;Mucoromycetes;Mucorales;Pilobolaceae;Pilobolus;Pilobolus crystallinus                       | Pilobolus                 |             13 | Saprotroph  | Dung Saprotroph        | NULL                          | NULL                                                | Highly Probable   | NULL                                                     | Bell A. 1983. Dung Fungi: An Illustrated Guide to Coprophilous Fungi in New Zealand. Victoria University Press, Wellington; Tedersoo L, et al. 2014. Science 346:1256688 |

For more information about the meaning of the new columns, see the
FUNGuild manual, available at <https://github.com/UMNFuN/FUNGuild>.

## Import data format

Each value in the Taxonomy column should consist of a comma-, colon-,
underscore\_, or semicolon-delimited list of taxa which the organism on
that row belongs to. You can see examples in the `sample_fungi` data
presented above.

Such taxonomic classifications are frequently arranged from the most
inclusive taxon (e.g., Kingdom) to the most specific (e.g., Species),
but this is not actually required. Not all taxonomic ranks are required;
for each row, the algorithm returns results only for the most specific
taxon which is present in the database.

## Database caching

By default, `funguild_assign()` and `nemaguild_assign()` download the
appropriate database each time they are invoked. In many analysis
pipelines, where guilds need to be assigned only once, this is not a
problem; because the databases are continuously updated, it is good to
use the most current version. However, if you are going to call the
functions many times, or if you plan to assign guilds in a situation
where you have no internet access, you can cache the database(s) locally
using the functions `get_funguild_db()` and `get_nemaguild_db()`. Each
of these returns the relevant database as a `tibble`, which can be
passed as the second argument to `funguild_assign()` or
`nemaguild_assign()`.

``` r
nema <- get_nemaguild_db()

# This isn't necessary for a single query, but it works.
nema_guild <- nemaguild_assign(sample_nema, db = nema)

# It might be more useful in this situation
data_guilds <- lapply(many_datasets, nemaguild_assign, db = nema)

# Or you can save it for later offline use
saveRDS(nema, "nemaguild.rds")

#And then load it again
nema <- loadRDS("nemaguild.rds")
```

This strategy can also be used for reproduceable research, to store the
same version of the database which was used in the original paper.
