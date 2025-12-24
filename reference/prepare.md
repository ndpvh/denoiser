# Prepare data for analysis

Function that is used internally to prepare data for analysis, it being
either binning
([`bin()`](https://github.com/ndpvh/denoiser/reference/bin.md)) or using
the Kalman filter
([`kalman_filter()`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md)).
This preparation consists of the following steps. First, this function
checks whether the provided data is actually a `data.frame`, which is
required for our functions to work properly. Then, this function
examines the column names of argument `cols`. When provided, it will
check whether they adhere to the required format and, if so, change the
column names of the data to the default ones used in this package (this
change is later undone in
[`finalize()`](https://github.com/ndpvh/denoiser/reference/finalize.md)).
Finally, this function check whether there is a grouping variable as
specified in `.by`, and if so prepares the data for this grouping.

## Usage

``` r
prepare(data, cols = NULL, .by = NULL)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default,
  `prepare()` will assume that this information is contained within the
  columns `"x"`, `"y"`, and `"time"` respectively. If this isn't the
  case, either change the column names in the data or specify the `cols`
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

## Value

Named list containing the prepared `data.frame` (under `"data"`), the
mapping of the user-specified and package-required column names (under
`"cols"`), and the values of the grouping variable (under `"group"`).

## See also

[`finalize()`](https://github.com/ndpvh/denoiser/reference/finalize.md)

## Examples

``` r
# Generate data for illustration purposes
data <- data.frame(
  X = rnorm(100),
  Y = rnorm(100),
  seconds = rep(1:50, times = 2) / 10,
  tag = rep(1:2, each = 50)
)

# Prepare the data for analysis
prepare(
  data,
  cols = c(
    "time" = "seconds",
    "x" = "X",
    "y" = "Y"
  ),
  .by = "tag"
)
#> $data
#>     time            x            y id
#> 1    0.1  0.358590886 -1.449155712  1
#> 2    0.2 -0.028995035 -0.791503959  1
#> 3    0.3  1.147042072 -0.504480733  1
#> 4    0.4  0.373588935  0.401826700  1
#> 5    0.5  0.323339211  0.971396469  1
#> 6    0.6 -0.829819320 -0.579663020  1
#> 7    0.7  1.394462582  1.604179789  1
#> 8    0.8 -0.191543577  0.225973337  1
#> 9    0.9  0.272277021 -0.514857122  1
#> 10   1.0 -1.081659008 -0.823788240  1
#> 11   1.1 -2.329399361  0.334415250  1
#> 12   1.2 -0.549625959 -0.093490765  1
#> 13   1.3 -0.072579991  0.304062078  1
#> 14   1.4  1.032288404 -0.476507534  1
#> 15   1.5  0.215138526 -0.241311717  1
#> 16   1.6 -0.494340125  0.824155833  1
#> 17   1.7  1.512138281 -1.555643970  1
#> 18   1.8 -0.579463264  0.093501283  1
#> 19   1.9  1.674789634 -0.366949421  1
#> 20   2.0 -1.000980259 -0.129408799  1
#> 21   2.1  1.222702835  0.407795520  1
#> 22   2.2  1.077188166 -0.583968954  1
#> 23   2.3 -0.611945460 -0.193449890  1
#> 24   2.4  0.506866968 -0.269546670  1
#> 25   2.5  0.460068373  0.073658232  1
#> 26   2.6  1.484391861  0.357236138  1
#> 27   2.7  0.881963226  0.550428418  1
#> 28   2.8 -0.536702239  0.038401793  1
#> 29   2.9  1.285553707 -1.609575292  1
#> 30   3.0  0.587848533 -1.049710115  1
#> 31   3.1 -1.308482026  2.052033974  1
#> 32   3.2  0.316726325  0.176436411  1
#> 33   3.3  1.194158303  1.128307358  1
#> 34   3.4  0.913057148  0.435001744  1
#> 35   3.5 -0.786752993  0.548833492  1
#> 36   3.6 -0.410929700  0.647418304  1
#> 37   3.7  0.476373682  0.878463454  1
#> 38   3.8  0.185915868  0.350797869  1
#> 39   3.9 -1.324716253  0.049879720  1
#> 40   4.0  1.172371055  0.835749446  1
#> 41   4.1  0.231492772 -0.281725199  1
#> 42   4.2  0.483071904 -0.791679461  1
#> 43   4.3 -0.535319580  0.001653727  1
#> 44   4.4  1.378135819 -1.187530126  1
#> 45   4.5 -1.302671671  0.362417465  1
#> 46   4.6  0.634857535 -0.549435319  1
#> 47   4.7  0.999655161  0.692949838  1
#> 48   4.8 -0.337748953 -0.060843916  1
#> 49   4.9 -0.086033607 -1.193540930  1
#> 50   5.0 -1.718817584 -0.119908059  1
#> 51   0.1 -0.929121572 -0.708107950  2
#> 52   0.2  0.813676046 -1.616663973  2
#> 53   0.3  0.526413546  0.495847824  2
#> 54   0.4  1.011957390  1.299750970  2
#> 55   0.5  0.831379809 -1.615985506  2
#> 56   0.6  0.415134145 -1.250367945  2
#> 57   0.7 -0.661257061  1.582132306  2
#> 58   0.8  0.548811286  1.252529118  2
#> 59   0.9 -0.539367800 -0.209395701  2
#> 60   1.0 -0.171318426 -0.639033687  2
#> 61   1.1 -0.766734605  0.398902937  2
#> 62   1.2 -0.606574846  1.341973500  2
#> 63   1.3  1.647312821 -0.037607422  2
#> 64   1.4  0.841069348  0.543670114  2
#> 65   1.5  0.338175097  1.740218394  2
#> 66   1.6 -0.404883076 -0.324455939  2
#> 67   1.7  0.900009039 -0.447511333  2
#> 68   1.8  1.190666655  0.416082526  2
#> 69   1.9 -0.047539083 -1.295865368  2
#> 70   2.0  0.786925425  0.682633090  2
#> 71   2.1  1.166684112  0.496913333  2
#> 72   2.2 -0.271823871  1.439660656  2
#> 73   2.3 -0.313704285  1.207358558  2
#> 74   2.4 -0.286300150  0.238514694  2
#> 75   2.5 -0.803440263 -0.298837878  2
#> 76   2.6 -0.094555455  1.384621050  2
#> 77   2.7 -0.074046506 -0.700069022  2
#> 78   2.8  0.714490683  1.860931509  2
#> 79   2.9  0.124718366  1.803924959  2
#> 80   3.0  1.296594339 -1.356043492  2
#> 81   3.1 -1.114492926 -0.314751072  2
#> 82   3.2 -0.842058813 -1.019265181  2
#> 83   3.3 -1.504294209 -0.612249656  2
#> 84   3.4 -0.284026455 -0.289068749  2
#> 85   3.5  0.042869041  1.506983292  2
#> 86   3.6 -0.008866413  0.367722694  2
#> 87   3.7 -2.949083784 -0.020034941  2
#> 88   3.8  0.020358254 -0.979921959  2
#> 89   3.9 -0.098446980 -1.400912333  2
#> 90   4.0  0.589109098  1.445014910  2
#> 91   4.1 -0.425751629 -0.423481621  2
#> 92   4.2  0.634658985 -0.733749597  2
#> 93   4.3 -0.578524902 -0.708484753  2
#> 94   4.4 -0.169109048  1.475092459  2
#> 95   4.5 -1.919232520  0.845004185  2
#> 96   4.6 -1.534266387  1.293994431  2
#> 97   4.7 -1.114761221  0.298161142  2
#> 98   4.8  1.597811635 -0.405682490  2
#> 99   4.9 -0.639805078 -0.138807578  2
#> 100  5.0  1.566690553 -0.222592731  2
#> 
#> $cols
#>      time         x         y        id 
#> "seconds"       "X"       "Y"     "tag" 
#> 
#> $group
#> [1] 1 2
#> 
```
