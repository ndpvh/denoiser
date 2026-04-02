test_that(
    "Known errors work",
    {
        # Not a data.fame
        expect_error(prepare(matrix(0, nrow = 10, ncol = 2)))
        expect_error(prepare(numeric(10)))
        expect_error(prepare(character(10)))
        expect_error(prepare(logical(10)))

        # Provided column names don't make sense
        cols <- c(
            "time" = "time", 
            "x" = "x",
            "test" = "test"
        )
        expect_error(
            prepare(
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
            prepare(
                data.frame(
                    time = 1:10,
                    x = 1:10,
                    y = 1:10
                ),
                cols = cols
            )
        )

        expect_error(
            prepare(
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
    "Test outcome of `prepare`",
    {
        # Create a mock dataset that can be prepared
        data <- data.frame(
            seconds = rep(1:5, times = 2),
            tag = rep(1:2, each = 5),
            xco = rep(1:5, times = 2),
            yco = rep(5:1, times = 2)
        )

        # Prepare the data
        prepared <- prepare(
            data, 
            cols = c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco"
            ),
            .by = "tag"
        )

        # Test its properties
        expect_equal(
            c("data", "cols", "group"), 
            names(prepared)            
        )

        expect_equal(
            c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco",
                "id" = "tag"
            ),
            prepared$cols            
        )

        expect_equal(
            1:2, 
            prepared$group
        )

        expect_equal(
            data[, c(1, 3, 4, 2)] |>
                `colnames<-` (c("time", "x", "y", "id")),
            prepared$data
        )
    }
)

test_that(
    "Test whether non-default columns are retained",
    {
        # Create a mock dataset to be prepared
        data <- data.frame(
            time = rep(1:5, times = 2),
            id = rep(1:2, each = 5),
            x = rep(1:5, times = 2),
            y = rep(5:1, times = 2),
            column_1 = rep(1, times = 10),
            column_2 = rep(2, times = 10),
            column_3 = rep(3, times = 10),
            column_4 = 1:10
        )

        # Prepare the dataset
        prepared <- prepare(
            data,
            cols = c(
                "time" = "time",
                "x" = "x",
                "y" = "y",
                "var_1" = "column_1",
                "var_2" = "column_2",
                "var_3" = "column_3",
                "var_4" = "column_4"
            ),
            .by = "id"
        )

        # Check the column names
        expect_equal(
            colnames(prepared$data),
            c("time", "x", "y", "var_1", "var_2", "var_3", "var_4", "id")
        )

        # Check the content
        expect_equal(
            prepared$data$var_1, 
            rep(1, 10)
        )
        expect_equal(
            prepared$data$var_2, 
            rep(2, 10)
        )
        expect_equal(
            prepared$data$var_3, 
            rep(3, 10)
        )
        expect_equal(
            prepared$data$var_4,
            1:10
        )
    }
)
