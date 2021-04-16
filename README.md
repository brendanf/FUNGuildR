
<!-- README.md is generated from README.Rmd. Please edit that file -->

# FUNGuildR

<!-- badges: start -->

[![R-CMD-check](https://github.com/brendanf/FUNGuildR/workflows/R-CMD-check/badge.svg)](https://github.com/brendanf/FUNGuildR/actions)
[![Codecov test
coverage](https://codecov.io/gh/brendanf/FUNGuildR/branch/master/graph/badge.svg)](https://codecov.io/gh/brendanf/FUNGuildR?branch=master)
<!-- badges: end -->

`FUNGuildR` is a tool for assigning trait information based on matching
to a taxonomic classification, using the [FUNGuild
database](http://www.funguild.org). In normal use, the database is
queried for each use, because FUNGuild are continually updated as new
information is submitted. However, `FUNGuildR` also includes functions
to download the database and store it as an R object to speed up
repeated queries, make queries reproducible over time, and allow local
queries without internet access.

## Installation

For the moment, `FUNGuildR` can only be installed from GitHub. To
install, be sure you have installed the
[devtools](https://cran.r-project.org/web/packages/devtools/index.html)
package, and then type:

``` r
devtools::install_github("brendanf/FUNGuildR")
```

## Usage

The main functions is `funguild_assign()`. It takes as its only required
argument a `data.frame`, which should contain a `character` column named
“Taxonomy”. It returns a version of the same `data.frame` (as a
`tibble`) with additional columns:

**taxon**: The name of the matched taxon.  
**guid**: [Globally Unique Identifier](http://guid.one/guid) for the
database record.  
**mbNumber**: The [MycoBank](https://www.mycobank.org) number of the
taxon.  
**taxonomicLevel**: A numeric representation of the taxonomic rank;
higher numbers are lower ranks.  
**trophicMode**: A very general overview of how the organism gets its
nutrition; one or more of *Saprotroph*, *Pathotroph*, and
*Symbiotroph*.  
**guild**: One or more narrower categories for how the organism gets its
nutrition.  
**confidenceRanking**: The confidence level of the guild assignment;
*Possible*, *Probable*, or *Highly Probable*.  
**growthForm**: The general growth morphology of the organism (or its
fruiting body). Multiple values may be given.  
**trait**: Additional traits about the organism, such as wood decay type
or toxicity.  
**note**: Additional notes about the entry.  
**citationSource**: Citation(s) for the information about the taxon.

That’s it\!

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

| Common.Name     | Species                  | Taxonomy                                                                                                     | taxon                    | guid                                 | mbNumber | taxonomicLevel | trophicMode                       | guild                                                                                                                                  | confidenceRanking | growthForm                                      | trait     | notes                                                                                                                                                                           | citationSource                                                                                                                                                                                                                                 |
| :-------------- | :----------------------- | :----------------------------------------------------------------------------------------------------------- | :----------------------- | :----------------------------------- | :------- | :------------- | :-------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------- | :---------------- | :---------------------------------------------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Button mushroom | Agaricus bisporus        | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Agaricaceae;Agaricus;Agaricus bisporus                         | Agaricaceae              | 1CB1CCAB-36B9-11D5-9548-00D0592D548C | 80434    | 9              | Saprotroph                        | Undefined Saprotroph                                                                                                                   | Probable          | Agaricoid-Gasteroid-Secotioid                   | NULL      | Primarily saprobes in grassland and woodland situations (Cannon & Kirk 2007)                                                                                                    | Cannon PF, Kirk PM. 2007. Fungal Families of the World. CAB International, Cambridge (ISBN: 978-0851998275)                                                                                                                                    |
| Death Cap       | Amanita phalloides       | Fungi;Basidiomycota;Agaricomycetes;Agaricales;Amanitaceae;Amanita;Amanita phalloides                         | Agaricales               | 715D162F-5F0E-40C8-A7DC-79D488D3F937 | 90508    | 7              | Pathotroph-Saprotroph-Symbiotroph | Bryophyte Parasite-Dung Saprotroph-Ectomycorrhizal-Fungal Parasite-Leaf Saprotroph-Plant Parasite-Undefined Saprotroph-Wood Saprotroph | Possible          | Agaricoid-Gasteroid-Microfungus-Secotioid-Yeast | NULL      | Mushrooms and toadstools, Gill fungi, Agarics… lignicolous, sometimes muscicolous or fungicolous, saprobic, mycorrhizal, rarely parasitic on plants or fungi (Kirk et al. 2008) | Kirk PM et al. 2008. Dictionary of the Fungi. Tenth Edition. CAB International, Wallingford (ISBN: 978-0851998268)                                                                                                                             |
| Beer Yeast      | Saccharomyces cerevisiae | Fungi;Ascomycota;Saccharomycetes;Saccharomycetales;Saccharomycetaceae;Saccharomyces;Saccharomyces cerevisiae | Saccharomyces cerevisiae | C140119E-2E48-43E7-A77A-3C749D931D94 | 492348   | 20             | Saprotroph                        | Undefined Saprotroph                                                                                                                   | Probable          | Yeast                                           | NULL      | NULL                                                                                                                                                                            | James TY, et al. 2006. Nature 443:818-822 ((<https://doi.org/10.1038/nature05110>))                                                                                                                                                            |
| Rhizophagus     | Rhizophagus irregularis  | Fungi;Glomeromycota;Glomeromycetes;Glomerales;Glomeraceae;Rhizophagus;Rhizophagus irregularis                | Glomeraceae              | 1CB1CD2A-36B9-11D5-9548-00D0592D548C | 82026    | 9              | Symbiotroph                       | Arbuscular Mycorrhizal                                                                                                                 | Highly Probable   | Microfungus                                     | NULL      | NULL                                                                                                                                                                            | Redecker D, et al. 2013. Mycorrhiza 23:515-531 ((<https://doi.org/10.1007/s00572-013-0486-y>))                                                                                                                                                 |
| Dry rot         | Serpula lacrymans        | Fungi;Basidiomycota;Agaricomycetes;Boletales;Serpulaceae;Serpula;Serpula lacrymans                           | Serpula                  | 1CB1A2A9-36B9-11D5-9548-00D0592D548C | 18541    | 13             | Saprotroph                        | Wood Saprotroph                                                                                                                        | Probable          | Corticioid                                      | Brown Rot | NULL                                                                                                                                                                            | Tedersoo L, et al. 2014. Science 346:e1256688 ((<https://doi.org/10.1126/science.1256688>))                                                                                                                                                    |
| Cryptococcus    | Cryptococcus neoformans  | Fungi;Basidiomycota;Tremellomycetes;Tremellales;Tremellaceae;Cryptococcus;Cryptococcus neoformans            | Cryptococcus neoformans  | 1CB1BA14-36B9-11D5-9548-00D0592D548C | 119294   | 20             | Pathotroph                        | Animal Pathogen                                                                                                                        | Highly Probable   | Dimorphic Yeast                                 | NULL      | Likely opportunistic human pathogen (Irinyi et al. 2015)                                                                                                                        | Kurtzman CP, et al. (eds.) 2011. The Yeasts, a Taxonomic Study. Fifth Edition. Vols 1-3. Elsevier, San Diego (ISBN: 9780444521491); Irinyi L, et al. 2015. Medical Mycology 53:313-337 ((<https://doi.org/10.1093/mmy/myv008>))                |
| Dung Cannon     | Pilobolus crystallinus   | Fungi;Zygomycota;Mucoromycetes;Mucorales;Pilobolaceae;Pilobolus;Pilobolus crystallinus                       | Pilobolus                | 1CB1CA1E-36B9-11D5-9548-00D0592D548C | 20420    | 13             | Saprotroph                        | Dung Saprotroph                                                                                                                        | Highly Probable   | NULL                                            | NULL      | NULL                                                                                                                                                                            | Bell A. 1983. Dung Fungi: An Illustrated Guide to Coprophilous Fungi in New Zealand. Victoria University Press, Wellington (ISBN: 978-0864730015); Tedersoo L, et al. 2014. Science 346:e1256688 ((<https://doi.org/10.1126/science.1256688>)) |

For more information about the meaning of the new columns, see the
[FUNGuild
manual](https://github.com/UMNFuN/FUNGuild/blob/master/FUNGuild_Manual.pdf).

## Input data format

Each value in the *Taxonomy* column of the input `data.frame` should
consist of a comma-, colon-, underscore-, or semicolon-delimited list of
taxa which the organism on that row belongs to. You can see examples in
the `sample_fungi` data presented above.

Such taxonomic classifications are frequently arranged from the most
inclusive taxon (e.g., Kingdom) to the least inclusive taxon (e.g.,
Species), but this is not actually required for FUNGuild. Not all
taxonomic ranks are required; for each row, the algorithm returns
results only for the least inclusive taxon which is present in the
database.

## Database caching

By default, `funguild_assign()` downloads the FUNGuild database each
time they are invoked. In many analysis workflows, where guilds need to
be assigned only once, this is not a problem; because the databases are
continuously updated, it is good to use the most current version.
However, if you are going to call the functions many times, or if you
plan to assign guilds in a situation where you have no internet access,
you can cache the database(s) locally using the functions
`get_funguild_db()`. This returns the database as a `tibble`, which can
be passed as a second argument to `funguild_assign()`.

``` r
fung <- get_funguild_db()

# This isn't necessary for a single query, but it works.
fung_guilds <- funguild_assign(sample_fungi, db = fung)

# It might be more useful in this situation
data_guilds <- lapply(many_datasets, funguild_assign, db = fung)

# Or you can save it for later offline use
saveRDS(fung, "funguild.rds")

#And then load it again
fung <- loadRDS("funguild.rds")
```

This strategy can also be used for reproduceable research, to store the
same version of the database which was used in the original analysis.

## NEMAGuild

As of April 2021, the NEMAGuild database is temporarily offline.
However, `FUNGuildR` has functions `nemaguild_assign()` and
`get_nemaguild_db()` to access it in exactly the same ways as the
FUNGuild database. These functions will not work for the time being
(unless you already have a cached copy of NEMAGuild\!) but they should
work again when NEMAGuild is back online. database.
