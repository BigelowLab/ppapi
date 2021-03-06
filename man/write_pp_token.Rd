% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{write_pp_token}
\alias{write_pp_token}
\title{Write a token to the user configuration path}
\usage{
write_pp_token(x, path = rappdirs::user_config_dir("ppapi"), overwrite = FALSE)
}
\arguments{
\item{x}{character, the token}

\item{path}{character, the user configuration directory}

\item{overwrite}{logical, if TRUE allow existing tokens to be overwritten}
}
\value{
the token
}
\description{
Write a token to the user configuration path
}
