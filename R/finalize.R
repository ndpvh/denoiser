#' Finalize data after analysis
#' 
#' Function that is used internally to change the data back to their original 
#' format after conducting an analysis, it being either binning ([bin()]) or 
#' using the Kalman filter ([kalman_filter()]). The finalization consists of 
#' renaming the columns to the user-defined column names instead of the package-
#' required ones and deleting the grouping variable if it was not originally 
#' present in the data.
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. By default, 
#' [kalman_filter()] will assume that this information is contained within the 
#' columns `"x"`, `"y"`, and `"time"` respectively.
#' @param cols Named vector or named list containing the relevant column names
#' in 'data' if they didn't contain the prespecified column names `"time"`, 
#' `"x"`, and `"y"`. The labels should conform to these prespecified 
#' column names and the values given to these locations should contain the 
#' corresponding column names in that dataset. Defaults to `NULL`, therefore 
#' assuming the structure explained in `data`.
#' @param .by String denoting whether the moving window should be taken with 
#' respect to a given grouping variable. Defaults to `NULL`.
#' 
#' @return Adjusted `data.frame`
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