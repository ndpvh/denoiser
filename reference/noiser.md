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
  [`denoiser()`](https://github.com/ndpvh/denoiser/reference/denoiser.md)
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

  String denoting the model to be used for noising up the data. Either
  `"independent"` or `"temporal"`, calling the
  [`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md)
  or
  [`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)
  model respectively. Defaults to `"temporal"`.

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
[`denoiser()`](https://github.com/ndpvh/denoiser/reference/denoiser.md)
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
#>   seconds        X          Y tag
#> 1       1 9.926674 0.01037486   1
#> 2       2 9.961569 1.19556831   1
#> 3       3 9.705025 2.66122127   1
#> 4       4 9.320603 3.68634187   1
#> 5       5 8.617249 4.72428423   1
#> 6       6 8.097239 6.01739631   1
```
