#' Smooth using a Kalman filter
#' 
#' This is a higher-level function that will first look at whether the data needs
#' to be processed by a given variable. Then it will run the Kalman filter on 
#' these grouped data.
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. By default, 
#' [kalman_filter()] will assume that this information is contained within the 
#' columns `"x"`, `"y"`, and `"time"` respectively. If this isn't the case, 
#' either change the column names in the data or specify the `cols` argument.
#' @param model String denoting which model to use. Defaults to 
#' `"constant_velocity"`, and is currently the only one that is implemented.
#' @param cols Named vector or named list containing the relevant column names
#' in 'data' if they didn't contain the prespecified column names `"time"`, 
#' `"x"`, and `"y"`. The labels should conform to these prespecified 
#' column names and the values given to these locations should contain the 
#' corresponding column names in that dataset. Defaults to `NULL`, therefore 
#' assuming the structure explained in `data`.
#' @param .by String denoting whether the moving window should be taken with 
#' respect to a given grouping variable. Defaults to `NULL`.
#' @param N_min Integer denoting the minimum number of datapoints that are 
#' needed to use the Kalman filter. Defaults to \code{5}.
#' @param ... Additional arguments provided to the loaded model. For more 
#' information, see [constant_velocity].
#' 
#' @return Smoothed dataframe with a similar structure as `data`
#' 
#' @examples 
#' # Generate data for illustration purposes. Movement in circular motion at a
#' # pace of 1.27m/s with some added noise of SD = 10cm.
#' angles <- seq(0, 4 * pi, length.out = 100)
#' coordinates <- 10 * cbind(cos(angles), sin(angles))
#' coordinates <- coordinates + rnorm(200, mean = 0, sd = 0.1)
#' 
#' data <- data.frame(
#'   X = coordinates[, 1],
#'   Y = coordinates[, 2],
#'   seconds = rep(1:50, times = 2),
#'   tag = rep(1:2, each = 50)
#' )
#' 
#' # Use the Kalman filter with the constant velocity model on these data to 
#' # filter out the measurement error. Provide an assumed variance of 0.01 
#' # to this model
#' kalman_filter(
#'   data,
#'   model = "constant_velocity",
#'   cols = c(
#'     "time" = "seconds",
#'     "x" = "X",
#'     "y" = "Y"
#'   ),
#'   .by = "tag",
#'   error = 0.01
#' )
#' 
#' @seealso 
#' \code{\link[denoiser]{kf_predict}},
#' \code{\link[denoiser]{kf_innovation}},
#' \code{\link[denoiser]{kf_update}}
#' 
#' @export 
kalman_filter <- function(data,
                          model = "constant_velocity",
                          cols = NULL,
                          .by = NULL,
                          N_min = 5,
                          ...) {

    # Prepare the data for the analysis
    preparation <- prepare(
        data,
        cols = cols,
        .by = .by
    )

    cols <- preparation$cols
    group <- preparation$group
    data <- preparation$data

    # Load the movement and measurement equations that were asked for by the 
    # user. Load them as a function so that we can use them later on
    equation <- function(x) kalman_models[[model]](
        x, 
        ...
    )

    # Check how much data you have. Based on personal experience, the Kalman 
    # filter cannot operate properly when less than 5 datapoints are available. 
    # Check for this cutoff and, if necessary, warn the user and return the 
    # unfiltered data.
    check <- sapply(
        group, 
        function(x) nrow(data[data$id == x, ])
    )
    if(any(check <= N_min)) {
        warning(
            paste(
                "Some of the data contain too few datapoints to perform the Kalman filter.",
                "Returning the data as-is for", 
                ifelse(
                    is.null(.by),
                    "this dataset.",
                    paste(
                        sum(check <= N_min),
                        "datasets defined through the `.by` argument."
                    )
                )
            )
        )
    }

    # Perform the Kalman filter for each group
    data <- lapply(
        group,
        function(x) {
            # Select the data of interest
            data_x <- data[data$id == x, ]

            # If there are less than N_min datapoints, then we just return the 
            # data as is
            if(nrow(data_x) <= N_min) {
                return(data_x)
            }

            # Apply the model for these data and extract the parameters to be 
            # used. Specifically:
            #   - z: The data to be filtered
            #   - x0: The initial condition to start from
            #   - P0: The initial condition for the covariance matrix for the 
            #         observations
            #   - cols: The columns that should be used in the filter
            parameters <- equation(data_x)   

            z <- parameters[["z"]]
            x0 <- parameters[["x"]]
            P0 <- parameters[["P"]]
            
            # Make a copy of the data that will contain the smoothed data. 
            # Futhermore create lists that will hold the estimation covariance 
            # and the Kalman gain at each iteration
            smoothed <- z

            P <- list()
            K <- list()
            y <- list()
            
            # Iterate over the data to smooth it. Smoothing proceeds through 
            # the repeated application of three steps:
            #   1) Prediction: Using the movement equation to predict the next 
            #                  state of x based on the initial conditions x0 and 
            #                  P0
            #   2) Innovation: Use the prediction to defined how "wrong" the 
            #                  measurement may be and compute the Kalman gain
            #   3) Update: Make a guess about the latent state of x based on the 
            #              prediction and measurement as weighted by the Kalman 
            #              gain
            for(i in seq_len(nrow(z))) {
                # Perform the prediction step of the Kalman filter. Note that in 
                # the first iteration, we use the initial (prior) guess as 
                # prediction.
                if(i == 1) {
                    prediction <- list(
                        "x" = x0, 
                        "P" = P0
                    )

                } else {
                    # Create parameters that are needed for the prediction step.
                    # These parameters are F (the deterministic movement) and 
                    # W (the expected stochastic noise around this movement), 
                    # both of which depend on the time between observations.
                    F <- parameters[["F"]](z$Delta_t[i])
                    W <- parameters[["W"]](z$Delta_t[i])

                    # Perform the prediction itself.
                    prediction <- kf_predict(
                        x0, 
                        P0, 
                        F, 
                        W,
                        u = parameters[["u"]][i, , drop = FALSE], 
                        B = parameters[["B"]]
                    )
                }

                # Perform the inovation step. Uses the measured state z, the 
                # predicted state x and its predicted covariance P, and finally 
                # the measurement matrix H and the assumed measurement 
                # covariance matrix R.
                innovation <- kf_innovation(
                    z[i, c("x", "y")] |>
                        as.numeric() |>
                        matrix(ncol = 1),
                    prediction[["x"]],
                    prediction[["P"]],
                    parameters[["H"]],
                    parameters[["R"]]
                )

                # Finally, update the value of x
                result <- kf_update(
                    prediction[["x"]],
                    prediction[["P"]], 
                    innovation[["y"]], 
                    parameters[["H"]],
                    innovation[["K"]]
                )

                # Save the results in the smoothed dataset.
                smoothed[i, c("x", "y")] <- result[["x"]][1:2]

                # Also save some of the intermediate results in a separate list.
                # This will ensure we are able to check each case for debugging
                # purposes. Note that I left in the case for P when it is not 
                # diagonal. Currently not use, but may be of interest at a later
                # stage
                # P[[i]] <- t(result[["P"]]) %*% result[["P"]]
                P[[i]] <- result[["P"]]
                K[[i]] <- innovation[["K"]]
                y[[i]] <- innovation[["y"]]

                # Overwrite the initial conditions with the newly acquired values
                x0 <- result[["x"]]
                P0 <- result[["P"]]
            }

            # Replace the original dataset with the smoothed ones
            data_x[, c("x", "y")] <- smoothed[, c("x", "y")]

            return(data_x)
        }
    )

    data <- do.call("rbind", data)   

    # Finalize and return the data
    return(
        finalize(
            data,
            cols = cols, 
            .by = .by
        )
    )
}





