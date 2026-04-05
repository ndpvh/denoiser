#' Filter the data
#'
#' The \code{\link[denoiser]{denoiser()}} function takes in a dataset and
#' attempts to filter out the inherent measurement error. The function makes
#' use of two steps: The data will go through a Kalman filter and will then be
#' binned, both according to the specifications of the user (see
#' \code{\link[denoiser]{kalman_filter()}} and \code{\link[denoiser]{bin()}}).
#' Note that the first step occurs by default, and that it's left up to the user
#' whether they would also like to bin or thin their data through specifying the
#' arguments \code{span} or \code{thin}.
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
#' @param kalman Logical denoting whether to apply the Kalman filter
#' (\code{TRUE}) or skip it (\code{FALSE}). Defaults to \code{TRUE}.
#' @param span Numeric denoting the size of the bins for binning the data. Will
#' pertain to the values in the \code{"time"} variable. When \code{NULL}, no
#' binning is performed. Must be a number or \code{NULL}. Defaults to
#' \code{NULL}.
#' @param fx Function to execute on the data that falls within the bin. Will be
#' executed on the \code{"x"} and \code{"y"} columns separately and should ouput
#' only a single value. Defaults to the function \code{\link[base]{mean()}}.
#' Ignored when \code{span} is \code{NULL}.
#' @param thin Integer denoting a thinning factor. When provided, every
#' \code{thin}-th row is returned after any filtering and binning. Defaults to
#' \code{NULL}.
#' @param ... Additional arguments defining the Kalman filter to employ for
#' filtering. See \code{\link[denoiser]{kalman_filter()}}.
#'
#' @return Smoothed and/or binned \code{data.frame} with a similar structure as
#' \code{data}
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
#' # Use the denoiser function to get rid of the noise. Kalman filter is
#' # defined with the constant velocity model and an error variance of 0.01.
#' # Binning is performed with a span of 5 seconds and using the mean of the
#' # interval as representative of the position within that interval.
#' denoiser(
#'   data,
#'   cols = c(
#'     "time" = "seconds",
#'     "x" = "X",
#'     "y" = "Y"
#'   ),
#'   .by = "tag",
#'   model = "constant_velocity",
#'   error = 0.01,
#'   span = 5,
#'   fx = mean
#' )
#'
#' @seealso
#' \code{\link[denoiser]{bin()}}
#' \code{\link[denoiser]{kalman_filter()}}
#' \code{\link[denoiser]{noiser()}}
#'
#' @rdname denoiser-function
#'
#' @export
denoiser <- function(data,
                     cols = NULL,
                     .by = NULL,
                     kalman = TRUE,
                     span = NULL,
                     fx = mean,
                     thin = NULL,
                     ...) {

    # Validate span
    if(!is.null(span) && !is.numeric(span)) {
        stop("Argument `span` must be a number or NULL.")
    }

    # Always prepare the data upfront so cols renaming takes effect regardless
    # of which steps are run. Sub-functions are called with cols = NULL and
    # .by = "id" since columns are already in standard form after prepare().
    preparation <- prepare(data, cols = cols, .by = .by)
    data <- preparation$data
    saved_cols <- preparation$cols
    by_internal <- if(!is.null(.by)) "id" else NULL

    # Perform the Kalman filter to smooth the data
    if(kalman) {
        data <- kalman_filter(
            data,
            cols = NULL,
            .by = by_internal,
            ...
        )
    }

    # If span is provided, bin the data
    if(!is.null(span)) {
        data <- bin(
            data,
            cols = NULL,
            .by = by_internal,
            span = span,
            fx = fx
        )
    }

    # If asked for, thin the data last
    if(!is.null(thin)) {
        if(!is.null(by_internal)) {
            groups <- unique(data[, by_internal])
            data <- do.call("rbind", lapply(groups, function(g) {
                data_g <- data[data[, by_internal] == g, ]
                data_g[seq(1, nrow(data_g), by = thin), ]
            }))
        } else {
            data <- data[seq(1, nrow(data), by = thin), ]
        }
    }

    return(finalize(data, cols = saved_cols, .by = .by))
}
