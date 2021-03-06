% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multispecies.R
\name{multispecies}
\alias{multispecies}
\title{Classify images with multiple potential species}
\usage{
multispecies(imagesallanimal, mlpredictions, classes, emptycol)
}
\arguments{
\item{imagesallanimal}{dataframe of MD animal images}

\item{mlpredictions}{classifier predictions for each box}

\item{classes}{list of all possible classes}

\item{emptycol}{integer value of the empty column}
}
\value{
list of images with multiple species, includes number of animals for each class
}
\description{
Classify images with multiple potential species
}
\examples{
\dontrun{
imagesallanimal <- multispecies(imagesallanimal,mlpredictions,classes,17)
}
}
