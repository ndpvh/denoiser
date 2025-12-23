#' Add independent error to data
#' 
#' Error is generated through a multivariate normal distribution with a
#' \code{mean} and \code{covariance} that are specified by the user. Primary 
#' assumption of this model is that the errors are independent over time, 
#' which stands in contrast to the \code{\link[denoiser]{temporal()}} model.
#' 
#' @param data A data.frame containing the data on which to base the parameters
#' of the constant velocity model. This function assumes that this data.frame
#' contains the columns \code{"time"}, \code{"x"}, and \code{"y"} containing 
#' the time at which the observed position (x, y) was measured respectively. 
#' @param mean Numeric vector with 1 or 2 values containing the mean of the 
#' error process. If only 1 number is provided, then this value will be assumed
#' to represent the mean for both the x- and y-dimensions. Defaults to 
#' \code{c(0, 0)}, representing no bias in the system.
#' @param covariance Numeric matrix of dimensionality \eqn{2 \times 2}, 
#' having the variances of the errors for x and y on the diagonal and the 
#' covariance of the errors on the off-diagonal. Defaults to having the variances
#' of the x- and y-dimension being equal to \code{0.031^2} and \code{0.027^2}
#' respectively, and the covariance being equal to \code{0.02}. These values 
#' represent the means of the respective variances and covariances found 
#' across the four days of the calibration study that informed this project.
#' 
#' @return A \code{data.frame} in which the \code{"x"} and \code{"y"} columns 
#' have additional noise in them.
#' 
#' @examples 
#' # Generate data for illustration purposes. Movement in circular motion at a
#' # pace of 1.27m/s with some added noise of SD = 10cm.
#' angles <- seq(0, 4 * pi, length.out = 100)
#' coordinates <- 10 * cbind(cos(angles), sin(angles))
#' 
#' data <- data.frame(
#'   x = coordinates[, 1],
#'   y = coordinates[, 2],
#'   time = 1:100
#' )
#' 
#' # Add independent noise to these data with an error variance of 0.01 in each
#' # dimension
#' independent(
#'   data,
#'   mean = c(0, 0),
#'   covariance = diag(2) * 0.01
#' ) |>
#'   head()
#' 
#' @seealso 
#' \code{\link[denoiser]{noiser()}}
#' \code{\link[denoiser]{temporal()}}
#' 
#' @export
independent <- function(data, 
                        mean = c(0, 0), 
                        covariance = c(0.031^2, 0.02, 0.02, 0.027^2) |>
                            matrix(nrow = 2, ncol = 2)) {

    # Perform a check of the length of the means
    if(length(mean) == 1) {
        mean <- rep(mean, 2)
    } else if(length(mean) > 2) {
        mean <- mean[1:2]
    }

    # Perform a check of the covariances. If not a matrix, then we cannot 
    # proceed
    if(!is.matrix(covariance)) {
        stop("Provided covariance is not a matrix. Cannot add multivariate noise.")
    }

    # Check whether the dimensionality of the covariances is allright
    if(dim(covariance) != c(2, 2)) {
        stop(
            paste(
                "Provided covariance matrix does not have the right dimensionality.",
                "A", 
                dim(covariance)[1], 
                "x", 
                dim(covariance)[2],
                "matrix is provided instead of the required 2 x 2 matrix."
            )
        )
    }
    
    # Use the multivariate normal distribution to generate the residuals, 
    # representing measurement error
    residuals <- MASS::mvrnorm(
        nrow(data),
        mu = mean, 
        Sigma = covariance
    )

    # Add the measurement error to the data and return
    data[, c("x", "y")] <- data[, c("x", "y")] + residuals

    return(data)
}

