test_that(
    "Known errors work",
    {
        # Not a data.fame
        expect_error(bin(matrix(0, nrow = 10, ncol = 2)))
        expect_error(bin(numeric(10)))
        expect_error(bin(character(10)))
        expect_error(bin(logical(10)))

        # Provided column names don't make sense
        cols <- c(
            "time" = "time", 
            "x" = "x",
            "test" = "test"
        )
        expect_error(
            bin(
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
            bin(
                data.frame(
                    time = 1:10,
                    x = 1:10,
                    y = 1:10
                ),
                cols = cols
            )
        )

        expect_error(
            bin(
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
    "Test outcome of the `bin` function: No grouping involved",
    {
        # Create a mock dataset that will lead to results that we know 
        # analytically
        data <- data.frame(
            time = rep(1:20 / 5, times = 2),
            id = rep(1:2, each = 20),
            x = rep(1:20, times = 2),
            y = rep(20:1, times = 2)
        )

        # Use the bin function with the mean
        tst <- bin(
            data, 
            fx = mean,
            span = 1
        )

        # Create a reference
        #   - time: (0.2 + 1.2) / 2, (1.4 + 2.2) / 2, (2.4 + 3.2) / 2, (3.4 + 4) / 2
        #   - x: (1 + 6) / 2, (7 + 11) / 2, (12 + 16) / 2, (17 + 20) /2
        #   - x: (20 + 15) / 2, (14 + 10) / 2, (9 + 5) / 2, (4 + 1) /2
        ref <- data.frame(
            time = c(0.7, 1.8, 2.8, 3.7),
            x = c(3.5, 9, 14, 18.5),
            y = c(17.5, 12, 7, 2.5)
        )

        # Perform the test
        expect_identical(ref, tst)
    }
)

test_that(
    "Test outcome of the `bin` function: Grouping involved",
    {
        # Create a mock dataset that will lead to results that we know 
        # analytically
        data <- data.frame(
            time = rep(1:20 / 5, times = 2),
            id = rep(1:2, each = 20),
            x = rep(1:20, times = 2),
            y = rep(20:1, times = 2)
        )

        # Use the bin function with the mean
        tst <- bin(
            data, 
            fx = mean,
            span = 1,
            .by = "id"
        )

        # Create a reference
        #   - time: (0.2 + 1.2) / 2, (1.4 + 2.2) / 2, (2.4 + 3.2) / 2, (3.4 + 4) / 2
        #   - x: (1 + 6) / 2, (7 + 11) / 2, (12 + 16) / 2, (17 + 20) /2
        #   - x: (20 + 15) / 2, (14 + 10) / 2, (9 + 5) / 2, (4 + 1) /2
        ref <- data.frame(
            time = rep(c(0.7, 1.8, 2.8, 3.7), times = 2),
            x = rep(c(3.5, 9, 14, 18.5), times = 2),
            y = rep(c(17.5, 12, 7, 2.5), times = 2),
            id = rep(1:2, each = 4)        
        )

        # Perform the test
        expect_identical(ref, tst)
    }
)

test_that(
    "Test outcome of the `bin` function: Different column names",
    {
        # Create a mock dataset that will lead to results that we know 
        # analytically
        data <- data.frame(
            seconds = rep(1:20 / 5, times = 2),
            tag = rep(1:2, each = 20),
            xco = rep(1:20, times = 2),
            yco = rep(20:1, times = 2)
        )

        # Use the bin function with the mean
        tst <- bin(
            data, 
            fx = mean,
            span = 1,
            .by = "tag",
            cols = c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco"
            )
        )

        # Create a reference
        #   - time: (0.2 + 1.2) / 2, (1.4 + 2.2) / 2, (2.4 + 3.2) / 2, (3.4 + 4) / 2
        #   - x: (1 + 6) / 2, (7 + 11) / 2, (12 + 16) / 2, (17 + 20) /2
        #   - x: (20 + 15) / 2, (14 + 10) / 2, (9 + 5) / 2, (4 + 1) /2
        ref <- data.frame(
            seconds = rep(c(0.7, 1.8, 2.8, 3.7), times = 2),            
            xco = rep(c(3.5, 9, 14, 18.5), times = 2),
            yco = rep(c(17.5, 12, 7, 2.5), times = 2),
            tag = rep(1:2, each = 4)         
        )

        # Perform the test
        expect_identical(ref, tst)
    }
)

test_that(
    "Test outcome of the `bin` function: Changing order of columns",
    {
        # Create a mock dataset that will lead to results that we know 
        # analytically
        data <- data.frame(
            seconds = rep(1:20 / 5, times = 2),
            tag = rep(1:2, each = 20),
            xco = rep(1:20, times = 2),
            yco = rep(20:1, times = 2)
        )

        # Use the bin function with the mean
        tst <- bin(
            data, 
            fx = mean,
            span = 1,
            .by = "tag",
            cols = c(
                "x" = "xco",
                "time" = "seconds",
                "y" = "yco"
            )
        )

        # Create a reference
        #   - time: (0.2 + 1.2) / 2, (1.4 + 2.2) / 2, (2.4 + 3.2) / 2, (3.4 + 4) / 2
        #   - x: (1 + 6) / 2, (7 + 11) / 2, (12 + 16) / 2, (17 + 20) /2
        #   - x: (20 + 15) / 2, (14 + 10) / 2, (9 + 5) / 2, (4 + 1) /2
        ref <- data.frame(
            xco = rep(c(3.5, 9, 14, 18.5), times = 2),
            seconds = rep(c(0.7, 1.8, 2.8, 3.7), times = 2),            
            yco = rep(c(17.5, 12, 7, 2.5), times = 2),
            tag = rep(1:2, each = 4)         
        )

        # Perform the test
        expect_identical(ref, tst)
    }
)