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
#>     time           x           y id
#> 1    0.1  1.31314355 -0.16481239  1
#> 2    0.2  0.08601352 -0.75096428  1
#> 3    0.3 -0.62985137 -1.25336629  1
#> 4    0.4  0.65507033 -1.03623626  1
#> 5    0.5  0.01939355 -0.02943857  1
#> 6    0.6  0.69626996 -0.27494378  1
#> 7    0.7  2.00886989  0.48545147  1
#> 8    0.8 -0.05697828  0.91698203  1
#> 9    0.9  0.24041550 -0.98534392  1
#> 10   1.0 -0.02189017 -1.49118975  1
#> 11   1.1 -0.83080816  0.81959245  1
#> 12   1.2  1.40247432  1.01340453  1
#> 13   1.3 -0.72386911  1.05360525  1
#> 14   1.4  1.33058037 -0.07142864  1
#> 15   1.5 -0.81133302  0.95244461  1
#> 16   1.6  1.79503611 -0.38403752  1
#> 17   1.7  0.68662633 -0.41775999  1
#> 18   1.8  0.08937800 -0.47026817  1
#> 19   1.9  0.32454774 -1.69018029  1
#> 20   2.0  0.07131812 -0.94549766  1
#> 21   2.1  0.23304838 -0.34301196  1
#> 22   2.2  1.98637658  0.35846241  1
#> 23   2.3 -0.95167079  0.04818886  1
#> 24   2.4 -0.55864232  1.13017228  1
#> 25   2.5  0.25581454 -0.52763231  1
#> 26   2.6 -0.19807617  0.47957533  1
#> 27   2.7  0.42878914  1.41752930  1
#> 28   2.8  0.07077011 -0.08009077  1
#> 29   2.9 -1.53665380 -0.39418700  1
#> 30   3.0  0.45398437  0.52525764  1
#> 31   3.1  0.87439857 -0.79593510  1
#> 32   3.2 -1.29773757  0.24509645  1
#> 33   3.3 -1.07896524 -0.77931984  1
#> 34   3.4 -1.13484994  0.59492387  1
#> 35   3.5  0.02261431  1.10889090  1
#> 36   3.6 -0.02146122 -0.94296903  1
#> 37   3.7 -0.27877244  0.70034399  1
#> 38   3.8 -0.02420641 -0.42467483  1
#> 39   3.9  0.82502030 -1.14313760  1
#> 40   4.0 -0.75018278  0.23344022  1
#> 41   4.1  0.53621047 -0.18923658  1
#> 42   4.2 -1.57271748 -1.66341126  1
#> 43   4.3 -0.98642742  1.91569077  1
#> 44   4.4  1.98351232 -0.81689444  1
#> 45   4.5 -1.85137844  0.38365049  1
#> 46   4.6 -0.90978818 -0.45863225  1
#> 47   4.7 -1.95144002 -0.71570398  1
#> 48   4.8 -0.80027646  0.42954854  1
#> 49   4.9 -1.86936160 -1.16985274  1
#> 50   5.0 -0.75057148  1.32208831  1
#> 51   0.1 -0.59093839  1.36596464  2
#> 52   0.2 -0.74209927 -0.24972371  2
#> 53   0.3  0.69351208 -0.42472135  2
#> 54   0.4 -0.05946397  1.09843934  2
#> 55   0.5 -1.86389510  0.67092304  2
#> 56   0.6 -1.27450892  0.03095466  2
#> 57   0.7 -1.78177081  2.36851196  2
#> 58   0.8 -0.50859339  2.58578811  2
#> 59   0.9 -1.73687829  1.21228095  2
#> 60   1.0  0.04048130 -1.25119684  2
#> 61   1.1 -0.12417946  0.40026604  2
#> 62   1.2 -0.61275343  0.93470763  2
#> 63   1.3  0.16066248 -0.47266985  2
#> 64   1.4 -0.66235963  1.58301322  2
#> 65   1.5 -0.33485166  0.59775422  2
#> 66   1.6  0.62301159  0.46608459  2
#> 67   1.7  1.02819429 -0.74436754  2
#> 68   1.8 -1.13457824  0.95905526  2
#> 69   1.9  0.91691105  0.15263708  2
#> 70   2.0  1.21387479 -0.76936870  2
#> 71   2.1 -0.68593246  1.39308074  2
#> 72   2.2 -1.09456819  0.91866877  2
#> 73   2.3  0.36487410  1.01608706  2
#> 74   2.4 -1.00801708  0.53463544  2
#> 75   2.5  0.55499644 -0.98762856  2
#> 76   2.6  0.43606592  1.18779227  2
#> 77   2.7  0.10537330 -0.51754221  2
#> 78   2.8 -0.25373785 -0.25956025  2
#> 79   2.9 -0.97649123 -0.32806467  2
#> 80   3.0  0.39421777  0.07343239  2
#> 81   3.1  1.01490303 -0.24786302  2
#> 82   3.2  0.63144381 -1.37386226  2
#> 83   3.3 -0.48339825 -0.04044582  2
#> 84   3.4 -1.52633394  0.42153824  2
#> 85   3.5  0.61684228  0.20159751  2
#> 86   3.6  1.22928684 -1.69719192  2
#> 87   3.7  0.15745303  0.64228768  2
#> 88   3.8  1.40634206 -0.99523961  2
#> 89   3.9  0.39680092  0.96381390  2
#> 90   4.0  0.32642296 -1.65603723  2
#> 91   4.1 -1.45934331  1.07086109  2
#> 92   4.2 -0.79929553 -0.10902636  2
#> 93   4.3  0.47001280  1.89918639  2
#> 94   4.4 -1.15018052 -1.13703073  2
#> 95   4.5 -0.27159672 -0.27971976  2
#> 96   4.6  0.45742422 -0.89412905  2
#> 97   4.7 -0.01695794  0.13670185  2
#> 98   4.8 -0.54159436 -0.74916542  2
#> 99   4.9  0.87581342  0.51819908  2
#> 100  5.0  0.74083815 -0.19233721  2
#> 
#> $cols
#>      time         x         y        id 
#> "seconds"       "X"       "Y"     "tag" 
#> 
#> $group
#> [1] 1 2
#> 
```
