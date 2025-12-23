# Bin observations

Summarize observations within a given time window, typically with the
idea of having a single observation per bin. The Minds for Mobile Agents
model assumes that pedestrians take a walking decision every 0.5
seconds. This function ensures that the data reflects this assumption by
binning all available data within that time-frame. Of course, this time
window can be adjusted by the user to fit their purposes.

## Usage

``` r
bin(data, span = 0.5, fx = mean, cols = NULL, .by = NULL)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default, `bin()`
  will assume that this information is contained within the columns
  `"x"`, `"y"`, and `"time"` respectively. If this isn't the case,
  either change the column names in the data or specify the `cols`
  argument.

- span:

  Numeric denoting the size of the bins. Will pertain to the values in
  the `"time"` variable. Defaults to `0.5`.

- fx:

  Function to execute on the data that falls within the bin. Will be
  executed on the `"x"` and `"y"` columns separately and should ouput
  only a single value. Defaults to the function
  [`mean()`](https://rdrr.io/r/base/mean.html).

- cols:

  Named vector or named list containing the relevant column names in
  `data` if they didn't contain the prespecified column names `"time"`,
  `"x"`, and `"y"`. The labels should conform to these prespecified
  column names and the values given to these locations should contain
  the corresponding column names in that dataset. Defaults to `NULL`,
  therefore assuming the structure explained in `data`.

- .by:

  String denoting whether the moving window should be taken with respect
  to a given grouping variable. Defaults to `NULL`.

## Value

Binned dataframe with a similar structure as `data`

## Details

Note that if more variables than required are provided to this function,
that these will get lost in translation. The reason is that it is
difficult to implement meaningful aggregation across the different types
of data that a user may supply.

## Examples

``` r
# Generate data for illustration purposes
data <- data.frame(
  X = rnorm(100),
  Y = rnorm(100),
  seconds = rep(1:50, times = 2) / 10,
  tag = rep(1:2, each = 50)
)

# Bin the data together by taking the average for each second
bin(
  data,
  span = 1,
  fx = mean,
  cols = c(
    "time" = "seconds",
    "x" = "X",
    "y" = "Y"
  ),
  .by = "tag"
)
#>    seconds           X           Y tag
#> 1     0.60 -0.26711990 -0.59840370   1
#> 2     1.65 -0.10311363  0.50638281   1
#> 3     2.65 -0.09548419  0.16530901   1
#> 4     3.65 -0.01592759 -0.28837860   1
#> 5     4.60  0.28795196  0.53248461   1
#> 6     0.60  0.07446149  0.04194506   2
#> 7     1.65 -0.24860377 -0.42394017   2
#> 8     2.65  0.72176228  0.20049239   2
#> 9     3.65  0.06384934  0.77397261   2
#> 10    4.60  0.48828897  0.38153518   2
```
