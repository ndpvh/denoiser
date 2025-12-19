test_that(
    "Test output of `finalize`: Grouping is involved",
    {
        # Create a mock dataset that can be prepared
        data <- data.frame(
            time = rep(1:5, times = 2),
            x = rep(1:5, times = 2),
            y = rep(5:1, times = 2),
            id = rep(1:2, each = 5)
        )

        # Finalize the data
        finalized <- finalize(
            data, 
            cols = c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco",
                "id" = "tag"
            ),
            .by = "tag"
        )

        # Test its properties
        expect_equal(
            data |>
                `colnames<-` (c("seconds", "xco", "yco", "tag")),
            finalized
        )
    }
)

test_that(
    "Test output of `finalize`: Grouping is not involved",
    {
        # Create a mock dataset that can be prepared
        data <- data.frame(
            time = rep(1:5, times = 2),
            x = rep(1:5, times = 2),
            y = rep(5:1, times = 2),
            id = rep(1:2, each = 5)
        )

        # Finalize the data
        finalized <- finalize(
            data, 
            cols = c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco",
                "id" = "tag"
            ),
            .by = NULL
        )

        # Test its properties
        expect_equal(
            data[, 1:3] |>
                `colnames<-` (c("seconds", "xco", "yco")),
            finalized
        )
    }
)

test_that(
    "Test whether `finalize` undoes what `prepare` does",
    {
        # Create a mock dataset that can be prepared
        data <- data.frame(
            seconds = rep(1:5, times = 2),
            xco = rep(1:5, times = 2),
            yco = rep(5:1, times = 2),
            tag = rep(1:2, each = 5)
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

        # Finalize the data
        finalized <- finalize(
            prepared$data, 
            cols = c(
                "time" = "seconds",
                "x" = "xco",
                "y" = "yco",
                "id" = "tag"
            ),
            .by = "tag"
        )

        expect_equal(
            data,
            finalized
        )
    }
)
