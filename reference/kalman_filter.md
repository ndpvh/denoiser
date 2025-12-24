# Smooth using a Kalman filter

This is a higher-level function that will first look at whether the data
needs to be processed by a given variable. Then it will run the Kalman
filter on these grouped data.

## Usage

``` r
kalman_filter(
  data,
  model = "constant_velocity",
  cols = NULL,
  .by = NULL,
  N_min = 5,
  ...
)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default,
  `kalman_filter()` will assume that this information is contained
  within the columns `"x"`, `"y"`, and `"time"` respectively. If this
  isn't the case, either change the column names in the data or specify
  the `cols` argument.

- model:

  String denoting which model to use. Defaults to `"constant_velocity"`,
  and is currently the only one that is implemented.

- cols:

  Named vector or named list containing the relevant column names in
  `data` if they didn't contain the prespecified column names `"time"`,
  `"x"`, and `"y"`. The labels should conform to these prespecified
  column names and the values given to these locations should contain
  the corresponding column names in that dataset. Defaults to `NULL`,
  therefore assuming the structure explained in `data`.

- .by:

  String denoting whether the moving window should be taken with respect
  to a given grouping variable. Defaults to `NULL`.

- N_min:

  Integer denoting the minimum number of datapoints that are needed to
  use the Kalman filter. Defaults to `5`.

- ...:

  Additional arguments provided to the loaded model. For more
  information, see
  [`constant_velocity()`](https://github.com/ndpvh/denoiser/reference/constant_velocity.md).

## Value

Smoothed dataframe with a similar structure as `data`

## See also

[`kf_predict`](https://github.com/ndpvh/denoiser/reference/kf_predict.md),
[`kf_innovation`](https://github.com/ndpvh/denoiser/reference/kf_innovation.md),
[`kf_update`](https://github.com/ndpvh/denoiser/reference/kf_update.md)

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

# Use the Kalman filter with the constant velocity model on these data to 
# filter out the measurement error. Provide an assumed variance of 0.01 
# to this model
kalman_filter(
  data,
  model = "constant_velocity",
  cols = c(
    "time" = "seconds",
    "x" = "X",
    "y" = "Y"
  ),
  .by = "tag",
  error = 0.01
)
#>     seconds           X            Y tag
#> 1         1   9.9151568   0.08029847   1
#> 2         2   9.8977853   1.21728759   1
#> 3         3   9.5289740   2.62940762   1
#> 4         4   9.3054389   3.84292418   1
#> 5         5   8.7453962   4.93205346   1
#> 6         6   8.0896628   5.92753836   1
#> 7         7   7.3986307   6.93167244   1
#> 8         8   6.4514374   7.78818956   1
#> 9         9   5.1811633   8.36494630   1
#> 10       10   4.2519222   9.15383405   1
#> 11       11   2.9768293   9.55440910   1
#> 12       12   1.5637146   9.85839206   1
#> 13       13   0.3762799   9.92578539   1
#> 14       14  -0.8154102   9.92128202   1
#> 15       15  -2.1439933   9.79130050   1
#> 16       16  -3.0067104   9.36755232   1
#> 17       17  -4.2966808   9.09401797   1
#> 18       18  -5.4051533   8.45151542   1
#> 19       19  -6.5843871   7.70422169   1
#> 20       20  -7.5420433   6.66259933   1
#> 21       21  -8.2898657   5.60906285   1
#> 22       22  -8.7699853   4.56038698   1
#> 23       23  -9.3452168   3.29021093   1
#> 24       24  -9.9632849   1.96756314   1
#> 25       25  -9.9583908   0.80766054   1
#> 26       26  -9.9103413  -0.29258672   1
#> 27       27  -9.8007807  -1.54860775   1
#> 28       28  -9.5409408  -2.81152341   1
#> 29       29  -9.2859264  -4.02020733   1
#> 30       30  -8.6054638  -4.94494367   1
#> 31       31  -7.8194433  -6.09119926   1
#> 32       32  -7.0650873  -7.25731096   1
#> 33       33  -6.1194194  -7.95410987   1
#> 34       34  -4.7635514  -8.57108653   1
#> 35       35  -3.8747359  -9.16885189   1
#> 36       36  -2.7117831  -9.72589140   1
#> 37       37  -1.3730188  -9.90658376   1
#> 38       38  -0.3469783 -10.05111519   1
#> 39       39   0.9075940 -10.03151668   1
#> 40       40   2.4068679  -9.70672701   1
#> 41       41   3.6494985  -9.29851047   1
#> 42       42   4.6443824  -8.68500018   1
#> 43       43   5.8888671  -8.12058100   1
#> 44       44   6.8827600  -7.25526955   1
#> 45       45   7.5296513  -6.46133126   1
#> 46       46   8.4449867  -5.43672465   1
#> 47       47   9.0853555  -4.26142220   1
#> 48       48   9.4725635  -2.97697250   1
#> 49       49   9.7956667  -1.71884275   1
#> 50       50   9.9525882  -0.58709987   1
#> 51        1   9.8651579   0.70485040   2
#> 52        2   9.7079514   2.09027374   2
#> 53        3   9.7043543   3.12673820   2
#> 54        4   8.9469322   4.32077717   2
#> 55        5   8.4555114   5.43452156   2
#> 56        6   7.6592202   6.33121444   2
#> 57        7   6.7187322   7.34187304   2
#> 58        8   5.6531618   8.36783365   2
#> 59        9   4.6824035   8.83665865   2
#> 60       10   3.3974790   9.25531118   2
#> 61       11   2.3510635   9.60153921   2
#> 62       12   1.0317417   9.76460015   2
#> 63       13  -0.2506073  10.00372948   2
#> 64       14  -1.4171597  10.01731045   2
#> 65       15  -2.5414367   9.67643137   2
#> 66       16  -3.7901958   9.12072605   2
#> 67       17  -4.9470769   8.72450828   2
#> 68       18  -6.1615814   7.88052334   2
#> 69       19  -7.0722978   7.16919946   2
#> 70       20  -7.9327073   6.22158578   2
#> 71       21  -8.5999596   4.97568523   2
#> 72       22  -9.1460297   3.81601455   2
#> 73       23  -9.6679800   2.85306412   2
#> 74       24  -9.9311520   1.71954472   2
#> 75       25 -10.0565810   0.40208171   2
#> 76       26  -9.8404706  -0.99122509   2
#> 77       27  -9.7342038  -2.10813265   2
#> 78       28  -9.3749113  -3.39406211   2
#> 79       29  -8.7863879  -4.67606000   2
#> 80       30  -8.3638499  -5.52512554   2
#> 81       31  -7.4210673  -6.76972208   2
#> 82       32  -6.6029999  -7.54668613   2
#> 83       33  -5.5120631  -8.30005515   2
#> 84       34  -4.4185389  -9.10812131   2
#> 85       35  -3.3664229  -9.31556811   2
#> 86       36  -2.0459355  -9.72949857   2
#> 87       37  -0.7028244  -9.90708084   2
#> 88       38   0.4386379 -10.07787007   2
#> 89       39   1.8290882  -9.86427398   2
#> 90       40   2.9138308  -9.64341053   2
#> 91       41   4.0064783  -8.98985147   2
#> 92       42   5.1340754  -8.44902745   2
#> 93       43   6.1719807  -7.67809286   2
#> 94       44   7.1642240  -6.90788327   2
#> 95       45   8.0074158  -5.99211749   2
#> 96       46   8.8762983  -4.89778730   2
#> 97       47   9.4545134  -3.73901913   2
#> 98       48   9.7999266  -2.45091276   2
#> 99       49   9.9074525  -1.39166022   2
#> 100      50   9.9826517  -0.13231075   2
```
