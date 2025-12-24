#' Add noise to the data
#' 
#' The \code{\link[denoiser]{noiser()}} function takes in a dataset and 
#' adds measurement error to it. To do this, it currently makes use of one of 
#' two potential measurement models: One in which the measurement error is 
#' independent over time (\code{\link[denoiser]{independent()}}) and one in which 
#' measurement error does depend on time (\code{\link[denoiser]{temporal()}}).
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. By default, 
#' \code{\link[denoiser]{denoiser()}} will assume that this information is 
#' contained within the columns \code{"x"}, \code{"y"}, and \code{"time"} 
#' respectively. If this isn't the case, either change the column names in the 
#' data or specify the \code{cols} argument.
#' @param cols Named vector or named list containing the relevant column names
#' in \code{data} if they do not conform to the prespecified column names 
#' \code{"time"}, \code{"x"}, and \code{"y"}. The labels should conform to these 
#' prespecified column names and the values given to these locations should 
#' contain the corresponding column names in that dataset. Defaults to 
#' \code{NULL}, therefore assuming the structure explained in \code{data}.
#' @param .by String denoting whether the moving window should be taken with 
#' respect to a given grouping variable. Defaults to \code{NULL}.
#' @param model String denoting the model to be used for noising up the data. 
#' Either \code{"independent"} or \code{"temporal"}, calling the 
#' \code{\link[denoiser]{independent()}} or \code{\link[denoiser]{temporal()}}
#' model respectively. Defaults to \code{"temporal"}.
#' @param ... Additional arguments provided to the measurement error models. For
#' more information, see \code{\link[denoiser]{independent()}} or 
#' \code{\link[denoiser]{temporal()}}.
#' 
#' @return Noised up \code{data.frame} with a similar structure as \code{data}
#' 
#' @examples 
#' # Generate data for illustration purposes. Movement in circular motion at a
#' # pace of 1.27m/s with some added noise of SD = 10cm.
#' angles <- seq(0, 4 * pi, length.out = 100)
#' coordinates <- 10 * cbind(cos(angles), sin(angles))
#' 
#' data <- data.frame(
#'   X = coordinates[, 1],
#'   Y = coordinates[, 2],
#'   seconds = rep(1:50, times = 2),
#'   tag = rep(1:2, each = 50)
#' )
#' 
#' # Use the noiser function to add measurement error. We use the independent 
#' # measurement error model with independence between the x- and y-dimension 
#' # and with the measurement error variance being 0.01 in both dimensions
#' noiser(
#'   data,
#'   cols = c(
#'     "time" = "seconds",
#'     "x" = "X",
#'     "y" = "Y"
#'   ),
#'   .by = "tag",
#'   model = "independent",
#'   covariance = diag(2) * 0.01
#' ) |>
#'   head()
#' 
#' @seealso 
#' \code{\link[denoiser]{independent()}}
#' \code{\link[denoiser]{denoiser()}}
#' \code{\link[denoiser]{temporal()}}
#' 
#' @export 
noiser <- function(data, 
                   cols = NULL,
                   .by = NULL,
                   model = "temporal",
                   ...) {

    # Prepare the data for adding noise to it
    preparation <- prepare(
        data, 
        cols = cols,
        .by = .by
    )

    cols <- preparation$cols
    group <- preparation$group
    data <- preparation$data

    # Load the measurement error model
    error <- function(x) measurement_models[[model]](
        x, 
        ...
    )

    # Loop over each of the groups and apply the measurement model to each of 
    # the individual datasets
    data <- lapply(
        seq_along(group),
        function(i) {
            # Get the data specific to the group (if .by is not NULL)
            data_i <- data[data$id == group[i], ]

            # Ensure the data are in chronological order 
            data_i <- data_i[order(data_i$time), ]

            # Apply the measurement model to these data to generate noised up 
            # data and return
            return(error(data_i))
        }
    )
    data <- do.call("rbind", data)

    # Finalize the data and return
    return(
        finalize(
            data,
            cols = cols,
            .by = .by
        )
    )
}