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
`noiser()`

## Examples
