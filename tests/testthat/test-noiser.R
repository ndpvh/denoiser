test_that(
    "Provide your own function for noising up works",
    {
        # Create a data.frame
        data <- data.frame(
            time = 1:100,
            x = 1:100,
            y = 1:100
        )

        # Provide your own function to noiser
        tst <- noiser(
            data,
            model = function(x) x
        )

        # Check whether both data.frames are identical
        expect_equal(tst, data)
    }
)

test_that(
    "Retaining additional columns in noiser works",
    {
        # Create a data.frame
        data <- data.frame(
            time = 1:100,
            x = 1:100,
            y = 1:100,
            column_1 = 2 * (1:100)
        )

        # Provide your own function to noiser
        tst <- noiser(
            data,
            cols = c(
                "time" = "time",
                "x" = "x",
                "y" = "y",
                "var_1" = "column_1"
            ),
            model = "independent"
        )

        # Check whether both data.frames are identical
        expect_equal(
            colnames(tst), 
            c("time", "x", "y", "column_1")
        )
        expect_equal(
            tst$column_1, 
            2 * (1:100)
        )
    }
)