#' Add temporal error to data
#' 
#' Error is generated through a vector autoregressive model with defining
#' parameters \code{intercept}, \code{transition}, and \code{covariance} being
#' specified by the user. 
#' 
#' @param data A data.frame containing the data on which to base the parameters
#' of the constant velocity model. This function assumes that this data.frame
#' contains the columns \code{"time"}, \code{"x"}, and \code{"y"} containing 
#' the time at which the observed position (x, y) was measured respectively. 
#' @param intercept Numeric vector with 1 or 2 values containing the intercept 
#' of the vector autoregressive model.If only 1 number is provided, then this 
#' value will be assumed to represent the intercept for both the x- and y-
#' dimensions. Defaults to \code{c(0, 0)}, representing no bias in the system.
#' @param transition Numeric matrix of dimensionality \eqn{2 \times 2} having 
#' the autoregressive effects on the diagonal and crossregressive effects on the
#' off-diagonal. Defaults to the autoregressive effects being equal to 
#' \code{0.925} and \code{0.87} for the x- and y-dimension respectively, and 
#' the cross-regressive effects being equal to \code{0.085} in a symmetric way.
#' These values represent the means of these parameters as found across the 
#' four days of the calibration study that informed this project.
#' @param covariance Numeric matrix of dimensionality \eqn{2 \times 2}, 
#' having the variances of the errors for x and y on the diagonal and the 
#' covariance of the errors on the off-diagonal. Defaults to having the variances
#' of the x- and y-dimension being equal to \code{0.031^2} and \code{0.027^2}
#' respectively, and the covariance being equal to \code{0.02}. These values 
#' represent the means of the respective variances and covariances found 
#' across the four days of the calibration study that informed this project.
#' @param sampling_rate Numeric denoting the sampling rate in Hz. Is used to 
#' scale the transition matrix according to the actual sampling rate. Defaults to 
#' \code{6.13}, which is the mean sampling rate for the data obtained across the
#' four days of the calibration study that informed this project. If you change
#' the \code{transition} argument, it is recommended to ignore this argument.
#' 
#' @return A \code{data.frame} in which the \code{"x"} and \code{"y"} columns 
#' have additional noise in them.
#' 
#' @examples 
#' # Generate data for illustration purposes. Movement in circular motion at a
#' # pace of 1.27m/s with some added noise of SD = 10cm.
#' angles <- seq(0, 4 * pi, length.out = 100)
#' coordinates <- 10 * cbind(cos(angles), sin(angles))
#' 
#' data <- data.frame(
#'   x = coordinates[, 1],
#'   y = coordinates[, 2],
#'   time = 1:100
#' )
#' 
#' # Add independent noise to these data with an error variance of 0.01 in each
#' # dimension and a transition matrix containing autoregressive effects of 0.15
#' temporal(
#'   data,
#'   intercept = c(0, 0),
#'   transition = diag(2) * 0.15,
#'   covariance = diag(2) * 0.01
#' ) |>
#'   head()
#' 
#' @seealso 
#' \code{\link[denoiser]{noiser()}}
#' \code{\link[denoiser]{independent()}}
#' 
#' @export
temporal <- function(data, 
                    intercept = c(0, 0), 
                    transition = c(0.925, 0.085, 0.085, 0.87) |>
                        matrix(nrow = 2, ncol = 2),
                    covariance = c(0.031^2, 0.02, 0.02, 0.027^2) |>
                        matrix(nrow = 2, ncol = 2),
                    sampling_rate = 6.13) {

    # Perform a check of the length of the intercepts
    if(length(intercept) == 1) {
        intercept <- rep(intercept, 2)
    } else if(length(intercept) > 2) {
        intercept <- intercept[1:2]
    }

    # Perform a check of the covariances. If not a matrix, then we cannot 
    # proceed
    if(!is.matrix(covariance)) {
        stop("Provided covariance is not a matrix. Cannot add multivariate noise.")
    }

    # Check whether the dimensionality of the covariances is allright
    if(dim(covariance) != c(2, 2)) {
        stop(
            paste(
                "Provided covariance matrix does not have the right dimensionality.",
                "A", 
                dim(covariance)[1], 
                "x", 
                dim(covariance)[2],
                "matrix is provided instead of the required 2 x 2 matrix."
            )
        )
    }

    # Perform similar checks for the transition matrix, which is subject to the 
    # same restrictions
    if(!is.matrix(transition)) {
        stop("Provided transition parameter is not a matrix. Cannot add multivariate noise.")
    }

    # Check whether the dimensionality of the covariances is allright
    if(dim(transition) != c(2, 2)) {
        stop(
            paste(
                "Provided transition matrix does not have the right dimensionality.",
                "A", 
                dim(transition)[1], 
                "x", 
                dim(transition)[2],
                "matrix is provided instead of the required 2 x 2 matrix."
            )
        )
    }

    # Check the value of the sampling rate
    if(sampling_rate <= 0) {
        stop("Sampling rate is lower than or equal to 0, which is impossible.")
    }

    # Adjust the transition matrix based on the sampling rate provided by the 
    # user
    transition <- transition %^% (6.13 / sampling_rate)
    
    # Use the multivariate normal distribution to generate the residuals, 
    # representing the innovations of the autoregressive process
    residuals <- MASS::mvrnorm(
        nrow(data),
        mu = c(0, 0), 
        Sigma = covariance
    )

    # Loop over all rows of the process
    for(i in seq_len(nrow(data))) {
        # If it is the first iteration, then we just add the residuals to the 
        # data. If it's not the first iteration, then we make the process depend 
        # on itself according to an autoregressive process
        if(i != 1) {
            data[i, c("x", "y")] <- intercept + transition %*% data[i, c("x", "y")]            
        }

        data[i, c("x", "y")] <- data[i, c("x", "y")] + residuals[i, ]
    }

    return(data)
}

#' List of measurement models
#' 
#' @export 
measurement_models <- list(
    "independent" = independent,
    "temporal" = temporal
)