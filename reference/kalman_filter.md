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
#>     seconds            X           Y tag
#> 1         1   9.96441848  -0.1705298   1
#> 2         2   9.89835202   1.1722391   1
#> 3         3   9.74261706   2.4971025   1
#> 4         4   9.16012502   3.6857584   1
#> 5         5   8.60824557   4.8450859   1
#> 6         6   8.01548265   5.8077569   1
#> 7         7   7.24968204   6.7112955   1
#> 8         8   6.23799440   7.7504616   1
#> 9         9   5.41986974   8.5037822   1
#> 10       10   4.12916431   9.1438336   1
#> 11       11   2.83171403   9.6882997   1
#> 12       12   1.82155442   9.8113319   1
#> 13       13   0.54589171  10.0554772   1
#> 14       14  -0.67010719   9.9313425   1
#> 15       15  -1.88356215   9.7370969   1
#> 16       16  -3.28682682   9.3834708   1
#> 17       17  -4.57979172   8.8732272   1
#> 18       18  -5.41929481   8.3310339   1
#> 19       19  -6.73100534   7.5784950   1
#> 20       20  -7.49559447   6.6093853   1
#> 21       21  -8.44770929   5.5980350   1
#> 22       22  -8.86064296   4.8507368   1
#> 23       23  -9.55137623   3.2955417   1
#> 24       24  -9.77909897   2.1341571   1
#> 25       25  -9.86493201   0.8585384   1
#> 26       26  -9.88785120  -0.3944225   1
#> 27       27  -9.73115623  -1.5440568   1
#> 28       28  -9.75822515  -2.7808015   1
#> 29       29  -9.44111827  -4.1066520   1
#> 30       30  -8.55986164  -5.1189056   1
#> 31       31  -7.75732658  -6.1890105   1
#> 32       32  -7.07924362  -7.2690504   1
#> 33       33  -6.09812254  -7.8525459   1
#> 34       34  -5.02536124  -8.5512037   1
#> 35       35  -3.84265970  -9.2673386   1
#> 36       36  -2.81116534  -9.7192900   1
#> 37       37  -1.35543923 -10.0811844   1
#> 38       38  -0.39096140 -10.1149709   1
#> 39       39   1.09605282  -9.8360370   1
#> 40       40   2.31353866  -9.8625355   1
#> 41       41   3.54076502  -9.5010458   1
#> 42       42   4.78005696  -8.7414886   1
#> 43       43   5.78267466  -8.0383689   1
#> 44       44   6.80838021  -7.3639316   1
#> 45       45   7.67332071  -6.2768189   1
#> 46       46   8.44109441  -5.4251164   1
#> 47       47   9.18702948  -4.2090523   1
#> 48       48   9.56169228  -3.0783595   1
#> 49       49   9.81479334  -2.0196438   1
#> 50       50   9.96609162  -0.7152986   1
#> 51        1  10.00456562   0.4065482   2
#> 52        2   9.87290641   1.8711058   2
#> 53        3   9.44612788   3.2658462   2
#> 54        4   9.12239064   4.1594202   2
#> 55        5   8.34700440   5.5475992   2
#> 56        6   7.53345108   6.3600069   2
#> 57        7   6.85687654   7.3140198   2
#> 58        8   5.76325069   8.1804934   2
#> 59        9   4.69696714   8.7571197   2
#> 60       10   3.53304276   9.3122431   2
#> 61       11   2.47762636   9.7065087   2
#> 62       12   1.06784353  10.0208187   2
#> 63       13  -0.04804198   9.9755822   2
#> 64       14  -1.40147035  10.1121760   2
#> 65       15  -2.80079789   9.7532179   2
#> 66       16  -3.99557183   9.2990954   2
#> 67       17  -5.21349819   8.5429491   2
#> 68       18  -6.06981959   7.9881752   2
#> 69       19  -6.94517293   7.0775450   2
#> 70       20  -7.90700512   6.3084558   2
#> 71       21  -8.40872484   5.1441525   2
#> 72       22  -8.95807459   3.9699511   2
#> 73       23  -9.55165605   2.7483852   2
#> 74       24  -9.93343101   1.4319035   2
#> 75       25 -10.08106139   0.4578141   2
#> 76       26  -9.91847677  -0.9800456   2
#> 77       27  -9.90019239  -2.2093990   2
#> 78       28  -9.44143825  -3.2972076   2
#> 79       29  -8.90244636  -4.7131799   2
#> 80       30  -8.43591494  -5.7324424   2
#> 81       31  -7.55690447  -6.7385361   2
#> 82       32  -6.50862207  -7.7432575   2
#> 83       33  -5.54457511  -8.3548913   2
#> 84       34  -4.45013992  -8.9932883   2
#> 85       35  -3.27485861  -9.4767135   2
#> 86       36  -2.11975670  -9.7445769   2
#> 87       37  -0.90483052 -10.0145868   2
#> 88       38   0.39679254  -9.9861933   2
#> 89       39   1.56033198  -9.9228131   2
#> 90       40   2.92417964  -9.7664538   2
#> 91       41   3.95478243  -9.1251790   2
#> 92       42   5.54110264  -8.4107250   2
#> 93       43   6.46428676  -7.8569975   2
#> 94       44   7.24254940  -6.9559955   2
#> 95       45   8.12563159  -6.0218945   2
#> 96       46   8.61584929  -5.0122839   2
#> 97       47   9.26560946  -3.7362835   2
#> 98       48   9.62168983  -2.3545339   2
#> 99       49  10.04405694  -1.1623253   2
#> 100      50  10.02997376  -0.1129664   2
```
