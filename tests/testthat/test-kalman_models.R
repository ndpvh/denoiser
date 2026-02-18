test_that(
    "Check which models are available", 
    {
        tst <- names(kalman_models)
        expect_true(all(tst %in% c("constant_velocity", "directional_constant_velocity")))
    }
)

test_that(
    "Test output of the constant velocity model",
    {
        # Create test data with known properties. Linear movement
        set.seed(1)
        data <- data.frame(
            time = 1:100,
            x = 1:100,
            y = 1:100
        )
        data$x <- rnorm(100, data$x, sd = 0.1)
        data$y <- rnorm(100, data$y, sd = 0.1)

        # Compute the constant velocity model for these data
        tst <- constant_velocity(
            data, 
            error = 0.1^2
        )

        # Check whether all parts of the output are there
        expect_true(
            all(
                c("z", "F", "W", "B", "u", "H", "R", "x", "P") %in% names(tst)
            )
        )

        # Check content of the data
        expect_true(
            all(
                c("time", "x", "y", "delta_t", "direction") %in% colnames(tst$z)
            )
        )
        expect_equal(
            tst$z$x,
            data$x
        )
        expect_equal(
            tst$z$y,
            data$y
        )
        expect_equal(
            tst$z$time,
            data$time
        )
        expect_equal(
            tst$z$delta_t,
            c(0, rep(1, 99))
        )
        angles <- c(0, atan2(diff(data$y), diff(data$x)))
        expect_equal(
            tst$z$direction, 
            angles,
            tolerance = 1e-2
        )

        # Check content of the initial conditions
        expect_equal(
            as.numeric(tst$x),
            c(50, 50, 1),
            tolerance = 1e-1
        )
        expect_equal(
            tst$P,
            diag(c(var(1:100), var(1:100), 0)),
            tolerance = 1e-1
        )

        # Check movement equation parameters
        expect_equal(
            tst$F(2),
            c(1, 0, cos(angles[2])^2, 
              0, 1, sin(angles[2])^2,
              0, 0, 1) |>
                matrix(nrow = 3, ncol = 3, byrow = TRUE)
        )
        expect_equal(
            tst$F(10),
            c(1, 0, cos(angles[10])^2, 
              0, 1, sin(angles[10])^2,
              0, 0, 1) |>
                matrix(nrow = 3, ncol = 3, byrow = TRUE)
        )

        var_w <- 1e-10
        expect_equal(
            tst$W(2),
            c(cos(angles[2])^4 * var_w, 0, cos(angles[2])^2 * var_w, 
              0, sin(angles[2])^4 * var_w, sin(angles[2])^2 * var_w, 
              cos(angles[2])^2 * var_w, sin(angles[2])^2 * var_w, var_w) |>
                matrix(nrow = 3, ncol = 3, byrow = TRUE),
            tolerance = 1e-3
        )
        expect_equal(
            tst$W(10),
            c(cos(angles[10])^4 * var_w, 0, cos(angles[10])^2 * var_w, 
              0, sin(angles[10])^4 * var_w, sin(angles[10])^2 * var_w, 
              cos(angles[10])^2 * var_w, sin(angles[10])^2 * var_w, var_w) |>
                matrix(nrow = 3, ncol = 3, byrow = TRUE),
            tolerance = 1e-3
        )

        expect_equal(
            tst$B, 
            matrix(0, nrow = 4, ncol = 1)
        )
        expect_equal(
            tst$u, 
            matrix(0, nrow = 100, ncol = 1)
        )

        # Check measurement error parameters
        expect_equal(
            tst$H, 
            c(1, 0, 0, 1, 0, 0) |>
                matrix(nrow = 3, ncol = 2, byrow = TRUE) |>
                t()
        )
        expect_equal(
            tst$R, 
            diag(2) * 0.1
        )
    }
)

test_that(
    "Test output of the directional constant velocity model",
    {
        # Create test data with known properties. Linear movement
        set.seed(1)
        data <- data.frame(
            time = 1:100,
            x = 1:100,
            y = 1:100
        )
        data$x <- rnorm(100, data$x, sd = 0.1)
        data$y <- rnorm(100, data$y, sd = 0.1)

        # Compute the constant velocity model for these data
        tst <- directional_constant_velocity(
            data, 
            error = 0.1^2
        )

        # Check whether all parts of the output are there
        expect_true(
            all(
                c("z", "F", "W", "B", "u", "H", "R", "x", "P") %in% names(tst)
            )
        )

        # Check content of the data
        expect_true(
            all(
                c("time", "x", "y", "delta_t") %in% colnames(tst$z)
            )
        )
        expect_equal(
            tst$z$x,
            data$x
        )
        expect_equal(
            tst$z$y,
            data$y
        )
        expect_equal(
            tst$z$time,
            data$time
        )
        expect_equal(
            tst$z$delta_t,
            c(0, rep(1, 99))
        )

        # Check content of the initial conditions
        expect_equal(
            as.numeric(tst$x),
            c(50, 50, 1, 1),
            tolerance = 1e-1
        )
        expect_equal(
            tst$P,
            diag(c(var(1:100), var(1:100), 0, 0)),
            tolerance = 1e-1
        )

        # Check movement equation parameters
        expect_equal(
            tst$F(2),
            c(1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1) |>
                matrix(nrow = 4, ncol = 4, byrow = TRUE)
        )
        expect_equal(
            tst$F(10),
            c(1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1) |>
                matrix(nrow = 4, ncol = 4, byrow = TRUE)
        )

        var_w <- 1e-10
        expect_equal(
            tst$W(1),
            c(var_w, 0, var_w, 0, 0, var_w, 0, var_w) |>
                rep(times = 2) |>
                matrix(nrow = 4, ncol = 4, byrow = TRUE),
            tolerance = 1e-3
        )
        expect_equal(
            tst$W(0.5),
            c(0.25 * var_w, 0, 0.5 * var_w, 0, 0, 0.25 * var_w, 0, 0.5 * var_w,
              0.5 * var_w, 0, var_w, 0, 0, 0.25 * var_w, 0, var_w) |>
                matrix(nrow = 4, ncol = 4, byrow = TRUE),
            tolerance = 1e-3
        )

        expect_equal(
            tst$B, 
            matrix(0, nrow = 4, ncol = 1)
        )
        expect_equal(
            tst$u, 
            matrix(0, nrow = 100, ncol = 1)
        )

        # Check measurement error parameters
        expect_equal(
            tst$H, 
            c(1, 0, 0, 1, 0, 0, 0, 0) |>
                matrix(nrow = 4, ncol = 2, byrow = TRUE) |>
                t()
        )
        expect_equal(
            tst$R, 
            diag(2) * 0.1
        )
    }
)
