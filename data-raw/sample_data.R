# subsample of the nemaguild database
nemaguild_testdb <- get_nemaguild_db() %>%
   dplyr::filter(
      stringr::str_detect(taxon,
                          paste0("(Caenorhabditis|",
                                 "Trichinella|",
                                 "Necator|",
                                 "Xiphinema|",
                                 "Turbatrix)")))
usethis::use_data(nemaguild_testdb, overwrite = TRUE)

# subsample of the funguild database
funguild_testdb <- get_funguild_db() %>%
   dplyr::filter(stringr::str_detect(taxon,
                                     paste0("(Agaricus|",
                                     "Amanita|",
                                     "Saccharomyces|",
                                     "Rhizophagus|",
                                     "Serpula|",
                                     "Cryptococcus|",
                                     "Pilobolus)")))
usethis::use_data(funguild_testdb, overwrite = TRUE)

sample_fungi <-
tibble::tribble(~Common.Name, ~species,
                "Button mushroom", "Agaricus bisporus",
                "Death Cap", "Amanita phalloides",
                "Beer Yeast", "Saccharomyces cerevisiae",
                "Rhizophagus", "Rhizophagus irregularis",
                "Dry rot", "Serpula lacrymans",
                "Cryptococcus", "Cryptococcus neoformans",
                "Dung Cannon", "Pilobolus crystallinus") %>%
   dplyr::left_join(purrr::map_dfr(.$species,
                                   rgbif::name_backbone,
                                   rank = "SPECIES"),
                    by = "species") %>%
   dplyr::mutate(Taxonomy = paste(kingdom, phylum, class, order, family, genus, species, sep = ";")) %>%
   dplyr::select(Common.Name, Species = species, Taxonomy)
usethis::use_data(sample_fungi, overwrite = TRUE)

sample_nema <-
   tibble::tribble(~Common.Name, ~species,
                   "C. elegans", "Caenorhabditis elegans",
                   "Trichinella", "Trichinella spiralis",
                   "Hookworm", "Necator americanus",
                   "American dagger nematode", "Xiphinema americanum",
                   "Vinegar eel", "Turbatrix aceti") %>%
   dplyr::left_join(purrr::map_dfr(.$species,
                                   rgbif::name_backbone,
                                   rank = "SPECIES"),
                    by = "species") %>%
   dplyr::mutate(Taxonomy = paste(kingdom, phylum, class, order, family, genus, species, sep = ";")) %>%
   dplyr::select(Common.Name, Species = species, Taxonomy)
usethis::use_data(sample_nema, overwrite = TRUE)
