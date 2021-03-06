% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sca_estimation_and_visualization.R
\name{ggvis_projection}
\alias{ggvis_projection}
\title{Creates ggplot of projections}
\usage{
ggvis_projection(
  sca_output,
  train_alpha = 0.3,
  test_color_power = 1/3,
  test_color_low = "white",
  test_color_high = "red",
  color_n_breaks = 10
)
}
\arguments{
\item{sca_output}{spectral_cluster_process function output (see details)}

\item{train_alpha}{opacity level for black training points}

\item{test_color_power}{power transformation (x^ test_color_power) of 
probability values for test points color}

\item{test_color_low}{lower color for range of colors on test points prob}

\item{test_color_high}{high color for range of colors on test points prob}

\item{color_n_breaks}{integer number of breaks along the color range 
(equally spaced along transformed probability space)}
}
\value{
ggplot scatter plot of training and colored test points
}
\description{
Creates ggplot of projections
}
\details{
ggplot experts are encouraged to use the output of data_projection 
function applied to sca_output instead of this wrapper

\code{sca_output} is a list that, at minimum needs:
\itemize{
\item \code{test_projected} test data in projection space
\item \code{train_projected}training data in projection space
\item \code{test_p_estimate} probability estimates for test data (\eqn{p_i})
\item \code{test_weight} scaled probabilities estimates (by max of probs) for
 test (\eqn{p_i/\max_k p_k})
}
}
