#' Bin observations
#' 
#' Summarize observations within a given time window, typically with the idea of
#' having a single observation per bin. The Minds for Mobile Agents model assumes 
#' that pedestrians take a walking decision every 0.5 seconds. This function 
#' ensures that the data reflects this assumption by binning all available data 
#' within that time-frame. Of course, this time window can be adjusted by the 
#' user to fit their purposes.
#' 
#' Note that if more variables than required are provided to this function, that
#' these will get lost in translation. The reason is that it is difficult to 
#' implement meaningful aggregation across the different types of data that a 
#' user may supply.
#' 
#' @param data Dataframe that contains information on location (x- and 
#' y-coordinates) and the time at which the measurement was taken. By default, 
#' \code{\link[denoiser]{bin()}} will assume that this information is contained 
#' within the columns \code{"x"}, \code{"y"}, and \code{"time"} respectively. 
#' If this isn't the case, either change the column names in the data or specify 
#' the \code{cols} argument.
#' @param span Numeric denoting the size of the bins. Will pertain to the values
#' in the \code{"time"} variable. Defaults to \code{0.5}.
#' @param fx Function to execute on the data that falls within the bin. Will be
#' executed on the \code{"x"} and \code{"y"} columns separately and should ouput 
#' only a single value. Defaults to the function \code{\link[base]{mean()}}.
#' @param cols Named vector or named list containing the relevant column names
#' in \code{data} if they didn't contain the prespecified column names 
#' \code{"time"}, \code{"x"}, and \code{"y"}. The labels should conform to these 
#' prespecified column names and the values given to these locations should 
#' contain the corresponding column names in that dataset. Defaults to 
#' \code{NULL}, therefore assuming the structure explained in \code{data}.
#' @param .by String denoting whether the moving window should be taken with 
#' respect to a given grouping variable. Defaults to \code{NULL}.
#' 
#' @return Binned dataframe with a similar structure as \code{data}
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
#' # Bin the data together by taking the average for each second
#' bin(
#'   data,
#'   span = 1,
#'   fx = mean,
#'   cols = c(
#'     "time" = "seconds",
#'     "x" = "X",
#'     "y" = "Y"
#'   ),
#'   .by = "tag"
#' )
#' 
#' @export 
bin <- function(data, 
                span = 0.5, 
                fx = mean,
                cols = NULL,
                .by = NULL) {

    # Prepare the data for the analysis
    preparation <- prepare(
        data,
        cols = cols,
        .by = .by
    )

    cols <- preparation$cols
    group <- preparation$group
    data <- preparation$data

    # Instantiate a mock data.frame. Will be updated repeatedly in the loops
    mock <- data.frame(
        time = 0, 
        id = 0, 
        x = 0,
        y = 0
    )

    # Go over each of the data points and smooth the data using the moving 
    # window. We dispatch/loop over all the different possibilities in the 
    # grouping variable, for each of which we will create an individual 
    # dataframe to be smoothed.
    #
    # Within this loop, we do the following:
    #   - Create a group-specific dataframe
    #   - Determine which time points to contain within each bin based on the 
    #     specified span
    #   - Apply the specified function to the data
    #   - Put these data in a list
    data <- lapply(
        seq_along(group),
        function(i) {
            # Get the data specific to the group (if .by is not NULL)
            data_i <- data[data$id == group[i], ]

            # Create a new time variable that will be robust against all types
            # of weird data (as long as it's numeric). Makes the assignment of 
            # bins a bit easier to perform, as done immediately after.
            data_i$abs_time <- data_i$time - min(data_i$time)
            data_i$abs_time[data_i$abs_time == 0] <- 1e-2

            data_i$bin_number <- ceiling(data_i$abs_time / span)

            # Loop over the different bins
            bins <- unique(data_i$bin_number)
            data_i <- lapply(
                seq_along(bins),
                function(j) {
                    # Select relevant data for the bin
                    data_j <- data_i[data_i$bin_number == bins[j], ]

                    # Bin the data itself
                    mock$time <- mean(data_j$time)
                    mock$id <- group[i]
                    mock$x <- fx(data_j$x)
                    mock$y <- fx(data_j$y)

                    # Return this
                    return(mock)
                }
            )
            data_i <- do.call("rbind", data_i)

            return(data_i)
        }
    )
    data <- do.call("rbind", data)

    return(
        finalize(
            data,
            cols = cols,
            .by = .by
        )
    )
}