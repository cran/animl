% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/symlink.R
\name{symlinkSpecies}
\alias{symlinkSpecies}
\title{Create SymLink Directories and Sort Classified Images}
\usage{
symlinkSpecies(manifest, linkdir, threshold = 0, outfile = NULL, copy = FALSE)
}
\arguments{
\item{manifest}{DataFrame of classified images}

\item{linkdir}{Destination directory for symlinks}

\item{threshold}{Confidence threshold for determining uncertain predictions, defaults to 0}

\item{outfile}{Results file to save to}

\item{copy}{Toggle to determine copy or hard link, defaults to link}
}
\value{
manifest with added link columns
}
\description{
Create SymLink Directories and Sort Classified Images
}
\examples{
\dontrun{
manifest <- symlinkSpecies(manifest, linkdir)
}
}
