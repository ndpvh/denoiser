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
#>               x            y time delta_t      delta_x      delta_y
#> 1     9.9929143   0.10771165    1       0  0.000000000  0.000000000
#> 2     9.8923328   1.38408209    2       1 -0.100581497  1.276370439
#> 3     9.4348190   2.53131908    3       1 -0.457513749  1.147236989
#> 4     9.2902280   3.67658403    4       1 -0.144591017  1.145264950
#> 5     8.6286429   4.92358279    5       1 -0.661585114  1.246998757
#> 6     7.9893848   6.12649497    6       1 -0.639258123  1.202912176
#> 7     7.0309749   7.08925635    7       1 -0.958409822  0.962761382
#> 8     6.5704199   7.60260259    8       1 -0.460555062  0.513346241
#> 9     5.1569148   8.44326198    9       1 -1.413505036  0.840659395
#> 10    4.1200863   8.97937381   10       1 -1.036828495  0.536111824
#> 11    3.0478400   9.60493301   11       1 -1.072246332  0.625559206
#> 12    1.6094305   9.66614281   12       1 -1.438409545  0.061209792
#> 13    0.5300333  10.02800779   13       1 -1.079397152  0.361864984
#> 14   -0.7849890   9.97276117   14       1 -1.315022292 -0.055246619
#> 15   -1.9922152   9.90599088   15       1 -1.207226260 -0.066770290
#> 16   -3.2291390   9.42431607   16       1 -1.236923755 -0.481674810
#> 17   -4.5858961   8.85430413   17       1 -1.356757110 -0.570011936
#> 18   -5.4450800   8.34557627   18       1 -0.859183924 -0.508727866
#> 19   -6.5825009   7.62254910   19       1 -1.137420900 -0.723027168
#> 20   -7.4602019   6.70208134   20       1 -0.877700995 -0.920467760
#> 21   -8.2327454   5.81835187   21       1 -0.772543454 -0.883729469
#> 22   -8.8759244   4.58946779   22       1 -0.643179005 -1.228884083
#> 23   -9.4967695   3.63284589   23       1 -0.620845083 -0.956621900
#> 24   -9.6309589   2.05548564   24       1 -0.134189399 -1.577360249
#> 25   -9.9206768   0.99134928   25       1 -0.289717915 -1.064136354
#> 26  -10.0422357  -0.17788156   26       1 -0.121558895 -1.169230838
#> 27   -9.8035136  -1.54398613   27       1  0.238722091 -1.366104575
#> 28   -9.7478256  -2.75187054   28       1  0.055687973 -1.207884413
#> 29   -9.1373420  -3.90408981   29       1  0.610483568 -1.152219269
#> 30   -8.7111156  -5.33472943   30       1  0.426226483 -1.430639616
#> 31   -7.7858281  -6.06075130   31       1  0.925287468 -0.726021873
#> 32   -7.1710007  -7.14386972   32       1  0.614827368 -1.083118420
#> 33   -6.0489915  -7.92811543   33       1  1.122009185 -0.784245708
#> 34   -5.0639535  -8.53361998   34       1  0.985038058 -0.605504549
#> 35   -3.9479708  -9.33707727   35       1  1.115982646 -0.803457288
#> 36   -2.5972137  -9.75152697   36       1  1.350757164 -0.414449699
#> 37   -1.3078108  -9.88721508   37       1  1.289402864 -0.135688115
#> 38   -0.3273101  -9.91345074   38       1  0.980500691 -0.026235655
#> 39    1.0181005  -9.96181843   39       1  1.345410617 -0.048367695
#> 40    2.4893527  -9.50944683   40       1  1.471252221  0.452371604
#> 41    3.6788812  -9.35257054   41       1  1.189528465  0.156876287
#> 42    4.8430875  -8.95381834   42       1  1.164206341  0.398752200
#> 43    5.6574420  -8.25998860   43       1  0.814354486  0.693829743
#> 44    6.9233852  -7.17545621   44       1  1.265943184  1.084532385
#> 45    7.6607570  -6.43588346   45       1  0.737371824  0.739572753
#> 46    8.4047466  -5.45013630   46       1  0.743989621  0.985747162
#> 47    9.0734082  -4.30987063   47       1  0.668661560  1.140265668
#> 48    9.5136035  -3.04168817   48       1  0.440195262  1.268182460
#> 49    9.7362655  -1.95040697   49       1  0.222662080  1.091281202
#> 50    9.9295075  -0.64878189   50       1  0.193241927  1.301625083
#> 51    9.8605026   0.68688500   51       1 -0.069004827  1.335666881
#> 52    9.7441146   2.06587025   52       1 -0.116388006  1.378985259
#> 53    9.6462953   3.26520018   53       1 -0.097819323  1.199329924
#> 54    8.9464050   4.44976844   54       1 -0.699890288  1.184568257
#> 55    8.4415128   5.36800745   55       1 -0.504892255  0.918239013
#> 56    7.6124391   6.61058861   56       1 -0.829073692  1.242581165
#> 57    6.7246112   7.29076791   57       1 -0.887827903  0.680179297
#> 58    5.9465801   8.05918417   58       1 -0.778031066  0.768416255
#> 59    4.7376787   8.78015049   59       1 -1.208901431  0.720966320
#> 60    3.4255301   9.44776625   60       1 -1.312148577  0.667615762
#> 61    2.3565590   9.79942150   61       1 -1.068971083  0.351655255
#> 62    1.0871584  10.11873298   62       1 -1.269400628  0.319311477
#> 63   -0.2492937   9.98823441   63       1 -1.336452052 -0.130498573
#> 64   -1.6333636   9.99645976   64       1 -1.384069974  0.008225348
#> 65   -2.4754021   9.46709132   65       1 -0.842038460 -0.529368432
#> 66   -3.9602638   9.14034099   66       1 -1.484861750 -0.326750335
#> 67   -5.0102603   8.77030323   67       1 -1.049996463 -0.370037762
#> 68   -6.0321009   7.94023639   68       1 -1.021840611 -0.830066831
#> 69   -7.0086590   7.14482292   69       1 -0.976558074 -0.795413479
#> 70   -8.0782886   6.11174692   70       1 -1.069629563 -1.033075998
#> 71   -8.5916201   5.04072900   71       1 -0.513331596 -1.071017917
#> 72   -9.1498551   3.91176305   72       1 -0.558234949 -1.128965950
#> 73   -9.5941411   2.78346792   73       1 -0.444286021 -1.128295132
#> 74   -9.6866145   1.69524867   74       1 -0.092473383 -1.088219251
#> 75   -9.7790898   0.35778945   75       1 -0.092475269 -1.337459214
#> 76   -9.8837478  -0.99765268   76       1 -0.104658005 -1.355442136
#> 77   -9.6775995  -2.21643043   77       1  0.206148243 -1.218777747
#> 78   -9.4277473  -3.29753320   78       1  0.249852181 -1.081102768
#> 79   -8.7871543  -4.54897082   79       1  0.640593048 -1.251437620
#> 80   -8.3286710  -5.70530749   80       1  0.458483328 -1.156336667
#> 81   -7.3963065  -6.67754507   81       1  0.932364485 -0.972237589
#> 82   -6.5163591  -7.55401914   82       1  0.879947425 -0.876474063
#> 83   -5.5025332  -8.28708584   83       1  1.013825862 -0.733066707
#> 84   -4.3276826  -8.95785462   84       1  1.174850592 -0.670768776
#> 85   -3.3648294  -9.44924951   85       1  0.962853170 -0.491394889
#> 86   -2.0262829  -9.69494006   86       1  1.338546524 -0.245690550
#> 87   -0.6509583 -10.03702275   87       1  1.375324577 -0.342082695
#> 88    0.4374459  -9.95493324   88       1  1.088404193  0.082089513
#> 89    1.7190731  -9.88929130   89       1  1.281627286  0.065641940
#> 90    2.9470293  -9.45559630   90       1  1.227956162  0.433694999
#> 91    4.0531973  -8.91228828   91       1  1.106167956  0.543308022
#> 92    5.3203272  -8.56773627   92       1  1.267129945  0.344552014
#> 93    6.4659674  -7.76061361   93       1  1.145640201  0.807122654
#> 94    7.0858379  -6.69737113   94       1  0.619870524  1.063242486
#> 95    7.9111002  -6.06324790   95       1  0.825262256  0.634123229
#> 96    8.8261715  -4.74606944   96       1  0.915071319  1.317178455
#> 97    9.3460926  -3.73694545   97       1  0.519921068  1.009123990
#> 98    9.8907147  -2.54928273   98       1  0.544622171  1.187662725
#> 99    9.8839357  -1.09231343   99       1 -0.006779056  1.456969296
#> 100   9.8935536  -0.08452478  100       1  0.009617892  1.007788650
#>          speed_x      speed_y
#> 1            NaN          NaN
#> 2   -0.100581497  1.276370439
#> 3   -0.457513749  1.147236989
#> 4   -0.144591017  1.145264950
#> 5   -0.661585114  1.246998757
#> 6   -0.639258123  1.202912176
#> 7   -0.958409822  0.962761382
#> 8   -0.460555062  0.513346241
#> 9   -1.413505036  0.840659395
#> 10  -1.036828495  0.536111824
#> 11  -1.072246332  0.625559206
#> 12  -1.438409545  0.061209792
#> 13  -1.079397152  0.361864984
#> 14  -1.315022292 -0.055246619
#> 15  -1.207226260 -0.066770290
#> 16  -1.236923755 -0.481674810
#> 17  -1.356757110 -0.570011936
#> 18  -0.859183924 -0.508727866
#> 19  -1.137420900 -0.723027168
#> 20  -0.877700995 -0.920467760
#> 21  -0.772543454 -0.883729469
#> 22  -0.643179005 -1.228884083
#> 23  -0.620845083 -0.956621900
#> 24  -0.134189399 -1.577360249
#> 25  -0.289717915 -1.064136354
#> 26  -0.121558895 -1.169230838
#> 27   0.238722091 -1.366104575
#> 28   0.055687973 -1.207884413
#> 29   0.610483568 -1.152219269
#> 30   0.426226483 -1.430639616
#> 31   0.925287468 -0.726021873
#> 32   0.614827368 -1.083118420
#> 33   1.122009185 -0.784245708
#> 34   0.985038058 -0.605504549
#> 35   1.115982646 -0.803457288
#> 36   1.350757164 -0.414449699
#> 37   1.289402864 -0.135688115
#> 38   0.980500691 -0.026235655
#> 39   1.345410617 -0.048367695
#> 40   1.471252221  0.452371604
#> 41   1.189528465  0.156876287
#> 42   1.164206341  0.398752200
#> 43   0.814354486  0.693829743
#> 44   1.265943184  1.084532385
#> 45   0.737371824  0.739572753
#> 46   0.743989621  0.985747162
#> 47   0.668661560  1.140265668
#> 48   0.440195262  1.268182460
#> 49   0.222662080  1.091281202
#> 50   0.193241927  1.301625083
#> 51  -0.069004827  1.335666881
#> 52  -0.116388006  1.378985259
#> 53  -0.097819323  1.199329924
#> 54  -0.699890288  1.184568257
#> 55  -0.504892255  0.918239013
#> 56  -0.829073692  1.242581165
#> 57  -0.887827903  0.680179297
#> 58  -0.778031066  0.768416255
#> 59  -1.208901431  0.720966320
#> 60  -1.312148577  0.667615762
#> 61  -1.068971083  0.351655255
#> 62  -1.269400628  0.319311477
#> 63  -1.336452052 -0.130498573
#> 64  -1.384069974  0.008225348
#> 65  -0.842038460 -0.529368432
#> 66  -1.484861750 -0.326750335
#> 67  -1.049996463 -0.370037762
#> 68  -1.021840611 -0.830066831
#> 69  -0.976558074 -0.795413479
#> 70  -1.069629563 -1.033075998
#> 71  -0.513331596 -1.071017917
#> 72  -0.558234949 -1.128965950
#> 73  -0.444286021 -1.128295132
#> 74  -0.092473383 -1.088219251
#> 75  -0.092475269 -1.337459214
#> 76  -0.104658005 -1.355442136
#> 77   0.206148243 -1.218777747
#> 78   0.249852181 -1.081102768
#> 79   0.640593048 -1.251437620
#> 80   0.458483328 -1.156336667
#> 81   0.932364485 -0.972237589
#> 82   0.879947425 -0.876474063
#> 83   1.013825862 -0.733066707
#> 84   1.174850592 -0.670768776
#> 85   0.962853170 -0.491394889
#> 86   1.338546524 -0.245690550
#> 87   1.375324577 -0.342082695
#> 88   1.088404193  0.082089513
#> 89   1.281627286  0.065641940
#> 90   1.227956162  0.433694999
#> 91   1.106167956  0.543308022
#> 92   1.267129945  0.344552014
#> 93   1.145640201  0.807122654
#> 94   0.619870524  1.063242486
#> 95   0.825262256  0.634123229
#> 96   0.915071319  1.317178455
#> 97   0.519921068  1.009123990
#> 98   0.544622171  1.187662725
#> 99  -0.006779056  1.456969296
#> 100  0.009617892  1.007788650
#> 
#> $x
#>              [,1]
#> [1,]  0.094643590
#> [2,]  0.021171338
#> [3,] -0.001003643
#> [4,] -0.001941782
#> 
#> $P
#>          [,1]     [,2]      [,3]      [,4]
#> [1,] 50.85794  0.00000 0.0000000 0.0000000
#> [2,]  0.00000 49.99315 0.0000000 0.0000000
#> [3,]  0.00000  0.00000 0.8361181 0.0000000
#> [4,]  0.00000  0.00000 0.0000000 0.8296371
#> 
#> $F
#> function (delta_t) 
#> {
#>     M <- matrix(c(1, 0, delta_t, 0, 0, 1, 0, delta_t, 0, 0, 1, 
#>         0, 0, 0, 0, 1), nrow = 4, ncol = 4, byrow = TRUE)
#>     return(M)
#> }
#> <bytecode: 0x56506a815078>
#> <environment: 0x56506a816be0>
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
#> <bytecode: 0x56506a8145c0>
#> <environment: 0x56506a816be0>
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
