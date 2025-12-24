# Filter the data

The `denoiser()` function takes in a dataset and attempts to filter out
the inherent measurement error. The function makes use of two steps: The
data will go through a Kalman filter and will then be binned, both
according to the specifications of the user (see
[`kalman_filter()`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md)
and [`bin()`](https://github.com/ndpvh/denoiser/reference/bin.md)). Note
that only the first step is mandatory and that it's left up to the user
whether they would also like to bin their data through specifying the
argument `binned`.

## Usage

``` r
denoiser(
  data,
  cols = NULL,
  .by = NULL,
  binned = FALSE,
  span = 0.5,
  fx = mean,
  ...
)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default,
  `denoiser()` will assume that this information is contained within the
  columns `"x"`, `"y"`, and `"time"` respectively. If this isn't the
  case, either change the column names in the data or specify the `cols`
  argument.

- cols:

  Named vector or named list containing the relevant column names in
  `data` if they do not conform to the prespecified column names
  `"time"`, `"x"`, and `"y"`. The labels should conform to these
  prespecified column names and the values given to these locations
  should contain the corresponding column names in that dataset.
  Defaults to `NULL`, therefore assuming the structure explained in
  `data`.

- .by:

  String denoting whether the moving window should be taken with respect
  to a given grouping variable. Defaults to `NULL`.

- binned:

  Logical denoting whether to also bin the data (`TRUE`) or to leave the
  data unbinned (`FALSE`). Defaults to `FALSE`.

- span:

  Numeric denoting the size of the bins. Will pertain to the values in
  the `"time"` variable. Defaults to `0.5`. Ignored when `binned` is
  `FALSE`.

- fx:

  Function to execute on the data that falls within the bin. Will be
  executed on the `"x"` and `"y"` columns separately and should ouput
  only a single value. Defaults to the function
  [`mean()`](https://rdrr.io/r/base/mean.html). Ignored when `binned` is
  `FALSE`.

- ...:

  Additional arguments defining the Kalman filter to employ for
  filtering. See
  [`kalman_filter()`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md).

## Value

Smoothed and/or binned `data.frame` with a similar structure as `data`

## See also

[`bin()`](https://github.com/ndpvh/denoiser/reference/bin.md)
[`kalman_filter()`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md)
[`noiser()`](https://github.com/ndpvh/denoiser/reference/noiser.md)

## Examples

``` r
# Generate data for illustration purposes. Movement in circular motion at a
# pace of 1.27m/s with some added noise of SD = 10cm.
angles <- seq(0, 4 * pi, length.out = 100)
coordinates <- 10 * cbind(cos(angles), sin(angles))
coordinates <- coordinates + rnorm(200, mean = 0, sd = 0.1)

data <- data.frame(
  X = coordinates[, 1],
  Y = coordinates[, 2],
  seconds = rep(1:50, times = 2),
  tag = rep(1:2, each = 50)
)

# Use the denoiser function to get rid of the noise. Kalman filter is 
# defined with the constant velocity model and an error variance of 0.01. 
# Binning is performed with a span of 5 seconds and using the mean of the 
# interval as representatitive of the position within that interval.
denoiser(
  data,
  cols = c(
    "time" = "seconds",
    "x" = "X",
    "y" = "Y"
  ),
  .by = "tag",
  model = "constant_velocity",
  error = 0.01,
  binned = TRUE,
  span = 5,
  fx = mean
)
#>    seconds          X         Y tag
#> 1      3.5  9.2877399  3.068721   1
#> 2      9.0  5.1192208  8.402175   1
#> 3     14.0 -0.7479721  9.783390   1
#> 4     19.0 -6.4362481  7.461191   1
#> 5     24.0 -9.6951022  2.092571   1
#> 6     29.0 -8.9716957 -3.966425   1
#> 7     34.0 -4.9764325 -8.494692   1
#> 8     39.0  1.0090269 -9.708284   1
#> 9     44.0  6.6636493 -7.232362   1
#> 10    48.5  9.6249569 -2.503712   1
#> 11     3.5  9.0185592  3.648907   2
#> 12     9.0  4.6772568  8.664695   2
#> 13    14.0 -1.4158817  9.650819   2
#> 14    19.0 -6.9792837  6.935121   2
#> 15    24.0 -9.7608758  1.594803   2
#> 16    29.0 -8.7333699 -4.578267   2
#> 17    34.0 -4.2904950 -8.745307   2
#> 18    39.0  1.6268184 -9.691017   2
#> 19    44.0  7.0856512 -6.801369   2
#> 20    48.5  9.7624910 -1.889712   2
```
