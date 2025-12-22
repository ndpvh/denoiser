# Updating step in the Kalman filter

Updating step in the Kalman filter

## Usage

``` r
kf_update(x, P, y, H, K)
```

## Arguments

- x:

  Vector of predicted values of the movement equation at time t + 1.

- P:

  Cholesky decomposition of the estimation covariance matrix at time t +
  1.

- y:

  Vector of innovations at time t + 1

- H:

  Measurement matrix connecting measurement to movement.

- K:

  Kalman gain

## Value

List containing the smoothed value of \\x\\ (`"x"`) together with the
Cholesky decomposition of its covariance (`"P"`)

## Details

In the update step, we use the measurement innovation \\\mathbf{y}\_i\\
and the predicted value \\\mathbf{x}\_i\\ and combine both in a guess of
what the latent state of the system should be. For this, we use the
following equation:

\$\$\hat{\mathbf{x}}\_i = \mathbf{x}\_i + K \mathbf{y}\$\$ where
\\\mathbf{x}\\ is the prediction coming from the prediction step,
\\\mathbf{y}\\ is the innovation derived in the innovation step, \\K\\
is the Kalman gain, and \\\hat{\mathbf{x}}\\ is the latent state of the
system.

We also compute the covariance of this update:

\$\$\hat{P}\_i = (I - K H) P_i\$\$ where I is the identity matrix, \\H\\
is the measurement matrix, \\K\\ is the Kalman gain, \\P_i\\ is the
covariance of the prediction derived in the prediction step, and
\\\hat{P}\_i\\ is the estimated certainty around the guess
\$\$\hat{\mathbf{x}}\_i\$\$.

Note that the values \$\$\hat{\mathbf{x}}\_i\$\$ and \\\hat{P}\_i\\ are
used as initial conditions for the next time step \\t\_{i + 1}\\,
therefore serving as input in the prediction step and starting the cycle
all over again.

## See also

[`kalman_filter`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md),
[`kf_predict`](https://github.com/ndpvh/denoiser/reference/kf_predict.md),
[`kf_innovation`](https://github.com/ndpvh/denoiser/reference/kf_innovation.md)
