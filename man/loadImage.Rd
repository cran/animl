% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generators.R
\name{loadImage}
\alias{loadImage}
\title{Load an image and return the full size image as an image tensor.}
\usage{
loadImage(file, standardize = FALSE)
}
\arguments{
\item{file}{path to a JPEG file}

\item{standardize}{standardize the image, TRUE or FALSE.}
}
\value{
An image tensor.
}
\description{
Load an image and return the full size an image tensor. Internal function to be called by image generator function.
}
