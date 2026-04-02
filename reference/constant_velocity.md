# Constant velocity model

This model assumes that movement occurs at a constant velocity, so that
changes in acceleration are considered to be noise. In a previous study,
we found that this model performed reasonably well on simulated and
observed pedestrian data.

## Usage

``` r
constant_velocity(data, error = 0.031^2)
```

## Arguments

- data:

  A data.frame containing the data on which to base the parameters of
  the constant velocity model. This function assumes that this
  data.frame contains the columns `"time"`, `"x"`, and `"y"` containing
  the time at which the observed position (x, y) was measured
  respectively.

- error:

  Numeric or numerical vector containing the assumed value of the
  measurement error variance in the x- and y-direction. Should consist
  of either 1 or 2 values. If only 1 value is provided, the measurement
  error variance will be assumed to be the same for both dimensions.
  Defaults to `0.031^2`, a value that we have obtained experimentally.

## Value

Named list containing all parameters relevant for the Kalman filter.

## Details

The constant velocity model is based on the assumption that velocity
remains constant, so that acceleration can be put to 0. This means that
we can use the following movement equation to model changes in the
positions, so that:

\$\$\begin{\bmatrix} x \\ y \\ \end{bmatrix}\_i = \begin{\bmatrix} x \\
y \\ \end{bmatrix}\_{i - 1} + \begin{bmatrix} v_x \\ v_y \\
\end{bmatrix} \Delta t\$\$

where \\x\\ and \\y\\ represent the x- and y-coordinates on which the
measurements at time \\t_i\\ and \\t\_{i - 1}\\ were taken. The
variables \\v_x\\ and \\v_y\\ represent the speeds in the x- and
y-direction at which the system is moving, and \\\Delta t = t_i -
t\_{i - 1}\\ represents the time between the two measurements. This is
the basic equation from which the parameters of the Kalman filter are
derived.

For the constant velocity model, we keep track of the positional data
and the respective velocities at a particular time point \\t_i\\. This
means that the latent state \\\mathbf{x}\\ consists of 4 values on each
iteration, namely:

\$\$\mathbf{x}\_i = \begin{bmatrix} x \\ y \\ v_x \\ v_y \\
\end{bmatrix}\_i\$\$

Under this specification, we define the transition matrix \\F\\ and the
covariance matrix \\W\\ of the movement equation as follows:

\$\$F_i = \begin{bmatrix} 1 & 0 & \Delta t & 0 \\ 0 & 1 & 0 & \Delta t
\\ 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ \end{bmatrix}\_i\$\$

\$\$W_i = \begin{bmatrix} \Delta t^2 \sigma\_{v_x}^2 & 0 & \Delta t
\sigma\_{v_x}^2 & 0 \\ 0 & \Delta t^2 \sigma\_{v_y}^2 & 0 & \Delta t
\sigma\_{v_y}^2 \\ \Delta t \sigma\_{v_x}^2 & 0 & \sigma\_{v_x}^2 & 0 \\
0 & \Delta t \sigma\_{v_y}^2 & 0 & \sigma\_{v_y}^2 \\
\end{bmatrix}\_i\$\$ In these equations, \\\Delta t\\ represents the
time that has elapsed between two observations, so that \\\Delta t =
t_i - t\_{i - 1}\\. The variances \\\sigma\_{v_x}^2\\ and
\\\sigma\_{v_y}^2\\ capture the variation in the speeds \\v_x\\ and
\\v_y\\. Within this function, we estimate these variances through
computing the observed variance in the speeds and subtracting the
assumed measurement error from it, so that in the x-direction, you
obtain:

\$\$\sigma\_{v_x}^2 = VAR\[v_x\]^\text{obs} - \frac{2}{E\[\Delta t\]^2}
\sigma\_{\epsilon, x}^2\$\$

where \\\sigma\_{\epsilon, x}^2\\ and \\\sigma\_{\epsilon, y}^2\\ are
provided through the `error` argument. Note that we assume no covariance
between the two dimensions in the movement covariance \\W\\.

