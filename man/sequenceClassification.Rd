% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sequenceClassification.R
\name{sequenceClassification}
\alias{sequenceClassification}
\title{Leverage sequences to classify images}
\usage{
sequenceClassification(
  animals,
  empty = NULL,
  predictions,
  classes,
  emptyclass = "",
  stationcolumn,
  sortcolumns = NULL,
  maxdiff = 60
)
}
\arguments{
\item{animals}{sub-selection of all images that contain MD animals}

\item{empty}{optional, data frame non-animal images (empty, human and vehicle) that will be merged back with animal imagages}

\item{predictions}{data frame of prediction probabilities from the classifySpecies function}

\item{classes}{a vector or species corresponding to the columns of 'predictions'}

\item{emptyclass}{a string indicating the class that should be considered 'Empty'}

\item{stationcolumn}{a column in the animals and empty data frame that indicates the camera or camera station}

\item{sortcolumns}{optional sort order. The default is 'stationcolumnumn' and DateTime.}

\item{maxdiff}{maximum difference between images in seconds to be included in a sequence, defaults to 60}
}
\value{
data frame with predictions and confidence values for animals and empty images
}
\description{
This function applies image classifications at a sequence level by leveraging
information from multiple images. A sequence is defined as all images at the same
camera/station where the time between consecutive images is <=maxdiff. This can improve
classification accuracy, but assumes that only one species is present in each sequence.
If you regularly expect multiple species to occur in an image or sequence don't use this function.
}
\details{
This function retains "Empty" classification even if other images within the
sequence are predicted to contain animals.
Classification confidence is weighted by MD confidence.
}
\examples{
\dontrun{
predictions <-classifyCropsSpecies(images,modelfile,resize=456)
animals <- allframes[allframes$max_detection_category==1,]
empty <- setEmpty(allframes)
animals <- sequenceClassification(animals, empty, predictions, classes,
                                  emptyclass = "Empty",
                                  stationcolumnumn="StationID", maxdiff=60)
}
}
