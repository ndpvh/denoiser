# Add noise to the data

The `noiser()` function takes in a dataset and adds measurement error to
it. To do this, it currently makes use of one of two potential
measurement models: One in which the measurement error is independent
over time
([`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md))
and one in which measurement error does depend on time
([`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)).

## Usage

``` r
noiser(data, cols = NULL, .by = NULL, model = "temporal", ...)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default,
  [`denoiser()`](https://github.com/ndpvh/denoiser/reference/denoiser-function.md)
  will assume that this information is contained within the columns
  `"x"`, `"y"`, and `"time"` respectively. If this isn't the case,
  either change the column names in the data or specify the `cols`
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

- model:

  String or function denoting the model to be used for noising up the
  data. When providing a string, one will use one of the native
  measurement models of the package, in which case the value should
  either be `"independent"` or `"temporal"`, calling the
  [`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md)
  or
  [`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)
  model respectively. If a function, then it should take in at least the
  `data` and add noise to these `data` through using the default column
  names (see `data`). See the vignettes for more information on how to
  specify this function. Defaults to `"temporal"`.

- ...:

  Additional arguments provided to the measurement error models. For
  more information, see
  [`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md)
  or
  [`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md).

## Value

Noised up `data.frame` with a similar structure as `data`

## See also

[`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md)
[`denoiser()`](https://github.com/ndpvh/denoiser/reference/denoiser-function.md)
[`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)

## Examples

``` r
# Generate data for illustration purposes. Movement in circular motion at a
# pace of 1.27m/s with some added noise of SD = 10cm.
angles <- seq(0, 4 * pi, length.out = 100)
coordinates <- 10 * cbind(cos(angles), sin(angles))

data <- data.frame(
  X = coordinates[, 1],
  Y = coordinates[, 2],
  seconds = rep(1:50, times = 2),
  tag = rep(1:2, each = 50)
)

# Use the noiser function to add measurement error. We use the independent 
# measurement error model with independence between the x- and y-dimension 
# and with the measurement error variance being 0.01 in both dimensions
noiser(
  data,
  cols = c(
    "time" = "seconds",
    "x" = "X",
    "y" = "Y"
  ),
  .by = "tag",
  model = "independent",
  covariance = diag(2) * 0.01
) |>
  head()
#>   seconds         X         Y tag
#> 1       1 10.059094 0.1313144   1
#> 2       2  9.993758 1.2745259   1
#> 3       3  9.610136 2.4484947   1
#> 4       4  9.289626 3.7821316   1
#> 5       5  8.924883 4.8639067   1
#> 6       6  8.180153 5.9987063   1
```
