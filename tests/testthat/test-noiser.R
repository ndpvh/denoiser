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
