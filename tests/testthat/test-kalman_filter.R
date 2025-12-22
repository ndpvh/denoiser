test_that(
    "Test known errors",
    {
        # Not a data.fame
        expect_error(kalman_filter(matrix(0, nrow = 10, ncol = 2)))
        expect_error(kalman_filter(numeric(10)))
        expect_error(kalman_filter(character(10)))
        expect_error(kalman_filter(logical(10)))

        # Provided column names don't make sense
        cols <- c(
            "time" = "time", 
            "x" = "x",
            "test" = "test"
        )
        expect_error(
            kalman_filter(
                data.frame(
                    time = 1:10,
                    x = 1:10,
                    y = 1:10
                ),
                cols = cols
            )
        )

        cols <- c("time", "x", "test")
        expect_error(
            kalman_filter(
                data.frame(
                    time = 1:10,
                    x = 1:10,
                    y = 1:10
                ),
                cols = cols
            )
        )

        expect_error(
            kalman_filter(
                data.frame(
                    time = 1:10,
                    x = 1:10,
                    y = 1:10
                ),
                cols = 1:3
            )
        )
    }
)

test_that(
    "Test known warnings",
    {
        # Less than N_min datapoints
        data <- data.frame(
            time = 1:9,
            x = rnorm(9),
            y = rnorm(9)
        )

        expect_warning(
            kalman_filter(
                data,
                N_min = 10
            )
        )

        tst <- kalman_filter(data, N_min = 10) |>
            suppressWarnings()
        
        expect_equal(
            tst, 
            data
        )
    }
)

test_that(
    "Test output of the Kalman filter, single participant",
    {
        # Generate data for illustration purposes. Movement in circular motion at a
        # pace of 1.27m/s
        angles <- seq(0, 4 * pi, length.out = 100)
        coordinates <- 10 * cbind(cos(angles), sin(angles))

        ref <- data.frame(
            seconds = 1:100,
            X = coordinates[, 1],
            Y = coordinates[, 2]
        )

        # Add some error of about 10cm in standard deviation and create a new 
        # data.frame to be used in the Kalman filter.
        set.seed(1)
        coordinates <- coordinates + rnorm(200, mean = 0, sd = 1)        
        data <- data.frame(
            seconds = 1:100,
            X = coordinates[, 1],
            Y = coordinates[, 2]
        )
        
        # Use the Kalman filter with the constant velocity model on these data to 
        # filter out the measurement error. Provide an assumed variance of 1m 
        # to this model
        tst <- kalman_filter(
            data,
            model = "constant_velocity",
            cols = c(
                "time" = "seconds",
                "x" = "X",
                "y" = "Y"
            ),
            error = 1
        )

        # Mean noise should be smaller for the Kalman filter than for the 
        # unfiltered data
        expect_true(mean(abs(tst$X - ref$X)) < mean(abs(data$X - ref$X)))
        expect_true(mean(abs(tst$Y - ref$Y)) < mean(abs(data$Y - ref$Y)))
    }
)

test_that(
    "Test output of the Kalman filter, multiple participants",
    {
        # Generate data for illustration purposes. Movement in circular motion at a
        # pace of 1.27m/s.
        angles <- seq(0, 4 * pi, length.out = 100)
        coordinates <- 10 * cbind(cos(angles), sin(angles))
        
        ref <- data.frame(
            seconds = rep(1:50, times = 2),
            X = coordinates[, 1],
            Y = coordinates[, 2],            
            tag = rep(1:2, each = 50)
        )

        # Add some error of about 10cm in standard deviation and create a new 
        # data.frame to be used in the Kalman filter.
        set.seed(1)
        coordinates <- coordinates + rnorm(200, mean = 0, sd = 1)        
        data <- data.frame(
            seconds = rep(1:50, times = 2),
            X = coordinates[, 1],
            Y = coordinates[, 2],
            tag = rep(1:2, each = 50)
        )
        
        # Use the Kalman filter with the constant velocity model on these data to 
        # filter out the measurement error. Provide an assumed variance of 1m
        # to this model
        tst <- kalman_filter(
            data,
            model = "constant_velocity",
            cols = c(
                "time" = "seconds",
                "x" = "X",
                "y" = "Y"
            ),
            .by = "tag",
            error = 1
        )

        # Mean noise should be smaller for the Kalman filter than for the 
        # unfiltered data
        expect_true(mean(abs(tst$X - ref$X)) < mean(abs(data$X - ref$X)))
        expect_true(mean(abs(tst$Y - ref$Y)) < mean(abs(data$Y - ref$Y)))

        # Check whether a distinction is still made for different people
        expect_true("tag" %in% colnames(tst))

        # Check convergence for each person separately
        tst_x <- mean(abs(tst$X[tst$tag == 1] - ref$X[ref$tag == 1]))
        data_x <- mean(abs(data$X[data$tag == 1] - ref$X[ref$tag == 1]))
        tst_y <- mean(abs(tst$Y[tst$tag == 1] - ref$Y[ref$tag == 1]))
        data_y <- mean(abs(data$Y[data$tag == 1] - ref$Y[ref$tag == 1]))

        expect_true(tst_x < data_x)
        expect_true(tst_y < data_y)

        tst_x <- mean(abs(tst$X[tst$tag == 2] - ref$X[ref$tag == 2]))
        data_x <- mean(abs(data$X[data$tag == 2] - ref$X[ref$tag == 2]))
        tst_y <- mean(abs(tst$Y[tst$tag == 2] - ref$Y[ref$tag == 2]))
        data_y <- mean(abs(data$Y[data$tag == 2] - ref$Y[ref$tag == 2]))

        expect_true(tst_x < data_x)
        expect_true(tst_y < data_y)
    }
)
