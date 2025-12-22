# Innovation step in the Kalman filter

Innovation step in the Kalman filter

## Usage

``` r
kf_innovation(z, x, P, H, R)
```

## Arguments

- z:

  Vector of measured values at time t + 1

- x:

  Vector of predicted values of the movement equation at time t + 1.

- P:

  Cholesky decomposition of the estimation covariance matrix at time t +
  1.

- H:

  Matrix relating the values in x to the values in y.

- R:

  Cholesky decomposition of the measurement noise covariance matrix.#'

## Value

Named list of the innovation (`"y"`), the Cholesky decomposition of its
covariance matrix (`"S"`), and the Kalman gain (`"K"`)

## Details

In the innovation step, we compute how much error we expect in the
measurement if the movement equation is correct in its prediction. The
expected "innovation" is defined as:

\$\$\mathbf{y}\_i = \mathbf{z}\_i - H \mathbf{x}\_i\$\$ where
\\\mathbf{z}\\ is the measurement, \\H\\ is the measurement matrix, and
\\\mathbf{x}\\ is the prediction obtained through the prediction step.
We also compute the covariance matrix for this innovation, which is
defined as:

\$\$\Sigma_i = H P_i H^T + R\$\$ where \\R\\ contains the (assumed)
measurement covariances. It is interesting to note that the value of
\\\Sigma\\ is always symmetric for each value of \\H\\. Whether its
Cholesky decomposition exists, however, will depend on both \\H\\ and
\\P\\.

In the final step, we compute the Kalman gain using both the covariance
of the prediction and the total covariance of the measurement process
through the following equation:

\$\$K_i = P_i H^T \Sigma_i^{-1}\$\$ As one may notice, the Kalman gain
is a measure of how much we can trust the prediction, specifically by
putting the prediction covariance over the total variance. It is thus
related to a measure of reliability.

## See also

[`kalman_filter`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md),
[`kf_predict`](https://github.com/ndpvh/denoiser/reference/kf_predict.md),
[`kf_update`](https://github.com/ndpvh/denoiser/reference/kf_update.md)
