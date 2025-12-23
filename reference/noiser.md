# Add noise to the data

The `noiser()` function takes in a dataset and adds measurement error to
it. To do this, it currently makes use of one of two potential
measurement models: One in which the measurement error is independent
over time (`independent()`) and one in which measurement error does
depend on time (`temporal()`).

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
  `"independent"` or `"temporal"`, calling the `independent()` or
  `temporal()` model respectively. Defaults to `"temporal"`.

- ...:

  Additional arguments provided to the measurement error models. For
  more information, see `independent()` or `temporal()`.

## Value

Noised up `data.frame` with a similar structure as `data`

## See also

`independent()`
[`denoiser()`](https://github.com/ndpvh/denoiser/reference/denoiser.md)
`temporal()`

## Examples
