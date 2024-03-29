% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractBoxes.R
\name{extractBoxesFromMD}
\alias{extractBoxesFromMD}
\title{Extract bounding boxes for a single image and save as new images}
\usage{
extractBoxesFromMD(
  image,
  min_conf = 0,
  buffer = 0,
  return.crops = FALSE,
  save = FALSE,
  resize = NA,
  outdir = "",
  quality = 0.8
)
}
\arguments{
\item{image}{single image, raw MD output format (list)}

\item{min_conf}{Confidence threshold (defaults to 0, not in use)}

\item{buffer}{Adds a buffer to the MD bounding box, defaults to 2px}

\item{return.crops}{Toggle to return list of cropped images, defaults to FALSE}

\item{save}{Toggle to save output cropped, defaults to FALSE}

\item{resize}{Size in pixels to resize cropped images, NA if images are not resized, defaults to NA}

\item{outdir}{Directory in which output cropped images will be saved}

\item{quality}{Compression level of output cropped image, defaults to 0.8}
}
\value{
a flattened data.frame containing crop information
}
\description{
Requires the unflattened raw MD output
}
\details{
A variable crop_rel_path in the image list can be used to change the path where the crops will be stored.

The final output path will be the outdir plus the crop_rel_path.
}
\examples{
\dontrun{
images <- read_exif(imagedir, tags = c("filename","directory"), recursive = TRUE)
crops <- extractBoxesFromMD(images[1, ], return.crops = TRUE, save = TRUE)
}
}
