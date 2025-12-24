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
#>     seconds            X            Y tag
#> 1         1  10.00846039  -0.19019709   1
#> 2         2   9.85010147   1.24783407   1
#> 3         3   9.82770626   2.51657614   1
#> 4         4   9.25952296   3.76305095   1
#> 5         5   8.60195480   5.00022084   1
#> 6         6   8.13884984   5.89140457   1
#> 7         7   7.30857891   6.96685892   1
#> 8         8   6.42917395   7.72363884   1
#> 9         9   5.43807644   8.44589693   1
#> 10       10   4.13935796   9.02951960   1
#> 11       11   2.83145888   9.46222533   1
#> 12       12   1.85777338   9.85351616   1
#> 13       13   0.29476430  10.00993632   1
#> 14       14  -0.83413336   9.91067676   1
#> 15       15  -2.25777446   9.71607546   1
#> 16       16  -3.24180601   9.71927876   1
#> 17       17  -4.59407509   8.83612014   1
#> 18       18  -5.56306943   8.25782563   1
#> 19       19  -6.45803052   7.46662014   1
#> 20       20  -7.34489277   6.59179407   1
#> 21       21  -8.09305360   5.70788359   1
#> 22       22  -9.05134535   4.62015031   1
#> 23       23  -9.67681807   3.32424302   1
#> 24       24  -9.73435337   2.22240601   1
#> 25       25  -9.85172994   0.94452340   1
#> 26       26 -10.05984798  -0.45804127   1
#> 27       27  -9.91695847  -1.47360697   1
#> 28       28  -9.62099443  -2.70707615   1
#> 29       29  -9.14114097  -4.05199754   1
#> 30       30  -8.72724534  -5.21662982   1
#> 31       31  -7.79390962  -6.36369619   1
#> 32       32  -7.24825350  -7.24243455   1
#> 33       33  -6.06968803  -7.85469322   1
#> 34       34  -5.04538488  -8.80432272   1
#> 35       35  -3.89291457  -9.38287200   1
#> 36       36  -2.60877190  -9.56531012   1
#> 37       37  -1.44242000  -9.79097840   1
#> 38       38  -0.13671592 -10.01708621   1
#> 39       39   1.11996410  -9.78778607   1
#> 40       40   2.38492754  -9.73750286   1
#> 41       41   3.72549894  -9.25336037   1
#> 42       42   4.78266757  -8.77351388   1
#> 43       43   5.79518211  -8.27397135   1
#> 44       44   6.77056712  -7.42813277   1
#> 45       45   7.68772805  -6.65474234   1
#> 46       46   8.46694739  -5.42427628   1
#> 47       47   8.97442853  -4.15371191   1
#> 48       48   9.59373734  -3.26029519   1
#> 49       49   9.75380815  -1.75274441   1
#> 50       50   9.85312616  -0.70346623   1
#> 51        1  10.05126177   0.60369621   2
#> 52        2   9.77885533   1.91838735   2
#> 53        3   9.47554283   3.06145685   2
#> 54        4   8.99437344   4.26771187   2
#> 55        5   8.53359338   5.39385684   2
#> 56        6   7.62104412   6.50949509   2
#> 57        7   6.89693115   7.32209922   2
#> 58        8   5.82355019   8.35921421   2
#> 59        9   4.58800389   8.92900460   2
#> 60       10   3.43812030   9.41687410   2
#> 61       11   2.14548302   9.60083460   2
#> 62       12   1.09603021   9.96913341   2
#> 63       13  -0.08774125   9.94972035   2
#> 64       14  -1.46833544  10.02561581   2
#> 65       15  -2.49243070   9.64650443   2
#> 66       16  -3.65933096   9.18503485   2
#> 67       17  -4.95573053   8.59229460   2
#> 68       18  -6.11427970   7.81060885   2
#> 69       19  -7.10013148   7.26867045   2
#> 70       20  -7.82373334   6.15339512   2
#> 71       21  -8.72533011   5.13182042   2
#> 72       22  -9.20538140   4.13367937   2
#> 73       23  -9.60897564   2.68781744   2
#> 74       24 -10.07366486   1.51955869   2
#> 75       25 -10.09953632   0.24780032   2
#> 76       26  -9.91521017  -1.13500388   2
#> 77       27  -9.76030496  -2.23105796   2
#> 78       28  -9.40718840  -3.45239536   2
#> 79       29  -8.89346028  -4.60792619   2
#> 80       30  -8.30950471  -5.62623442   2
#> 81       31  -7.56613314  -6.71294954   2
#> 82       32  -6.62888104  -7.55439520   2
#> 83       33  -5.71666166  -8.39997287   2
#> 84       34  -4.48705556  -9.17707980   2
#> 85       35  -3.47142796  -9.47876126   2
#> 86       36  -1.78061990  -9.70155972   2
#> 87       37  -0.63509818 -10.06431696   2
#> 88       38   0.47970186 -10.04429728   2
#> 89       39   1.80814107  -9.94147224   2
#> 90       40   2.84538229  -9.70007570   2
#> 91       41   4.13499479  -9.11686444   2
#> 92       42   5.21349980  -8.34132206   2
#> 93       43   6.42920609  -7.65898807   2
#> 94       44   7.26664264  -7.01497622   2
#> 95       45   7.88473508  -6.02402791   2
#> 96       46   8.65132057  -4.55659584   2
#> 97       47   9.27082631  -3.81538542   2
#> 98       48   9.64981530  -2.58688901   2
#> 99       49   9.90377589  -1.28671097   2
#> 100      50   9.87959142   0.07365152   2
```
