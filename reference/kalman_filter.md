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
  \[kalman_filter()\] will assume that this information is contained
  within the columns \`"x"\`, \`"y"\`, and \`"time"\` respectively. If
  this isn't the case, either change the column names in the data or
  specify the \`cols\` argument.

- model:

  String denoting which model to use. Defaults to
  \`"constant_velocity"\`, and is currently the only one that is
  implemented.

- cols:

  Named vector or named list containing the relevant column names in
  'data' if they didn't contain the prespecified column names
  \`"time"\`, \`"x"\`, and \`"y"\`. The labels should conform to these
  prespecified column names and the values given to these locations
  should contain the corresponding column names in that dataset.
  Defaults to \`NULL\`, therefore assuming the structure explained in
  \`data\`.

- .by:

  String denoting whether the moving window should be taken with respect
  to a given grouping variable. Defaults to \`NULL\`.

- N_min:

  Integer denoting the minimum number of datapoints that are needed to
  use the Kalman filter. Defaults to `5`.

- ...:

  Additional arguments provided to the loaded model. For more
  information, see \[constant_velocity\].

## Value

Smoothed dataframe with a similar structure as \`data\`

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
#> 1         1   9.9474480  -0.05207172   1
#> 2         2   9.8093754   1.19438825   1
#> 3         3   9.5856083   2.44772171   1
#> 4         4   9.3317320   3.72697734   1
#> 5         5   8.6637366   4.97995796   1
#> 6         6   8.0753284   5.97680945   1
#> 7         7   7.1192981   7.12637439   1
#> 8         8   6.0614256   7.78080050   1
#> 9         9   5.1219970   8.29906730   1
#> 10       10   4.1117189   9.05157970   1
#> 11       11   2.8775367   9.51449460   1
#> 12       12   1.7234749   9.97031313   1
#> 13       13   0.6089901   9.84138699   1
#> 14       14  -0.8743112   9.93507820   1
#> 15       15  -1.9855895   9.78875460   1
#> 16       16  -3.4093392   9.21601882   1
#> 17       17  -4.3293656   9.04436571   1
#> 18       18  -5.6749145   8.18532239   1
#> 19       19  -6.4449377   7.59907240   1
#> 20       20  -7.3810844   6.80699744   1
#> 21       21  -8.3230939   5.67262885   1
#> 22       22  -9.0005368   4.57105340   1
#> 23       23  -9.4038470   3.44692379   1
#> 24       24  -9.6748834   2.23452444   1
#> 25       25 -10.0040234   0.93328029   1
#> 26       26  -9.9050634  -0.26251883   1
#> 27       27  -9.8909493  -1.59708001   1
#> 28       28  -9.7074784  -2.89889841   1
#> 29       29  -9.2587716  -4.17368632   1
#> 30       30  -8.5539353  -5.09016380   1
#> 31       31  -7.7737721  -6.00625589   1
#> 32       32  -7.1281158  -7.06602988   1
#> 33       33  -6.1733728  -7.85901741   1
#> 34       34  -5.1446529  -8.64820616   1
#> 35       35  -3.9151913  -9.33257357   1
#> 36       36  -2.5819023  -9.75584810   1
#> 37       37  -1.3429399  -9.95387314   1
#> 38       38  -0.1747087 -10.06790854   1
#> 39       39   1.1676734  -9.96122475   1
#> 40       40   2.2830356  -9.55323581   1
#> 41       41   3.6548383  -9.44148565   1
#> 42       42   4.7274031  -8.83580943   1
#> 43       43   5.8229152  -8.15144570   1
#> 44       44   6.7144405  -7.44160067   1
#> 45       45   7.5390169  -6.39023646   1
#> 46       46   8.4522167  -5.39444846   1
#> 47       47   8.9588102  -4.29277823   1
#> 48       48   9.4843859  -3.21205147   1
#> 49       49   9.8562503  -1.80616255   1
#> 50       50   9.9541461  -0.71048384   1
#> 51        1   9.9884168   0.70092642   2
#> 52        2   9.8918772   1.90063591   2
#> 53        3   9.4436070   3.13273724   2
#> 54        4   8.9195263   4.14718505   2
#> 55        5   8.4652431   5.42362892   2
#> 56        6   7.7371479   6.36004217   2
#> 57        7   6.6668050   7.38118245   2
#> 58        8   5.8993541   8.28699222   2
#> 59        9   4.7732315   8.85578776   2
#> 60       10   3.6479885   9.18778353   2
#> 61       11   2.3465682   9.71077139   2
#> 62       12   1.0157326   9.99257248   2
#> 63       13  -0.1964853  10.05635266   2
#> 64       14  -1.4078012   9.98662248   2
#> 65       15  -2.6233751   9.70932990   2
#> 66       16  -3.6178819   9.20993719   2
#> 67       17  -5.2112412   8.48453009   2
#> 68       18  -6.0227506   7.85286628   2
#> 69       19  -7.0482624   7.21006338   2
#> 70       20  -7.9268383   6.24609476   2
#> 71       21  -8.5873641   5.12646782   2
#> 72       22  -9.1208905   4.10155063   2
#> 73       23  -9.6581791   2.72529516   2
#> 74       24  -9.7642776   1.60264094   2
#> 75       25 -10.0169551   0.26519298   2
#> 76       26 -10.1206891  -0.85995866   2
#> 77       27  -9.9082684  -2.25377436   2
#> 78       28  -9.6031200  -3.46748595   2
#> 79       29  -8.9674583  -4.62687837   2
#> 80       30  -8.2511809  -5.73286318   2
#> 81       31  -7.3541441  -6.62603786   2
#> 82       32  -6.3333424  -7.50940859   2
#> 83       33  -5.3070399  -8.27289449   2
#> 84       34  -4.5397648  -9.18727828   2
#> 85       35  -3.2714309  -9.42684972   2
#> 86       36  -2.1240058  -9.64801309   2
#> 87       37  -0.8721825  -9.83128956   2
#> 88       38   0.4028689  -9.88417392   2
#> 89       39   1.8032380  -9.78665995   2
#> 90       40   2.9490821  -9.44345321   2
#> 91       41   4.0041856  -8.96235866   2
#> 92       42   5.2121677  -8.46128490   2
#> 93       43   6.1067607  -7.54935640   2
#> 94       44   7.2746611  -6.88409394   2
#> 95       45   8.1114028  -5.79633930   2
#> 96       46   8.7437363  -4.90887482   2
#> 97       47   9.3730833  -3.56839622   2
#> 98       48   9.6458881  -2.54944837   2
#> 99       49   9.9795349  -1.32036046   2
#> 100      50  10.0030263   0.08295978   2
```
