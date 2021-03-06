% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/decodeImage.R
\name{decode_img_full}
\alias{decode_img_full}
\title{Load image with TF, full size for MD}
\usage{
decode_img_full(image_filepath)
}
\arguments{
\item{image_filepath}{the file path of the image}
}
\description{
Load image with TF, full size for MD
}
\examples{
\dontrun{
  dataset<-tfdatasets::dataset_map_and_batch(dataset,decode_img_full,batch_size)
}
}
