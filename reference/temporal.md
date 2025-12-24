# Add temporal error to data

Error is generated through a vector autoregressive model with its
defining parameters parameters `intercept`, `transition`, and
`covariance`, which should be specified by the user. Note that the
temporal component of this model is defined on the residual level (i.e.,
residuals carry over over time), not on the data level (positions are
not carried over over time). See the details for more information.

## Usage

``` r
temporal(
  data,
  intercept = c(0, 0),
  transition = matrix(c(0.925, 0.085, 0.085, 0.87), nrow = 2, ncol = 2),
  covariance = matrix(c(0.031^2, 0.02, 0.02, 0.027^2), nrow = 2, ncol = 2),
  sampling_rate = 6.13
)
```

## Arguments

- data:

  A data.frame containing the data on which to base the parameters of
  the constant velocity model. This function assumes that this
  data.frame contains the columns `"time"`, `"x"`, and `"y"` containing
  the time at which the observed position (x, y) was measured
  respectively.

- intercept:

  Numeric vector with 1 or 2 values containing the intercept of the
  vector autoregressive model.If only 1 number is provided, then this
  value will be assumed to represent the intercept for both the x- and
  y- dimensions. Defaults to `c(0, 0)`, representing no bias in the
  system.

- transition:

  Numeric matrix of dimensionality \\2 \times 2\\ having the
  autoregressive effects on the diagonal and crossregressive effects on
  the off-diagonal. Defaults to the autoregressive effects being equal
  to `0.925` and `0.87` for the x- and y-dimension respectively, and the
  cross-regressive effects being equal to `0.085` in a symmetric way.
  These values represent the means of these parameters as found across
  the four days of the calibration study that informed this project.

- covariance:

  Numeric matrix of dimensionality \\2 \times 2\\, having the variances
  of the errors for x and y on the diagonal and the covariance of the
  errors on the off-diagonal. Defaults to having the variances of the x-
  and y-dimension being equal to `0.031^2` and `0.027^2` respectively,
  and the covariance being equal to `0.02`. These values represent the
  means of the respective variances and covariances found across the
  four days of the calibration study that informed this project.

- sampling_rate:

  Numeric denoting the sampling rate in Hz. Is used to scale the
  transition matrix according to the actual sampling rate. Defaults to
  `6.13`, which is the mean sampling rate for the data obtained across
  the four days of the calibration study that informed this project. If
  you change the `transition` argument, it is recommended to ignore this
  argument.

## Value

A `data.frame` in which the `"x"` and `"y"` columns have additional
noise in them.

## Details

According to this function, the observed positions \\\mathbf{y}\_i\\ at
time \\t_i\\ contain error that in itself is temporally related, that is
carried over over time. Specifically, we assume that the error
\\\mathbf{\epsilon}\_i\\ at time \\t_i\\ depends on the error
\\\mathbf{\epsilon}\_{i - 1}\\ at previous time \\t\_{i - 1}\\ and a
white noise residual at the same timepoint, as specified in the vector
autoregressive model. In symbols:

\$\$\mathbf{\epsilon}\_i = \mathbf{\delta} + \Theta
\mathbf{\epsilon}\_{i - 1} + \mathbf{\omega}\_i\$\$

with

\$\$\mathbf{\omega}\_i \sim N(\mathbf{0}, \Sigma)\$\$ where
\\\mathbf{\delta}\\ represents the intercept of the model, \\\Theta\\ is
the transition matrix defining the temporal carry-over, and \\\Sigma\\
is the covariance matrix of the white noise residuals
\\\mathbf{\omega}\\. Note that for the vector autoregressive model, the
mean of the process is defined as:

\$\$\mathbf{\mu} = (I - \Theta)^{-1} \mathbf{\delta}\$\$ which is useful
to keep in mind when specifying the intercept to add bias to the system.
Furthermore note that the covariance \\\Sigma\_\epsilon\\ of the process
\\\mathbf{\epsilon}\\ is defined as:

\$\$\Sigma\_\epsilon = (I - \Theta)^{-2} \Sigma\$\$ which is useful to
keep in mind when specifying the covariance matrix \\\Sigma\\, which is
defined on the level of \\\mathbf{\omega}\\.

Once the errors \\\mathbf{\epsilon}\_i\\ are defined, we compute the
observed positions \\\mathbf{y}\_i\\ as consisting of a systematic
component (i.e., the latent positions, provided in `data`) and the
unsystematic error component so that:

\$\$\mathbf{y}\_i = \mathbf{x}\_i + \mathbf{\epsilon}\_i\$\$

## See also

[`noiser()`](https://github.com/ndpvh/denoiser/reference/noiser.md)
[`independent()`](https://github.com/ndpvh/denoiser/reference/independent.md)

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
# dimension and a transition matrix containing autoregressive effects of 0.15
temporal(
  data,
  intercept = c(0, 0),
  transition = diag(2) * 0.15,
  covariance = diag(2) * 0.01
) |>
  head()
#>           x          y time
#> 1 10.144916 0.03585909    1
#> 2 10.020436 1.26840390    2
#> 3  9.745068 2.62655598    3
#> 4  9.253334 3.77124487    4
#> 5  8.636802 4.90249433    5
#> 6  8.095415 5.85217640    6
```