################################################################################
# STEPS IN KALMAN FILTER

#' Prediction step in the Kalman filter
#' 
#' @details
#' In this step, we use the movement equation to predict the new values of x 
#' based on the initial condition defined by the location \eqn{\mathbf{x}} and 
#' the covariance \eqn{P} at time \eqn{t_{i - 1}}, using the equation:
#' 
#' \deqn{\mathbf{x}_t = F_i \mathbf{x}_{i - 1} + B_i \mathbf{u}_i + \mathbf{\epsilon}_i}
#' where \eqn{F} is the movement transition matrix, \eqn{B} scales the external
#' influences \eqn{\mathbf{u}}, and \eqn{\mathbf{\epsilon}} defines the error, 
#' and where all terms are defined at the time point \eqn{t_i}. 
#' 
#' The covariance \eqn{P} is also updated based on this equation, representing 
#' the certainty around the prediction \eqn{\mathbf{x}_i}. This covariance is 
#' updated through the following equation:
#' 
#' \deqn{P_i = F_i P_{i - 1} F_i^T + W_i}
#' where \eqn{W} represents the covariance matrix of \eqn{\epsilon}. 
#' 
#' For stability purposes, we use Cholesky decompositions of the covariance 
#' matrices rather than the actual covariance matrices. This needs to be taken 
#' into account when making your own model. 
#' 
#' @param x0 Vector of values of the movement equation at time t.
#' @param P0 Cholesky decomposition of the covariance of x0 at time t.
#' @param F Transition matrix, relating values of X at time t to those at t.
#' @param W Cholesky decomposition of the process noise covariance matrix.
#' @param u Vector of values for the external variables at time t. By default an 
#' empty vector.
#' @param B Matrix that connects the external variables in u to the values in x.
#' By default an empty matrix.
#' 
#' @return Named list of predicted values for \eqn{\mathbf{x}} (\code{"x}) and 
#' \eqn{P} (\code{"P"}) at the next time point.
#' 
#' @seealso 
#' \code{\link[denoiser]{kalman_filter}},
#' \code{\link[denoiser]{kf_innovation}},
#' \code{\link[denoiser]{kf_update}}
#' 
#' @export 
kf_predict <- function(x0,
                       P0, 
                       F, 
                       W, 
                       u = matrix(0, nrow = length(x0), ncol = 1), 
                       B = matrix(0, nrow = length(u), ncol = length(u))) {

    # Predict values of the mean and estimation covariance. Use the square root 
    # of the covariances to ensure that they will lead to positive definite 
    # matrices. For this, use and predict values of the Cholesky decomposition 
    # and use the R matrix of a QR decomposition to update this Cholesky.
    x <- F %*% x0 + B %*% u
    P <- F %*% P0 %*% t(F) + W

    # Return the predicted value of x as well as the Cholesky decomposition of 
    # the covariance.
    return(
        list(
            "x" = matrix(x, ncol = 1), 
            "P" = P
        )
    ) 
}

