#' Geenens & Nieto-Reyes functional distance-based depth
#'
#' Calculates a global distance-based depth vector using a distance matrix.
#' Specifically we use Geenens & Nieto-Reyes's global distance-based depth
#' defined as:
#'
#' \eqn{DD(x, \hat{P}) = 1/(n choose 2) * sum_{i!=j} I(d(X_1, X_2) > max(d(X_1,x),
#' d(X_2,x)))}
#'
#' @details
#' This function (renamed as \code{distance_depth_function}) is shared with
#' \pkg{timeternR} on github:
#' \href{https://github.com/skgallagher/timeternR}{timeternR}.
#'
#' @param dist_matrix  a n x n square positive symmetric matrix
#'
#' @return depth vector length n with depth values associated with indices in 
#' dist_matrix
#' @export
#' 
#' @examples 
#' dist_mat <- matrix(c(0,   1, 1.5,
#'                      1,   0, 2,
#'                      1.5, 2, 0   ),
#'                    nrow = 3,
#'                    byrow = TRUE)
#'
#' dd_vec <- depth_function(dist_mat) # c(1,0,0)
depth_function <- function(dist_matrix){

  if (nrow(dist_matrix) != ncol(dist_matrix) | 
     any(t(dist_matrix) != dist_matrix) | 
     any(dist_matrix < 0)) {
    stop("your dist_mat is not a positive symmetric square matrix")
  }
  
  N <- nrow(dist_matrix)
  N_step <- as.integer(N/10)
  
  depth <- rep(0,N)
  
  for (obs_index in 1:N) {
    sub_matrix <- dist_matrix[-obs_index,-obs_index]
    
    obs_column <- dist_matrix[-obs_index,obs_index]
    obs_row    <- dist_matrix[obs_index,-obs_index]
    
    obs_column_matrix <- matrix(rep(obs_column, N - 1), nrow = N - 1)
    obs_row_matrix    <- matrix(rep(obs_row, N - 1), nrow = N - 1, byrow = T)
        
    obs_combo_array <- array(0, dim = c(N - 1, N - 1, 2))
    obs_combo_array[,,1] <- matrix(rep(obs_column, N - 1), nrow = N - 1)
    obs_combo_array[,,2] <- matrix(rep(obs_row, N - 1), nrow = N - 1, byrow = T)
    
    max_matrix <- sapply(1:(N - 1), function(row_i) {
      sapply(1:(N - 1), function(col_i) {
        max(obs_combo_array[row_i, col_i, 1:2])
      })
      }) %>% t
    
    depth[obs_index] <- mean((sub_matrix > max_matrix)[
      row(sub_matrix)!=col(sub_matrix)
      #^ignoring the diagonal values
      ])
  }
  return(depth)
}


#' Create a data frame of points in selected curves
#'
#' @param data_list list of hurricanes
#' @param desired_index which hurricanes to be included
#' @param verbose if progress is to be reported in creation of data frame
#'
#' @return data frame with points in desired curves
selected_paths_to_df <- function(data_list, desired_index = NULL, 
                                 verbose = TRUE) {
  if (is.null(desired_index)) {
    desired_index = 1:length(data_list)
  }
  
  if (verbose) {
    n_desired = length(desired_index)
    pb <- progress::progress_bar$new(
      format = "Convert List to Data Frame [:bar] :percent eta: :eta",
      total = n_desired, clear = FALSE, width = 51)
  }

  data_list <- lapply(data_list, as.data.frame)
  df_out <- data_list[[1]][1,] %>% dplyr::mutate(curve = 0)
  
  for (good_curve_idx in desired_index) {
    df_out <- rbind(df_out, 
                    data_list[[good_curve_idx]] %>%
                      dplyr::mutate(curve = good_curve_idx))
    if (verbose) {
      pb$tick()
    }
  }
  
  df_out <- df_out[-1,]
  
  return(df_out)
}




#' Get deepest curves' points in a data frame
#'
#' @details This function (renamed as \code{ depth_curves_to_points.list}) is
#' shared with \pkg{timeternR} on github:
#' \href{https://github.com/skgallagher/timeternR}{timeternR}.
#'
#' @param data_list list of hurricanes
#' @param alpha for prediction band (related to depth). Takes value in (0, 1.0), 
#'        for a 95\% PB, set alpha to .05.
#' @param dist_mat distance matrix (otherwise is calculated)
#' @param verbose if the distance matrix is verbose
#' @param position only needed if created 13 point reduction 
#' @param ... other parameters in distance calculation through 
#' \code{\link{distMatrixPath_innersq}}
#' @param depth_vector vector of depth values (otherwise calculated)
#'
#' @return data frame with points in desired curves
#' @export
depth_curves_to_points <- function(data_list, alpha, dist_mat = NULL, 
                                   position = 1:2,
                                   depth_vector = NULL,
                                   verbose = FALSE, ...){
  if (is.null(depth_vector)) {
    
    if (is.null(dist_mat)) {
      # distance matrix ----------------
      dflist_13pointsreduction = thirteen_points_listable(data_list, 
                                                        position = position,
                                                        verbose = verbose)
      
      dist_mat = distMatrixPath_innersq(dflist_13pointsreduction, 
                                        verbose = verbose, ...)
    }
    
    # depth approach ---------------
    depth_vector <- depth_function(dist_mat)
  }
  
  deep_idx <- which(depth_vector > stats::quantile(depth_vector, probs = alpha))
  
  data_deep_df <- selected_paths_to_df(data_list, deep_idx, verbose = verbose)
  data_deep_points <- data_deep_df[, -which(names(data_deep_df) == "curve")]
  
  return(data_deep_points)
}



