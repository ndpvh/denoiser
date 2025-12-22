# Prepare data for analysis

Function that is used internally to prepare data for analysis, it being
either binning (\[bin()\]) or using the Kalman filter
(\[kalman_filter()\]). This preparation consists of the following steps.
First, this function checks whether the provided data is actually a
\`data.frame\`, which is required for our functions to work properly.
Then, this function examines the column names of argument \`cols\`. When
provided, it will check whether they adhere to the required format and,
if so, change the column names of the data to the default ones used in
this package (this change is later undone in \[finalize()\]). Finally,
this function check whether there is a grouping variable as specified in
\`.by\`, and if so prepares the data for this grouping.

## Usage

``` r
prepare(data, cols = NULL, .by = NULL)
```

## Arguments

- data:

  Dataframe that contains information on location (x- and y-coordinates)
  and the time at which the measurement was taken. By default,
  \[kalman_filter()\] will assume that this information is contained
  within the columns \`"x"\`, \`"y"\`, and \`"time"\` respectively. If
  this isn't the case, either change the column names in the data or
  specify the \`cols\` argument.

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

## Value

Named list containing the prepared \`data.frame\` (under \`"data"\`),
the mapping of the user-specified and package-required column names
(under \`"cols"\`), and the values of the grouping variable (under
\`"group"\`).

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
#> 1    0.1 -0.82935177  0.80312186  1
#> 2    0.2 -0.21869594 -0.41579535  1
#> 3    0.3 -1.54508372  1.21248959  1
#> 4    0.4  0.23322978  1.24036003  1
#> 5    0.5  0.03106964  0.68567588  1
#> 6    0.6  0.35786565 -0.02679868  1
#> 7    0.7  1.60862422  0.30958051  1
#> 8    0.8  1.42985426  0.24986433  1
#> 9    0.9 -0.94833964 -1.35646087  1
#> 10   1.0  1.01570554  0.59937977  1
#> 11   1.1  0.03773461  0.00864779  1
#> 12   1.2 -1.74423940  0.09071661  1
#> 13   1.3 -0.97007381 -0.65705741  1
#> 14   1.4 -0.22902736 -0.48178225  1
#> 15   1.5 -0.97484568  0.01775788  1
#> 16   1.6  2.69237242 -0.85953576  1
#> 17   1.7  1.39239386  1.35770498  1
#> 18   1.8  1.36007615  1.21506118  1
#> 19   1.9 -0.36541588  1.45391292  1
#> 20   2.0 -0.86893720 -0.08591198  1
#> 21   2.1 -0.50655673 -0.61756875  1
#> 22   2.2  1.21470730 -0.21826025  1
#> 23   2.3  0.50695868 -1.32600521  1
#> 24   2.4 -2.09497131 -2.36220890  1
#> 25   2.5  0.03407924 -1.40996955  1
#> 26   2.6  0.85272870  0.25439714  1
#> 27   2.7  0.74322814  0.29587030  1
#> 28   2.8  0.55715361  0.05678979  1
#> 29   2.9 -1.24858322 -0.10265486  1
#> 30   3.0 -0.20787431  1.95192303  1
#> 31   3.1  0.42396946  0.87856596  1
#> 32   3.2 -0.50669744 -1.30661693  1
#> 33   3.3 -0.61152331  0.09034427  1
#> 34   3.4  2.41165945  0.90235804  1
#> 35   3.5 -0.16495814  0.54942132  1
#> 36   3.6 -0.44040605 -0.86983920  1
#> 37   3.7  0.52197617 -0.03921465  1
#> 38   3.8 -1.91832225 -0.51845168  1
#> 39   3.9 -1.98264996 -0.91184962  1
#> 40   4.0  0.52120016  0.15031364  1
#> 41   4.1  0.77778320  0.44035545  1
#> 42   4.2 -0.81211887  1.31978206  1
#> 43   4.3  0.91074832  0.24656113  1
#> 44   4.4  0.94875395  0.94182660  1
#> 45   4.5 -1.34804945 -0.34215133  1
#> 46   4.6  0.35417586 -0.27614681  1
#> 47   4.7  0.53026393  0.38365678  1
#> 48   4.8 -0.31097493  1.44691022  1
#> 49   4.9 -0.24415553  1.73390029  1
#> 50   5.0 -0.29187819  0.45642938  1
#> 51   0.1 -1.12808616  0.70750349  2
#> 52   0.2 -1.12288159  2.06378922  2
#> 53   0.3  2.05393864  0.02391059  2
#> 54   0.4 -0.90951843  0.24594946  2
#> 55   0.5  0.45837916  0.27205914  2
#> 56   0.6 -0.04661845 -0.99245858  2
#> 57   0.7 -0.68095460 -0.02757795  2
#> 58   0.8 -1.48882940  2.22284516  2
#> 59   0.9 -0.39251301  0.15550390  2
#> 60   1.0 -1.74968202 -0.86911632  2
#> 61   1.1 -0.03866763 -1.17448945  2
#> 62   1.2 -0.79715324 -1.75967731  2
#> 63   1.3 -0.91592054  0.05836159  2
#> 64   1.4  0.07326746  1.16451986  2
#> 65   1.5  1.23817132  0.33762789  2
#> 66   1.6  0.71837134 -1.05451872  2
#> 67   1.7  0.53946650  0.66076911  2
#> 68   1.8 -1.06123399 -0.82340900  2
#> 69   1.9 -0.54073787  0.43703366  2
#> 70   2.0 -0.71520471  0.37238811  2
#> 71   2.1 -0.17892009 -1.64674913  2
#> 72   2.2  0.16497028 -1.92355227  2
#> 73   2.3 -0.72740817  0.38083303  2
#> 74   2.4 -0.53783713  1.37570535  2
#> 75   2.5 -0.59966490  0.82584873  2
#> 76   2.6  1.18208775 -0.41611500  2
#> 77   2.7  0.18921288  0.98214959  2
#> 78   2.8  0.24894911  0.24218073  2
#> 79   2.9  1.04664341 -0.93792685  2
#> 80   3.0 -1.28930094  1.50585850  2
#> 81   3.1  0.37511557 -1.06585117  2
#> 82   3.2 -0.55691839  0.16227053  2
#> 83   3.3  0.30242663  0.26047039  2
#> 84   3.4  0.22226647 -1.48820199  2
#> 85   3.5 -0.96216696  1.41518387  2
#> 86   3.6  0.05203237  0.56250751  2
#> 87   3.7  0.90004038  0.64205574  2
#> 88   3.8 -0.39490088 -0.89053264  2
#> 89   3.9  0.95414600 -0.11653752  2
#> 90   4.0 -0.58821435 -0.94197475  2
#> 91   4.1 -1.47658453  1.11582792  2
#> 92   4.2 -1.37777577  0.47013513  2
#> 93   4.3 -1.34567231  0.86061271  2
#> 94   4.4 -0.73663796 -0.07039665  2
#> 95   4.5 -0.47011150 -0.61318021  2
#> 96   4.6  1.38060934 -0.33671496  2
#> 97   4.7  1.67501093 -0.21584018  2
#> 98   4.8  1.17690663  0.62113229  2
#> 99   4.9 -0.14889834 -1.28402652  2
#> 100  5.0 -0.17782336 -1.30009244  2
#> 
#> $cols
#>      time         x         y        id 
#> "seconds"       "X"       "Y"     "tag" 
#> 
#> $group
#> [1] 1 2
#> 
```
