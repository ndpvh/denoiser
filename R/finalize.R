#' Finalize data after analysis
#' 
#' Function that is used internally to change the data back to their original 
#' format after conducting an analysis, it being either binning 
#' (\code{\link[denoiser]{bin()}}) or using the Kalman filter 
#' (\code{\link[denoiser]{kalman_filter()}}). The finalization consists of 
#' renaming the columns to the user-defined column names instead of the package-
#' required ones and deleting the grouping variable if it was not originally 
#' present in the data.
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. It is assumed
#' that this information is contained within the columns \code{"x"}, \code{"y"},
#' and \code{"time"} respectively.
#' @param cols Named vector or named list containing the mapping of the original
#' column names to the internal ones used within the package. Defaults to 
#' \code{NULL}, therefore assuming the structure explained in \code{data}.
#' @param .by String denoting whether the moving window should be taken with 
#' respect to a given grouping variable. Defaults to \code{NULL}.
#' 
#' @return Adjusted \code{data.frame}
#' 
#' @examples 
#' # Generate data for illustration purposes
#' #
#' # Note that for this to work, I need to define the package-required column 
#' # names
#' data <- data.frame(
#'   x = rnorm(100),
#'   y = rnorm(100),
#'   time = rep(1:50, times = 2) / 10,
#'   id = rep(1:2, each = 50)
#' )
#' 
#' # Prepare the data for analysis
#' finalize(
#'   data,
#'   cols = c(
#'     "time" = "seconds",
#'     "x" = "X",
#'     "y" = "Y"
#'   ),
#'   .by = "tag"
#' )
#' 
#' @seealso 
#' \code{\link[denoiser]{prepare()}}
#' 
#' @export
finalize <- function(data, 
                     cols = NULL,
                     .by = NULL) {

    # Change the column names back
    data <- data[, names(cols)] |>
        `colnames<-` (cols)

    # Remove the id-column if the .by argument was not defined
    if(is.null(.by)) {
        data[, cols["id"]] <- NULL
    }

    return(data)
}