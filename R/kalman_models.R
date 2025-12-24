#' Constant velocity model
#' 
#' This model assumes that movement occurs at a constant velocity, so that 
#' changes in acceleration are considered to be noise. In a previous study, we
#' found that this model performed reasonably well on simulated and observed 
#' pedestrian data.
#' 
#' @details 
#' The constant velocity model is based on the assumption that velocity remains
#' constant, so that acceleration can be put to 0. This means that we can use 
#' the following movement equation to model changes in the positions, so that:
#' 
#' \deqn{\begin{bmatrix}
#'   x \\
#'   y \\
#' \end{bmatrix}_i = \begin{bmatrix}
#'   x \\
#'   y \\
#' \end{bmatrix}_{i - 1} + \begin{bmatrix}
#'   v_x \\
#'   v_y \\
#' \end{bmatrix} \Delta t}
#' 
#' where \eqn{x} and \eqn{y} represent the x- and y-coordinates on which the 
#' measurements at time \eqn{t_i} and \eqn{t_{i - 1}} were taken. The variables
#' \eqn{v_x} and \eqn{v_y} represent the speeds in the x- and y-direction at 
#' which the system is moving, and \eqn{\Delta t = t_i - t_{i - 1}} represents 
#' the time between the two measurements. This is the basic equation from which 
#' the parameters of the Kalman filter are derived.
#' 
#' For the constant velocity model, we keep track of the positional data and 
#' the respective velocities at a particular time point \eqn{t_i}. This means 
#' that the latent state \eqn{\mathbf{x}} consists of 4 values on each iteration, 
#' namely:
#' 
#' \deqn{\mathbf{x}_i = \begin{bmatrix}
#'   x \\
#'   y \\
#'   v_x \\
#'   v_y \\
#' \end{bmatrix}_i}
#' 
#' Under this specification, we define the transition matrix \eqn{F} and the 
#' covariance matrix \eqn{W} of the movement equation as follows:
#' 
#' \deqn{F_i = \begin{bmatrix} 
#'   1 & 0 & \Delta t & 0 \\  
#'   0 & 1 & 0 & \Delta t \\
#'   0 & 0 & 1 & 0 \\
#'   0 & 0 & 0 & 1 \\
#' \end{bmatrix}_i}
#' 
#' \deqn{W_i = \begin{bmatrix}
#'   \Delta t^2 \sigma_{v_x}^2 & 0 & \Delta t \sigma_{v_x}^2 & 0 \\
#'   0 & \Delta t^2 \sigma_{v_y}^2 & 0 & \Delta t \sigma_{v_y}^2 \\
#'   \Delta t \sigma_{v_x}^2 & 0 & \sigma_{v_x}^2 & 0 \\
#'   0 & \Delta t \sigma_{v_y}^2 & 0 & \sigma_{v_y}^2 \\
#' \end{bmatrix}_i}
#' In these equations, \eqn{\Delta t} represents the time that has elapsed 
#' between two observations, so that \eqn{\Delta t = t_i - t_{i - 1}}. The 
#' variances \eqn{\sigma_{v_x}^2} and \eqn{\sigma_{v_y}^2} capture the 
#' variation in the speeds \eqn{v_x} and \eqn{v_y}. Within this function, we 
#' estimate these variances through computing the observed variance in the 
#' speeds and subtracting the assumed measurement error from it, so that in the 
#' x-direction, you obtain:
#' 
#' \deqn{\sigma_{v_x}^2 = VAR[v_x]^\text{obs} - 
#' \frac{2}{E[\Delta t]^2} \sigma_{\epsilon, x}^2}
#' 
#' where \eqn{\sigma_{\epsilon, x}^2} and \eqn{\sigma_{\epsilon, y}^2} are
#' provided through the \code{error} argument. Note that we assume no 
#' covariance between the two dimensions in the movement covariance \eqn{W}.
#' 
#' Typically, the movement equation also includes external forces that may 
#' influence the observed behavior. In the constant velocity model described by
#' this function, we assume that these parameters have no influence on the 
#' observed behavior, meaning that we set its parameters \eqn{B} and 
#' \eqn{\mathbf{u}} to 0.
#' 
#' For the measurement equation, we define the measurement matrix \eqn{H} and 
#' the measurement error covariance matrix \eqn{R} as:
#' 
#' \deqn{H = \begin{bmatrix}
#'   1 & 0 & 0 & 0 \\
#'   0 & 1 & 0 & 0 \\
#' \end{bmatrix}}
#' 
#' \deqn{R = \begin{bmatrix}
#'   \sigma_\epsilon^2 & 0 \\
#'   0 & \sigma_\epsilon^2
#' \end{bmatrix}}
#' where \eqn{\sigma_\epsilon^2} is provided through the \code{error}
#' argument. Importantly, the matrix \eqn{R} is transformed to its Cholesky 
#' decomposition, as the function \code{\link[denoiser]{kalman_filter}} assumes
#' the Cholesky decomposition is provided for stability purposes.
#' 
#' Note that these two matrices are time-independent: They are assumed to be 
#' constant at each iteration (long-term changes over time) and to not depend on 
#' the time between obsevations \eqn{\Delta t}. Furthermore note that the 
#' measurement error covariance \eqn{R} can only be defined for those variables
#' that we have measurements on, namely the x- and y-coordinates. No such error
#' exists for the speeds \eqn{v_x} and \eqn{v_y}. Similarly, note that the 
#' measurement matrix \eqn{H} maps the predictions on the latent level to 
#' predictions the measurement level, where it acknowledges that we only 
#' measured x- and y-coordinates. 
#' 
#' Finally, we need to define the initial conditions from which the Kalman filter
#' starts. These initial conditions are taken as the observed initial locations
#' and speeds (in \eqn{\mathbf{x}_0}) and the observed variances of all 
#' these variables (in \eqn{P_0}). Note that we provide a covariance matrix 
#' \eqn{P_0} that is diagonal for simplicity. 
#' 
#' @param data A data.frame containing the data on which to base the parameters
#' of the constant velocity model. This function assumes that this data.frame
#' contains the columns \code{"time"}, \code{"x"}, and \code{"y"} containing 
#' the time at which the observed position (x, y) was measured respectively. 
#' @param error Numeric or numerical vector containing the assumed
#' value of the measurement error variance in the x- and y-direction. Should 
#' consist of either 1 or 2 values. If only 1 value is provided, the measurement
#' error variance will be assumed to be the same for both dimensions. Defaults 
#' to \code{0.031^2}, a value that we have obtained experimentally.
#' 
#' @return Named list containing all parameters relevant for the Kalman filter.
#' 
#' @examples 
#' # Generate data for illustration purposes. Movement in circular motion at a
#' # pace of 1.27m/s with some added noise of SD = 10cm.
#' # some added noise
#' angles <- seq(0, 4 * pi, length.out = 100)
#' coordinates <- 10 * cbind(cos(angles), sin(angles))
#' coordinates <- coordinates + rnorm(200, mean = 0, sd = 0.1)
#' 
#' data <- data.frame(
#'   x = coordinates[, 1],
#'   y = coordinates[, 2],
#'   time = 1:100
#' )
#' 
#' # Generate the parameters of the Kalman filter according to the constant 
#' # velocity model with an assumed measurement error variance of 0.01
#' constant_velocity(
#'   data, 
#'   error = 0.1^2
#' )
#'
#' @export
constant_velocity <- function(data,
                              error = 0.031^2) {

    # Ensure the error variances contain two values.
    if(length(error) == 1) {
        error <- rep(error, 2)

    } else if(length(error) > 2) {
        error <- error[1:2]
    }

    # Preprocess the data to (a) be in chronological order, (b) contain the 
    # times between observations, (c) contain the difference in position in
    # each dimension, and (d) contain the speeds in each dimension
    data <- data[order(data$time), ]

    data$delta_t <- c(0, diff(data$time))
    data$delta_x <- c(0, diff(data$x))
    data$delta_y <- c(0, diff(data$y))

    data$speed_x <- data$delta_x / data$delta_t
    data$speed_y <- data$delta_y / data$delta_t

    # Define the movement equation parameters F and W. For W, we inform the 
    # values of this matrix empirically, using error-corrected values of the 
    # observed variances for this purpose.
    F <- function(delta_t) {
        M <- c(
            1, 0, delta_t, 0,
            0, 1, 0, delta_t,
            0, 0, 1, 0,
            0, 0, 0, 1
        ) |>
            matrix(nrow = 4, ncol = 4, byrow = TRUE)

        return(M)
    }
    
    denom <- mean(data$delta_t[-1], na.rm = TRUE)^2
    var_x <- var(data$speed_x, na.rm = TRUE) - 2 * error[1] / denom
    var_y <- var(data$speed_y, na.rm = TRUE) - 2 * error[2] / denom

    var_x <- ifelse(var_x <= 1e-10, 1e-10, var_x)
    var_y <- ifelse(var_y <= 1e-10, 1e-10, var_y)

    W <- function(delta_t) {
        M <- c(
            delta_t^2 * var_x, 0, delta_t * var_x, 0, 
            0, delta_t^2 * var_y, 0, delta_t * var_y, 
            delta_t * var_x, 0, var_x, 0,
            0, delta_t * var_y, 0, var_y
        ) |>
            matrix(nrow = 4, ncol = 4, byrow = TRUE)

        return(M)
    }

    # The external influences are assumed to amount to 0, which is reflected in 
    # the matrices B and u below.
    B <- matrix(0, nrow = 4, ncol = 1)
    u <- matrix(0, nrow = nrow(data), ncol = 1)

    # Define the measurement equation parameters H and R.
    H <- c(1, 0, 0, 0,
           0, 1, 0, 0) |>
        matrix(nrow = 2, byrow = TRUE)
        
    R <- diag(error) |>
        chol()

    # Define the initial conditions for the latent state, reflected in the latent
    # position x_0 and the latent covariance P_0. I keep these very vague yet 
    # data-driven for a faster convergence.
    x0 <- c(
        mean(data$x, na.rm = TRUE), 
        mean(data$y, na.rm = TRUE),
        mean(data$speed_x, na.rm = TRUE),
        mean(data$speed_y, na.rm = TRUE)
    ) |>
        matrix(ncol = 1)
    
    P0 <- cbind(
        data$x, 
        data$y, 
        data$speed_x, 
        data$speed_y
    ) |>
        cov(use = "pairwise.complete.obs") |>
        diag() |>
        diag()

    # Put everything in a list and return. This list looks different for the 
    # internal functions than for the kalman_filter function of the 
    # package kalmanfilter.
    return(
        list(
            "z" = data,       # Data to smooth
            "x" = x0,         # Current value of x (prior mean)
            "P" = P0,         # Current covariance of x (prior covariance)
            "F" = F,          # Movement transition matrix
            "W" = W,          # Movement covariance matrix
            "B" = B,          # External variable transition matrix
            "u" = u,          # External variables themselves
            "H" = H,          # Measurement matrix
            "R" = R           # Measurement covariance matrix
        )
    )
}

#' List of Kalman filter models
#' 
#' @export
kalman_models <- list("constant_velocity" = constant_velocity)