#' Innovation step in the Kalman filter
#' 
#' @details
#' In the innovation step, we compute how much error we expect in the measurement
#' if the movement equation is correct in its prediction. The expected 
#' "innovation" is defined as:
#' 
#' \deqn{\mathbf{y}_i = \mathbf{z}_i - H \mathbf{x}_i}
#' where \eqn{\mathbf{z}} is the measurement, \eqn{H} is the measurement matrix, 
#' and \eqn{\mathbf{x}} is the prediction obtained through the prediction step. 
#' We also compute the covariance matrix for this innovation, which is defined as:
#' 
#' \deqn{\Sigma_i = H P_i H^T + R}
#' where \eqn{R} contains the (assumed) measurement covariances. It is 
#' interesting to note that the value of \eqn{\Sigma} is always symmetric for 
#' each value of \eqn{H}. Whether its Cholesky decomposition exists, however, 
#' will depend on both \eqn{H} and \eqn{P}.
#' 
#' In the final step, we compute the Kalman gain using both the covariance of 
#' the prediction and the total covariance of the measurement process through 
#' the following equation: 
#' 
#' \deqn{K_i = P_i H^T \Sigma_i^{-1}}
#' As one may notice, the Kalman gain is a measure of how much we can trust the
#' prediction, specifically by putting the prediction covariance over the total
#' variance. It is thus related to a measure of reliability.
#' 
#' @param z Vector of measured values at time t + 1
#' @param x Vector of predicted values of the movement equation at time t + 1.
#' @param P Cholesky decomposition of the estimation covariance matrix at time 
#' t + 1.
#' @param H Matrix relating the values in x to the values in y.
#' @param R Cholesky decomposition of the measurement noise covariance matrix.#' 
#' 
#' @return Named list of the innovation (\code{"y"}), the Cholesky decomposition 
#' of its covariance matrix (\code{"S"}), and the Kalman gain (\code{"K"})
#' 
#' @seealso 
#' \code{\link[denoiser]{kalman_filter}},
#' \code{\link[denoiser]{kf_predict}},
#' \code{\link[denoiser]{kf_update}}
#' 
#' @export 
kf_innovation <- function(z, 
                          x, 
                          P,
                          H,
                          R) {

    # Transform the relevant matrices to a covariance matrix using their 
    # Cholesky decomposition.
    R <- t(R) %*% R

    # Compute the innovation y and its covariance matrix decomposition
    y <- z - H %*% x
    S <- H %*% P %*% t(H) + R

    # Compute the Kalman gain
    K <- P %*% t(H) %*% solve(S)

    return(
        list(
            "y" = y,
            "S" = chol(S),
            "K" = K
        )
    )
}