Typically, the movement equation also includes external forces that may
influence the observed behavior. In the constant velocity model
described by this function, we assume that these parameters have no
influence on the observed behavior, meaning that we set its parameters
\\B\\ and \\\mathbf{u}\\ to 0.

For the measurement equation, we define the measurement matrix \\H\\ and
the measurement error covariance matrix \\R\\ as:

\$\$H = \begin{bmatrix} 1 & 0 & 0 & 0 \\ 0 & 1 & 0 & 0 \\
\end{bmatrix}\$\$

\$\$R = \begin{bmatrix} \sigma\_\epsilon^2 & 0 \\ 0 & \sigma\_\epsilon^2
\end{bmatrix}\$\$ where \\\sigma\_\epsilon^2\\ is provided through the
`error` argument. Importantly, the matrix \\R\\ is transformed to its
Cholesky decomposition, as the function
[`kalman_filter`](https://github.com/ndpvh/denoiser/reference/kalman_filter.md)
assumes the Cholesky decomposition is provided for stability purposes.

Note that these two matrices are time-independent: They are assumed to
be constant at each iteration (long-term changes over time) and to not
depend on the time between obsevations \\\Delta t\\. Furthermore note
that the measurement error covariance \\R\\ can only be defined for
those variables that we have measurements on, namely the x- and
y-coordinates. No such error exists for the speeds \\v_x\\ and \\v_y\\.
Similarly, note that the measurement matrix \\H\\ maps the predictions
on the latent level to predictions the measurement level, where it
acknowledges that we only measured x- and y-coordinates.

Finally, we need to define the initial conditions from which the Kalman
filter starts. These initial conditions are taken as the observed
initial locations and speeds (in \\\mathbf{x}\_0\\) and the observed
variances of all these variables (in \\P_0\\). Note that we provide a
covariance matrix \\P_0\\ that is diagonal for simplicity.

## Examples

``` r
# Generate data for illustration purposes. Movement in circular motion at a
# pace of 1.27m/s with some added noise of SD = 10cm.
# some added noise
angles <- seq(0, 4 * pi, length.out = 100)
coordinates <- 10 * cbind(cos(angles), sin(angles))
coordinates <- coordinates + rnorm(200, mean = 0, sd = 0.1)

data <- data.frame(
  x = coordinates[, 1],
  y = coordinates[, 2],
  time = 1:100
)

# Generate the parameters of the Kalman filter according to the constant 
# velocity model with an assumed measurement error variance of 0.01
constant_velocity(
  data, 
  error = 0.1^2
)
#> $z
#>                x            y time delta_t     delta_x      delta_y     speed_x
#> 1     9.95706199  -0.03561244    1       0  0.00000000  0.000000000         NaN
#> 2    10.05559426   1.15947811    2       1  0.09853227  1.195090556  0.09853227
#> 3     9.67240127   2.61919153    3       1 -0.38319299  1.459713411 -0.38319299
#> 4     9.25646396   3.83478211    4       1 -0.41593731  1.215590588 -0.41593731
#> 5     8.49382577   4.88180657    5       1 -0.76263819  1.047024457 -0.76263819
#> 6     8.05925124   5.88903877    6       1 -0.43457453  1.007232195 -0.43457453
#> 7     7.12748949   6.96240554    7       1 -0.93176175  1.073366777 -0.93176175
#> 8     6.24220885   7.95888032    8       1 -0.88528064  0.996474775 -0.88528064
#> 9     5.06588923   8.68572053    9       1 -1.17631962  0.726840214 -1.17631962
#> 10    4.41904333   8.93745790   10       1 -0.64684590  0.251737367 -0.64684590
#> 11    2.85386391   9.49503010   11       1 -1.56517942  0.557572199 -1.56517942
#> 12    1.70241799   9.73113138   12       1 -1.15144593  0.236101286 -1.15144593
#> 13    0.55445542  10.04458399   13       1 -1.14796257  0.313452607 -1.14796257
#> 14   -0.91955088   9.78661303   14       1 -1.47400630 -0.257970956 -1.47400630
#> 15   -1.99385253   9.82735886   15       1 -1.07430165  0.040745825 -1.07430165
#> 16   -3.26316904   9.45422160   16       1 -1.26931652 -0.373137262 -1.26931652
#> 17   -4.38481468   9.07790416   17       1 -1.12164564 -0.376317437 -1.12164564
#> 18   -5.49766000   8.30000643   18       1 -1.11284531 -0.777897732 -1.11284531
#> 19   -6.69383732   7.45186213   19       1 -1.19617732 -0.848144295 -1.19617732
#> 20   -7.35852388   6.68756773   20       1 -0.66468657 -0.764294408 -0.66468657
#> 21   -8.27065940   5.73565199   21       1 -0.91213552 -0.951915732 -0.91213552
#> 22   -8.89591191   4.61665655   22       1 -0.62525251 -1.118995443 -0.62525251
#> 23   -9.39290577   3.56795466   23       1 -0.49699386 -1.048701887 -0.49699386
#> 24   -9.74186776   2.21030790   24       1 -0.34896199 -1.357646767 -0.34896199
#> 25  -10.05456248   1.16320489   25       1 -0.31269472 -1.047103011 -0.31269472
#> 26   -9.87162642  -0.46489903   26       1  0.18293606 -1.628103912  0.18293606
#> 27   -9.84034644  -1.53922511   27       1  0.03127998 -1.074326084  0.03127998
#> 28   -9.64219998  -2.67792779   28       1  0.19814645 -1.138702679  0.19814645
#> 29   -9.09020927  -3.97327752   29       1  0.55199072 -1.295349736  0.55199072
#> 30   -8.73273000  -5.07131889   30       1  0.35747926 -1.098041366  0.35747926
#> 31   -7.83678841  -6.07637432   31       1  0.89594159 -1.005055429  0.89594159
#> 32   -7.14603030  -7.32489723   32       1  0.69075811 -1.248522906  0.69075811
#> 33   -5.98139401  -7.83677984   33       1  1.16463629 -0.511882618  1.16463629
#> 34   -5.15625184  -8.67718205   34       1  0.82514217 -0.840402201  0.82514217
#> 35   -3.85634592  -9.19403997   35       1  1.29990592 -0.516857920  1.29990592
#> 36   -2.72869161  -9.51178753   36       1  1.12765431 -0.317747561  1.12765431
#> 37   -1.50766796 -10.01174874   37       1  1.22102366 -0.499961218  1.22102366
#> 38   -0.09113517 -10.11184666   38       1  1.41653279 -0.100097912  1.41653279
#> 39    1.22371958  -9.92738531   39       1  1.31485475  0.184461350  1.31485475
#> 40    2.18893888  -9.63282514   40       1  0.96521930  0.294560164  0.96521930
#> 41    3.47858072  -9.36491239   41       1  1.28964184  0.267912753  1.28964184
#> 42    4.85447412  -8.60586478   42       1  1.37589340  0.759047611  1.37589340
#> 43    5.91058807  -8.15685146   43       1  1.05611395  0.449013320  1.05611395
#> 44    6.90547090  -7.48520179   44       1  0.99488283  0.671649665  0.99488283
#> 45    7.51731735  -6.54210517   45       1  0.61184645  0.943096619  0.61184645
#> 46    8.55082641  -5.23594730   46       1  1.03350906  1.306157873  1.03350906
#> 47    9.02957798  -4.30595648   47       1  0.47875156  0.929990816  0.47875156
#> 48    9.49292249  -3.16406258   48       1  0.46334452  1.141893903  0.46334452
#> 49    9.86342980  -1.90443395   49       1  0.37050730  1.259628628  0.37050730
#> 50    9.99275905  -0.55559291   50       1  0.12932926  1.348841043  0.12932926
#> 51    9.89684534   0.57634467   51       1 -0.09591372  1.131937582 -0.09591372
#> 52    9.76892768   1.87796976   52       1 -0.12791766  1.301625083 -0.12791766
#> 53    9.38134706   3.17298026   53       1 -0.38758062  1.295010501 -0.38758062
#> 54    8.95409305   4.47130693   54       1 -0.42725401  1.298326676 -0.42725401
#> 55    8.55811947   5.55127390   55       1 -0.39597358  1.079966965 -0.39597358
#> 56    7.57758408   6.57969541   56       1 -0.98053539  1.028421515 -0.98053539
#> 57    6.81407156   7.30751636   57       1 -0.76351252  0.727820949 -0.76351252
#> 58    5.75256375   8.32847204   58       1 -1.06150781  1.020955677 -1.06150781
#> 59    4.66222781   8.75938446   59       1 -1.09033593  0.430912421 -1.09033593
#> 60    3.71487323   9.25490325   60       1 -0.94735458  0.495518789 -0.94735458
#> 61    2.37255729   9.68373254   61       1 -1.34231594  0.428829287 -1.34231594
#> 62    0.96504989  10.04467229   62       1 -1.40750740  0.360939755 -1.40750740
#> 63   -0.15968997  10.08004710   63       1 -1.12473986  0.035374807 -1.12473986
#> 64   -1.44437199  10.07856275   64       1 -1.28468202 -0.001484342 -1.28468202
#> 65   -2.75537215   9.62791472   65       1 -1.31100017 -0.450648039 -1.31100017
#> 66   -4.07366650   9.32178828   66       1 -1.31829435 -0.306126439 -1.31829435
#> 67   -4.81066395   8.48892378   67       1 -0.73699745 -0.832864502 -0.73699745
#> 68   -6.15290946   7.87441645   68       1 -1.34224550 -0.614507323 -1.34224550
#> 69   -7.02500918   7.23699090   69       1 -0.87209973 -0.637425551 -0.87209973
#> 70   -7.83653499   6.16420785   70       1 -0.81152581 -1.072783050 -0.81152581
#> 71   -8.57374424   5.15465512   71       1 -0.73720925 -1.009552734 -0.73720925
#> 72   -9.37884218   3.93946241   72       1 -0.80509793 -1.215192708 -0.80509793
#> 73   -9.60671575   2.72128065   73       1 -0.22787357 -1.218181757 -0.22787357
#> 74   -9.86315941   1.48247166   74       1 -0.25644366 -1.238808997 -0.25644366
#> 75   -9.99417680   0.28342168   75       1 -0.13101740 -1.199049971 -0.13101740
#> 76   -9.76694484  -0.83532573   76       1  0.22723197 -1.118747410  0.22723197
#> 77   -9.53842221  -2.16259521   77       1  0.22852263 -1.327269484  0.22852263
#> 78   -9.32595476  -3.46729368   78       1  0.21246746 -1.304698473  0.21246746
#> 79   -8.81165615  -4.59559032   79       1  0.51429861 -1.128296636  0.51429861
#> 80   -8.26758696  -5.54793040   80       1  0.54406919 -0.952340084  0.54406919
#> 81   -7.35144431  -6.63439561   81       1  0.91614264 -1.086465203  0.91614264
#> 82   -6.64051250  -7.59220459   82       1  0.71093181 -0.957808985  0.71093181
#> 83   -5.48286263  -8.33555362   83       1  1.15764987 -0.743349025  1.15764987
#> 84   -4.40841785  -8.95646114   84       1  1.07444478 -0.620907522  1.07444478
#> 85   -3.23401220  -9.41139548   85       1  1.17440565 -0.454934348  1.17440565
#> 86   -1.93508317  -9.78594134   86       1  1.29892903 -0.374545854  1.29892903
#> 87   -0.88664938  -9.96778908   87       1  1.04843379 -0.181847742  1.04843379
#> 88    0.49760292  -9.89558899   88       1  1.38425230  0.072200093  1.38425230
#> 89    1.87802301  -9.91655252   89       1  1.38042008 -0.020963535  1.38042008
#> 90    2.93083045  -9.51528226   90       1  1.05280744  0.401270261  1.05280744
#> 91    4.13674149  -9.13753372   91       1  1.20591104  0.377748539  1.20591104
#> 92    5.25008022  -8.40382819   92       1  1.11333873  0.733705537  1.11333873
#> 93    6.20457380  -7.57743297   93       1  0.95449357  0.826395218  0.95449357
#> 94    7.28541291  -6.97127208   94       1  1.08083911  0.606160888  1.08083911
#> 95    8.21314331  -5.92822826   95       1  0.92773040  1.043043822  0.92773040
#> 96    8.58699132  -4.65854837   96       1  0.37384801  1.269679887  0.37384801
#> 97    9.14207694  -3.85079316   97       1  0.55508562  0.807755209  0.55508562
#> 98    9.76716475  -2.39558195   98       1  0.62508781  1.455211210  0.62508781
#> 99    9.98196137  -1.28624543   99       1  0.21479662  1.109336522  0.21479662
#> 100  10.21122773  -0.03780286  100       1  0.22926636  1.248442576  0.22926636
#>          speed_y
#> 1            NaN
#> 2    1.195090556
#> 3    1.459713411
#> 4    1.215590588
#> 5    1.047024457
#> 6    1.007232195
#> 7    1.073366777
#> 8    0.996474775
#> 9    0.726840214
#> 10   0.251737367
#> 11   0.557572199
#> 12   0.236101286
#> 13   0.313452607
#> 14  -0.257970956
#> 15   0.040745825
#> 16  -0.373137262
#> 17  -0.376317437
#> 18  -0.777897732
#> 19  -0.848144295
#> 20  -0.764294408
#> 21  -0.951915732
#> 22  -1.118995443
#> 23  -1.048701887
#> 24  -1.357646767
#> 25  -1.047103011
#> 26  -1.628103912
#> 27  -1.074326084
#> 28  -1.138702679
#> 29  -1.295349736
#> 30  -1.098041366
#> 31  -1.005055429
#> 32  -1.248522906
#> 33  -0.511882618
#> 34  -0.840402201
#> 35  -0.516857920
#> 36  -0.317747561
#> 37  -0.499961218
#> 38  -0.100097912
#> 39   0.184461350
#> 40   0.294560164
#> 41   0.267912753
#> 42   0.759047611
#> 43   0.449013320
#> 44   0.671649665
#> 45   0.943096619
#> 46   1.306157873
#> 47   0.929990816
#> 48   1.141893903
#> 49   1.259628628
#> 50   1.348841043
#> 51   1.131937582
#> 52   1.301625083
#> 53   1.295010501
#> 54   1.298326676
#> 55   1.079966965
#> 56   1.028421515
#> 57   0.727820949
#> 58   1.020955677
#> 59   0.430912421
#> 60   0.495518789
#> 61   0.428829287
#> 62   0.360939755
#> 63   0.035374807
#> 64  -0.001484342
#> 65  -0.450648039
#> 66  -0.306126439
#> 67  -0.832864502
#> 68  -0.614507323
#> 69  -0.637425551
#> 70  -1.072783050
#> 71  -1.009552734
#> 72  -1.215192708
#> 73  -1.218181757
#> 74  -1.238808997
#> 75  -1.199049971
#> 76  -1.118747410
#> 77  -1.327269484
#> 78  -1.304698473
#> 79  -1.128296636
#> 80  -0.952340084
#> 81  -1.086465203
#> 82  -0.957808985
#> 83  -0.743349025
#> 84  -0.620907522
#> 85  -0.454934348
#> 86  -0.374545854
#> 87  -0.181847742
#> 88   0.072200093
#> 89  -0.020963535
#> 90   0.401270261
#> 91   0.377748539
#> 92   0.733705537
#> 93   0.826395218
#> 94   0.606160888
#> 95   1.043043822
#> 96   1.269679887
#> 97   0.807755209
#> 98   1.455211210
#> 99   1.109336522
#> 100  1.248442576
#> 
#> $x
#>               [,1]
#> [1,]  9.699526e-02
#> [2,]  1.885989e-02
#> [3,]  2.567331e-03
#> [4,] -2.212539e-05
#> 
#> $P
#>          [,1]     [,2]      [,3]     [,4]
#> [1,] 50.94627  0.00000 0.0000000 0.000000
#> [2,]  0.00000 50.02358 0.0000000 0.000000
#> [3,]  0.00000  0.00000 0.8369546 0.000000
#> [4,]  0.00000  0.00000 0.0000000 0.834431
#> 
#> $F
#> function (delta_t) 
#> {
#>     M <- matrix(c(1, 0, delta_t, 0, 0, 1, 0, delta_t, 0, 0, 1, 
#>         0, 0, 0, 0, 1), nrow = 4, ncol = 4, byrow = TRUE)
#>     return(M)
#> }
#> <bytecode: 0x55a19ee74c80>
#> <environment: 0x55a19ee80ab8>
#> 
#> $W
#> function (delta_t) 
#> {
#>     M <- matrix(c(delta_t^2 * var_x, 0, delta_t * var_x, 0, 0, 
#>         delta_t^2 * var_y, 0, delta_t * var_y, delta_t * var_x, 
#>         0, var_x, 0, 0, delta_t * var_y, 0, var_y), nrow = 4, 
#>         ncol = 4, byrow = TRUE)
#>     return(M)
#> }
#> <bytecode: 0x55a19ee7b8d8>
#> <environment: 0x55a19ee80ab8>
#> 
#> $B
#>      [,1]
#> [1,]    0
#> [2,]    0
#> [3,]    0
#> [4,]    0
#> 
#> $u
#>        [,1]
#>   [1,]    0
#>   [2,]    0
#>   [3,]    0
#>   [4,]    0
#>   [5,]    0
#>   [6,]    0
#>   [7,]    0
#>   [8,]    0
#>   [9,]    0
#>  [10,]    0
#>  [11,]    0
#>  [12,]    0
#>  [13,]    0
#>  [14,]    0
#>  [15,]    0
#>  [16,]    0
#>  [17,]    0
#>  [18,]    0
#>  [19,]    0
#>  [20,]    0
#>  [21,]    0
#>  [22,]    0
#>  [23,]    0
#>  [24,]    0
#>  [25,]    0
#>  [26,]    0
#>  [27,]    0
#>  [28,]    0
#>  [29,]    0
#>  [30,]    0
#>  [31,]    0
#>  [32,]    0
#>  [33,]    0
#>  [34,]    0
#>  [35,]    0
#>  [36,]    0
#>  [37,]    0
#>  [38,]    0
#>  [39,]    0
#>  [40,]    0
#>  [41,]    0
#>  [42,]    0
#>  [43,]    0
#>  [44,]    0
#>  [45,]    0
#>  [46,]    0
#>  [47,]    0
#>  [48,]    0
#>  [49,]    0
#>  [50,]    0
#>  [51,]    0
#>  [52,]    0
#>  [53,]    0
#>  [54,]    0
#>  [55,]    0
#>  [56,]    0
#>  [57,]    0
#>  [58,]    0
#>  [59,]    0
#>  [60,]    0
#>  [61,]    0
#>  [62,]    0
#>  [63,]    0
#>  [64,]    0
#>  [65,]    0
#>  [66,]    0
#>  [67,]    0
#>  [68,]    0
#>  [69,]    0
#>  [70,]    0
#>  [71,]    0
#>  [72,]    0
#>  [73,]    0
#>  [74,]    0
#>  [75,]    0
#>  [76,]    0
#>  [77,]    0
#>  [78,]    0
#>  [79,]    0
#>  [80,]    0
#>  [81,]    0
#>  [82,]    0
#>  [83,]    0
#>  [84,]    0
#>  [85,]    0
#>  [86,]    0
#>  [87,]    0
#>  [88,]    0
#>  [89,]    0
#>  [90,]    0
#>  [91,]    0
#>  [92,]    0
#>  [93,]    0
#>  [94,]    0
#>  [95,]    0
#>  [96,]    0
#>  [97,]    0
#>  [98,]    0
#>  [99,]    0
#> [100,]    0
#> 
#> $H
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    0    0    0
#> [2,]    0    1    0    0
#> 
#> $R
#>      [,1] [,2]
#> [1,]  0.1  0.0
#> [2,]  0.0  0.1
#> 
```
