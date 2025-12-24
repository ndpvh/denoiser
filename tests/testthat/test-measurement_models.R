test_that(
    "Known errors: Independent model",
    {
        data <- data.frame(
            x = rnorm(10),
            y = rnorm(10),
            time = 1:10
        )
        
        # Covariance is not a matrix
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = logical(4)
            )
        )
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = numeric(4)
            )
        )
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = character(4)
            )
        )

        # Dimensionality of covariance is not sound
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = matrix(0, nrow = 1, ncol = 1)
            )
        )
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = matrix(0, nrow = 3, ncol = 3)
            )
        )

        # Positive definiteness of the covariance matrix
        expect_error(
            independent(
                data, 
                mean = c(0, 0),
                covariance = c(1, 100, 100, 1) |>
                    matrix(nrow = 2, ncol = 2)
            )
        )
    }
)

test_that(
    "Known errors: Temporal model",
    {
        data <- data.frame(
            x = rnorm(10),
            y = rnorm(10),
            time = 1:10
        )
        
        # Covariance is not a matrix
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = logical(4)
            )
        )
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = numeric(4)
            )
        )
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = character(4)
            )
        )

        # Dimensionality of covariance is not sound
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = matrix(0, nrow = 1, ncol = 1)
            )
        )
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = matrix(0, nrow = 3, ncol = 3)
            )
        )

        # Positive definiteness of the covariance matrix
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(2) * 0.15,
                covariance = c(1, 100, 100, 1) |>
                    matrix(nrow = 2, ncol = 2)
            )
        )

        # Transition matrix is not a matrix
        expect_error(
            temporal(
                data,
                intercept = c(0, 0),
                transition = logical(4),
                covariance = diag(2)
            )
        )
        expect_error(
            temporal(
                data,
                intercept = c(0, 0),
                transition = numeric(4),
                covariance = diag(2)
            )
        )
        expect_error(
            temporal(
                data,
                intercept = c(0, 0),
                transition = character(4),
                covariance = diag(2)
            )
        )

        # Dimensionality of transition matrix is not sound
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),                
                transition = diag(1) * 0.15,
                covariance = diag(2)
            )
        )
        expect_error(
            temporal(
                data, 
                intercept = c(0, 0),
                transition = diag(3) * 0.15,
                covariance = diag(2)
            )
        )
    }
)

test_that(
    "Check the names provided in the measurement models list",
    {
        expect_true(all(names(measurement_models) %in% c("independent", "temporal")))
    }
)

test_that(
    "Checking residuals of independent model",
    {
        # Generate positional data
        set.seed(1)
        data <- data.frame(
            time = 1:1000,
            x = rnorm(1000),
            y = rnorm(1000)
        )

        # Add noise to these data
        tst <- independent(
            data,
            mean = c(5, 5),
            covariance = diag(2)
        )

        # Compute the residuals
        tst_x <- tst$x - data$x 
        tst_y <- tst$y - data$y 

        # Check the means of the residuals
        expect_equal(
            c(mean(tst_x), mean(tst_y)),
            c(5, 5),
            tolerance = 1e-1
        )
        
        # Check the covariance of the residuals
        expect_equal(
            c(sd(tst_x), sd(tst_y), cov(tst_x, tst_y)),
            c(1, 1, 0),
            tolerance = 1e-1
        )
    }
)

test_that(
    "Checking residuals of temporal model",
    {
        N <- 10000

        # Generate positional data
        set.seed(1)
        angles <- seq(0, 10 * pi, length.out = N)
        data <- data.frame(
            time = 1:N,
            x = 10 * cos(angles),
            y = 10 * sin(angles)
        )

        # Add noise to these data
        tst <- temporal(
            data,
            intercept = c(5, 5),
            transition = diag(2) * 0.5,
            covariance = diag(2) * 0.1
        )

        # Compute the residuals
        tst_x <- tst$x - data$x 
        tst_y <- tst$y - data$y 

        # Estimate a VAR with these data
        X <- cbind(rep(1, N - 1), tst_x[2:N - 1], tst_y[2:N - 1])
        Y <- cbind(tst_x[2:N], tst_y[2:N])
        B <- t(Y) %*% X %*% solve(t(X) %*% X)

        # Check the means of the residuals
        expect_equal(
            c(mean(tst_x), mean(tst_y)),
            c(5 / (1 - 0.5), 5 / (1 - 0.5)),
            tolerance = 1e-1
        )

        # Check the estimated intercepts of the residuals
        expect_equal(
            B[, 1],
            c(5, 5),
            tolerance = 1e-1
        )

        # Check the autocorrelation of the residuals
        expect_equal(
            c(cor(tst_x[2:N], tst_x[2:N - 1]), cor(tst_y[2:N], tst_y[2:N - 1])),
            c(0.5, 0.5),
            tolerance = 1e-1
        )

        # Check the correlation of the residuals
        expect_equal(
            cor(tst_x, tst_y),
            0,
            tolerance = 1e-1
        )

        # Check the estimation transition matrix of the residuals
        expect_equal(
            B[, 2:3],
            diag(2) * 0.5,
            tolerance = 1e-1
        )
        
        # Check the covariance of the residuals
        expect_equal(
            c(sd(tst_x), sd(tst_y), cov(tst_x, tst_y)),
            c(0.1 / (1 - 0.5)^2, 0.1 / (1 - 0.5)^2, 0),
            tolerance = 1e-1
        )
    }
)