#' Updating step in the Kalman filter
#' 
#' @details
#' In the update step, we use the measurement innovation \eqn{\mathbf{y}_i} and 
#' the predicted value \eqn{\mathbf{x}_i} and combine both in a guess of what 
#' the latent state of the system should be. For this, we use the following 
#' equation:
#' 
#' \deqn{\hat{\mathbf{x}}_i = \mathbf{x}_i + K \mathbf{y}}
#' where \eqn{\mathbf{x}} is the prediction coming from the prediction step, 
#' \eqn{\mathbf{y}} is the innovation derived in the innovation step, \eqn{K} is
#' the Kalman gain, and \eqn{\hat{\mathbf{x}}} is the latent state of the system.
#' 
#' We also compute the covariance of this update:
#' 
#' \deqn{\hat{P}_i = (I - K H) P_i}
#' where I is the identity matrix, \eqn{H} is the measurement matrix, \eqn{K} is 
#' the Kalman gain, \eqn{P_i} is the covariance of the prediction derived in the 
#' prediction step, and \eqn{\hat{P}_i} is the estimated certainty around the 
#' guess \deqn{\hat{\mathbf{x}}_i}. 
#' 
#' Note that the values \deqn{\hat{\mathbf{x}}_i} and \eqn{\hat{P}_i} are used
#' as initial conditions for the next time step \eqn{t_{i + 1}}, therefore 
#' serving as input in the prediction step and starting the cycle all over again.
#' 
#' @param x Vector of predicted values of the movement equation at time t + 1.
#' @param P Cholesky decomposition of the estimation covariance matrix at time 
#' t + 1.
#' @param y Vector of innovations at time t + 1
#' @param H Measurement matrix connecting measurement to movement.
#' @param K Kalman gain
#' 
#' @return List containing the smoothed value of \eqn{x} (\code{"x"}) together 
#' with the Cholesky decomposition of its covariance (\code{"P"})
#' 
#' @seealso 
#' \code{\link[denoiser]{kalman_filter}},
#' \code{\link[denoiser]{kf_predict}},
#' \code{\link[denoiser]{kf_innovation}}
#' 
#' @export 
kf_update <- function(x, 
                      P, 
                      y, 
                      H, 
                      K) {

    # Compute x and P         
    x <- x + K %*% y
    P <- (diag(nrow(P)) - K %*% H) %*% P
    
    return(
        list(
            "x" = x,
            "P" = P
        )
    )
}