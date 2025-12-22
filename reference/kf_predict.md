# Prediction step in the Kalman filter

Prediction step in the Kalman filter

## Usage

``` r
kf_predict(
  x0,
  P0,
  F,
  W,
  u = matrix(0, nrow = length(x0), ncol = 1),
  B = matrix(0, nrow = length(u), ncol = length(u))
)
```

## Arguments

- x0:

  Vector of values of the movement equation at time t.

- P0:

  Cholesky decomposition of the covariance of x0 at time t.

- F:

  Transition matrix, relating values of X at time t to those at t.

- W:

  Cholesky decomposition of the process noise covariance matrix.

- u:

  Vector of values for the external variables at time t. By default an
  empty vector.

- B:

  Matrix that connects the external variables in u to the values in x.
  By default an empty matrix.

## Value

Named list of predicted values for \\\mathbf{x}\\ (`"x"`) and \\P\\
(`"P"`) at the next time point.

## Details

In this step, we use the movement equation to predict the new values of
x based on the initial condition defined by the location \\\mathbf{x}\\
and the covariance \\P\\ at time \\t\_{i - 1}\\, using the equation:

\$\$\mathbf{x}\_t = F_i \mathbf{x}\_{i - 1} + B_i \mathbf{u}\_i +
\mathbf{\epsilon}\_i\$\$ where \\F\\ is the movement transition matrix,
\\B\\ scales the external influences \\\mathbf{u}\\, and
\\\mathbf{\epsilon}\\ defines the error, and where all terms are defined
at the time point \\t_i\\.

The covariance \\P\\ is also updated based on this equation,
representing the certainty around the prediction \\\mathbf{x}\_i\\. This
covariance is updated through the following equation:

\$\$P_i = F_i P\_{i - 1} F_i^T + W_i\$\$ where \\W\\ represents the
covariance matrix of \\\epsilon\\.

For stability purposes, we use Cholesky decompositions of the covariance
matrices rather than the actual covariance matrices. This needs to be
taken into account when making your own model.

## See also

[`kalman_filter`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md),
[`kf_innovation`](https://github.com/ndpvh/denoiser/reference/kf_innovation.md),
[`kf_update`](https://github.com/ndpvh/denoiser/reference/kf_update.md)
