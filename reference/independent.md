# Add independent error to data

Error is generated through a multivariate normal distribution with a
`mean` and `covariance` that are specified by the user. Primary
assumption of this model is that the errors are independent over time,
which stands in contrast to the
[`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)
model.

## Usage

``` r
independent(
  data,
  mean = c(0, 0),
  covariance = matrix(c(0.031^2, 0.02, 0.02, 0.027^2), nrow = 2, ncol = 2)
)
```

## Arguments

- data:

  A data.frame containing the data on which to base the parameters of
  the constant velocity model. This function assumes that this
  data.frame contains the columns `"time"`, `"x"`, and `"y"` containing
  the time at which the observed position (x, y) was measured
  respectively.

- mean:

  Numeric vector with 1 or 2 values containing the mean of the error
  process. If only 1 number is provided, then this value will be assumed
  to represent the mean for both the x- and y-dimensions. Defaults to
  `c(0, 0)`, representing no bias in the system.

- covariance:

  Numeric matrix of dimensionality \\2 \times 2\\, having the variances
  of the errors for x and y on the diagonal and the covariance of the
  errors on the off-diagonal. Defaults to having the variances of the x-
  and y-dimension being equal to `0.031^2` and `0.027^2` respectively,
  and the covariance being equal to `0.02`. These values represent the
  means of the respective variances and covariances found across the
  four days of the calibration study that informed this project.

## Value

A `data.frame` in which the `"x"` and `"y"` columns have additional
noise in them.

## Details

According to this function, the observed positions \\\mathbf{y}\_i\\ at
time \\t_i\\ contain some white noise error. In symbols, this comes down
to saying that:

\$\$\mathbf{\epsilon}\_{i} \sim N(\mathbf{\mu}, \Sigma)\$\$ where
\\\mathbf{\mu}\\ represents the mean of the noise and \\\Sigma\\ the
covariance matrix of the noise. The observed positions \\\mathbf{y}\_i\\
then consist of a systematic component (i.e., the latent positions,
provided in `data`) and an unsystematic error component so that:

\$\$\mathbf{y}\_i = \mathbf{x}\_i + \mathbf{\epsilon}\_i\$\$

## See also

[`noiser()`](https://github.com/ndpvh/denoiser/reference/noiser.md)
[`temporal()`](https://github.com/ndpvh/denoiser/reference/temporal.md)

## Examples

``` r
# Generate data for illustration purposes. Movement in circular motion at a
# pace of 1.27m/s with some added noise of SD = 10cm.
angles <- seq(0, 4 * pi, length.out = 100)
coordinates <- 10 * cbind(cos(angles), sin(angles))

data <- data.frame(
  x = coordinates[, 1],
  y = coordinates[, 2],
  time = 1:100
)

# Add independent noise to these data with an error variance of 0.01 in each
# dimension
independent(
  data,
  mean = c(0, 0),
  covariance = diag(2) * 0.01
) |>
  head()
#>           x           y time
#> 1 10.052080 -0.05062863    1
#> 2  9.983450  1.15492765    2
#> 3  9.743076  2.41660930    3
#> 4  9.273021  3.76430893    4
#> 5  8.620802  4.78244720    5
#> 6  8.007963  5.95251198    6
```
