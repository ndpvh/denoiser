# denoiser

<!-- badges: start -->

[![GitHub Release](https://img.shields.io/github/v/release/npdvh/denoiser)](https://github.com/ndpvh/denoiser/releases)
[![GitHub License](https://img.shields.io/github/license/ndpvh/denoiser)](https://github.com/ndpvh/denoiser/blob/main/LICENSE)
[![Documentation](https://img.shields.io/readthedocs/denoiser/v0.1.0)](https://ndpvh.github.io/denoiser)
[![R-CMD-check](https://github.com/ndpvh/denoiser/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ndpvh/denoiser/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ndpvh/denoiser/graph/badge.svg)](https://app.codecov.io/gh/ndpvh/denoiser)
<!-- badges: end -->

## Overview

Package containing functions for adding noise to and filtering out noise from positional data, that is data that contains measurements of x- and y-coordinates. This package implements code that allows for the addition of realistic noise to simulated data and for the user to employ a realistic filtering pipeline to simulated and empirical data, therefore allowing for realistic recovery studies for pedestrian modelers. Answers this specific need for the [Minds for Mobile Agents](https://www.ampl-psych.com/projects/minds-for-mobile-agents/) pedestrian model implemented in the [predped package](https://github.com/ndpvh/predped), but can be more broadly applied. 

The implementation of this package and the defaults provided to the arguments of its functions is heavily based on results of a study conducted by Dr. Niels Vanhasbroeck and Prof. Dr. Andrew Heathcote, the repository of which you can find [here](https://github.com/ndpvh/calibration-movement-data).

## Getting started

### Installation

You can install the package from Github through the command:

```{r}
remotes::install_github("ndpvh/denoiser")
```

Once installed, you can load the package through the `library` function.

```{r}
library(denoiser)
```

### Usage

The primary functionality of this package is provided through two functions, namely `noiser` and `denoiser`. Imagine that we have data that contains circular movement, such as in the following case:

```{r}
# Create x- and y-coordinates for a person walking in a full circle
angles <- seq(0, 2 * pi, length.out = 50)
data <- data.frame(
    time = 1:50, 
    x = 10 * cos(angles),
    y = 10 * sin(angles)
)

# Plot these data
plot(data$x, data$y)
```

Then we can add ``realistic'' noise to these data by using the `noiser` function. Specifically, we call:

```{r}
# Noise up the data
noised_up <- noiser(
    data
)

# Plot the noised up data
plot(noised_up$x, noised_up$y)
```

To decrease the noise again, we call the `denoiser` function:

```{r}
# Denoise the data
denoised <- denoiser(
    data
)

# Plot the denoised data
plot(denoised$x, denoised$y)
```

## Getting help

You can find detailed documentation of the functions in this package as well as examples on the [Documentation site](https://ndpvh.github.io/denoiser). If you encounter a bug, please file an issue with a minimal working example on [Github](https://github.com/ndpvh/denoiser/issues). 

