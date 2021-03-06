% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/funguildr.R
\name{get_funguild_db}
\alias{get_funguild_db}
\alias{get_nemaguild_db}
\title{Retrieve the FUNGuild or NEMAGuild database}
\usage{
get_funguild_db(db = "http://www.stbates.org/funguild_db_2.php")

get_nemaguild_db(db = "http://www.stbates.org/nemaguild_db.php")
}
\arguments{
\item{db}{a length 1 character string giving the URL to retrieve the database
from}
}
\value{
a \code{\link[tibble:tibble]{tibble::tibble}} containing the database, which can be passed
to the \code{db} argument of \code{\link[=funguild_assign]{funguild_assign()}} and
\code{\link[=nemaguild_assign]{nemaguild_assign()}}
}
\description{
The two functions are exactly the same, but have different default values
for the URL.
}
\examples{
get_funguild_db()
}
\references{
Nguyen NH, Song Z, Bates ST, Branco S, Tedersoo L, Menke J,
Schilling JS, Kennedy PG. 2016. \emph{FUNGuild: An open annotation tool for
parsing fungal community datasets by ecological guild}. Fungal Ecology
20:241–248.
}
