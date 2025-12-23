#' Prepare data for analysis
#' 
#' Function that is used internally to prepare data for analysis, it being either
#' binning (\code{\link[denoiser]{bin()}}) or using the Kalman filter 
#' (\code{\link[denoiser]{kalman_filter()}}). This preparation consists of the 
#' following steps. First, this function checks whether the provided data is 
#' actually a \code{data.frame}, which is required for our functions to work 
#' properly. Then, this function examines the column names of argument \code{cols}. 
#' When provided, it will check whether they adhere to the required format and, 
#' if so, change the column names of the data to the default ones used in this 
#' package (this change is later undone in \code{\link[denoiser]{finalize()}}). 
#' Finally, this function check whether there is a grouping variable as 
#' specified in \code{.by}, and if so prepares the data for this grouping.
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. By default, 
#' \code{\link[denoiser]{prepare()}} will assume that this information is 
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
#' 
#' @return Named list containing the prepared \code{data.frame} (under
#' \code{"data"}), the mapping of the user-specified and package-required 
#' column names (under \code{"cols"}), and the values of the grouping variable 
#' (under \code{"group"}).
#' 
#' @examples 
#' # Generate data for illustration purposes
#' data <- data.frame(
#'   X = rnorm(100),
#'   Y = rnorm(100),
#'   seconds = rep(1:50, times = 2) / 10,
#'   tag = rep(1:2, each = 50)
#' )
#' 
#' # Prepare the data for analysis
#' prepare(
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
#' \code{\link[denoiser]{finalize()}}
#' 
#' @export
prepare <- function(data, 
                    cols = NULL,
                    .by = NULL) {

    # Check whether a dataframe is provided. If not, throw an error
    if(!is.data.frame(data)) {
        stop("Argument `data` should contain a data.frame.")
    }

    # If column names are provided, temporarily change the column names to the 
    # default ones. If no column names are provided, then we use the default 
    # ones.
    if(!is.null(cols)) {
        # Check whether the correct names are provided to the vector
        if(!all(c("time", "x", "y") %in% names(cols))) {
            stop(
                paste(
                    "Names of the `cols` argument does not contain the required names.", 
                    "Please make sure the labels are 'time', 'x', and 'y' or change your data's column names."
                )
            )
        }
    } else {
        cols <- c(
            "time" = "time",
            "x" = "x",
            "y" = "y"
        )
    }

    # Check whether there is a grouping variable to account for. If not, then 
    # we just use a dummy
    if(!is.null(.by)) {
        group <- unique(data[, .by])
        cols["id"] <- .by
    } else {
        data$id <- 1
        group <- 1

        cols["id"] <- "id"
    }

    # Select the columns of interest
    data <- data[, cols] |>
        `colnames<-` (names(cols))

    return(
        list(
            "data" = data,
            "cols" = cols, 
            "group" = group
        )
    )
}