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
