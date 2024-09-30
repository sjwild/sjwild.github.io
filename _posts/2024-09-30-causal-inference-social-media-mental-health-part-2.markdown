---
layout: post
title:  "Causal inference, social media, and mental health, part 2"
date:   2024-09-30 08:00:00 -0400
categories: blog
usemathjax: true

---


_This is part 2 of a ? part series. In my next post I intend to incorporate the time series element. You can find a repo with the Rmd files [here](https://github.com/sjwild/SM-and-MH)_

In my [last post](https://sjwild.github.io/blog/2024/09/21/causal-inference-social-media-mental-health-part-1.html), I showed a DAG, and why I think the the reduction experiments in the [Ferguson meta analysis](https://doi.org/10.1037/ppm0000541) could only ever estimate a small portion of the total causal effect of social media on mental health. The estimand in those RCTs isn’t useless, but it is much more limited than the discussion around it implies.

In this post I’m going to simulate some data from the final DAG in my previous post, and then we are going to run a few simple regressions to show the causal effect of closing various paths. This post includes the R code to simulate the data and the regressions to estimate the causal effect.

For this post post, I assume the following about you: 
* You are comfortable with DAGs, causal effects, and RCTs  
* You understand regressions and regression coefficients (no marginal effects this time)  
* You understand R code  
* If you aren’t comfortable with DAGs, causal effects, RCTs, regressions, or anything else I discuss, you’ll go look it up

## Some brief background
Zach Rausch and Jon Haidt have started a four-part (?) critique of a recent meta analysis by Chris Ferguson. This led to a bit of back and forth, some blog posts, and Twitter discussion. While some the discussion focused on the intricacies of meta analysis, much of the discussion assumes (or at least implies) that the RCTs are estimating the total causal effects of RCTs. As I demonstrated in my last post, I don’t think that is the case.

# Simulating some data
We’ll start by simulating some data. We’ll use the DAG below from the last post. This version differs slightly from the final DAG in that it also shows the direct path from social media to mental health.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-30-causal-inference-social-media-mental-health-part-2/DAG_all_paths.png  "A simple DAG showing a paths from social media to mental health.")

To simulate this data, I’m going to build a function. This will make it easier if we need to simulate data multiple times. I encourage you to draw your own DAG and simulate data for it.

This function takes a few arguments and returns an N by 8 dataframe. In our simulated data, higher numbers for mental health (MH) mean better mental health. So a negative effect of social media on mental health would mean our treatment effect is less than zero, while an effect greater than zero means social media leads to better mental health. In this example, I’ve set it so that the effect is negative.

I want to draw your attention to three arguments: coef_mediators, coefs_MH, and coef_direct. It’s these that determine our total causal effect.

``` r
simulate_data <- function(N = 1000,
                          seed = NULL,
                          A = 5,
                          coefs_mediators = c(-1, -.5, -2, .25),
                          coefs_MH = c(.2, .4, .3, -1),
                          coef_direct = -.4,
                          coef_OA = .75
                          ){
  
  if(!is.null(seed)){
    set.seed(seed)
  }
  
  # SM
  SM <- runif(N) 
  # written in a verbose way to make the steps clear
  # causal effects from SM to mediators
  OS <- SM * coefs_mediators[1] + rnorm(N)
  OP <- SM * coefs_mediators[2] + rnorm(N)
  FM <- SM * coefs_mediators[3] + rnorm(N)
  FR <- SM * coefs_mediators[4] + rnorm(N)
  
  # causal effects of mediators on MH
  # low numbers = worse MH
  MH <- A + OS * coefs_MH[1] +
    OP * coefs_MH[2] +
    FM * coefs_MH[3] +
    FR * coefs_MH[4] + rnorm(N)
  
  # add in direct effects of OA and SM
  OA <- runif(N)
  MH <- MH + OA * coef_OA +
    coef_direct * SM

  d <- data.frame(SM = SM,
                  OS = OS,
                  OP = OP,
                  FM = FM,
                  FR = FR,
                  OA = OA,
                  MH = MH)
  
  return(d)
  
}

d <- simulate_data(seed = 8675309)
```

## Estimating the total causal effect
Because this is simulated data, we know both the total causal effect, the indirect effects, and the direct effect. To find the total causal effect, we can do some simple math. To figure out the causal effect on any given path, say from SM -> OS -> MH, we simply multiply coefficients together (thank you for the inspiration, front door criterion!).

``` r
path_SM_OS_MH <- -1 * .2
path_SM_OS_MH
```

    ## [1] -0.2

We can see, then, that the causal effect of SM -> OS -> MH is -0.2. To figure out the total causal effect then, we add all the paths from SM -> MH together.

``` r
total_causal_effect <- (-1 * .2) + # SM -> OS -> MH
  (-.5 * .4) + # SM -> OP -> MH
  (-2 * .3) +  # SM -> FM -> MH
  (.25 * -1) + # SM -> FR -> MH
  -.4          # direct effect
  
total_causal_effect
```

    ## [1] -1.65

Based on this, our total causal effect should be around -1.65: That is, SM negatively affects mental health by 1.65 points.

## The direct effect
As I mentioned, this is simulated data, so we know the truth. And we know that the total effect is -1.65. What does our regression show?

``` r
mod_total <- lm(MH ~ SM, data = d)

summary(mod_total)
```

    ## 
    ## Call:
    ## lm(formula = MH ~ SM, data = d)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -5.0978 -1.0437 -0.0244  1.0151  5.0774 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  5.53923    0.09396   58.95   <2e-16 ***
    ## SM          -1.86304    0.16479  -11.31   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.509 on 998 degrees of freedom
    ## Multiple R-squared:  0.1135, Adjusted R-squared:  0.1126 
    ## F-statistic: 127.8 on 1 and 998 DF,  p-value: < 2.2e-16

From the regression above, we can see the estimated causal effect in our simulated data is -1.86. That’s negative, and close to the total causal effect we calculated earlier.

What happens if we block all the other paths?

``` r
mod_mediators <- lm(MH ~ SM + OS + OP + FR + FM, data = d)

summary(mod_mediators)
```

    ## 
    ## Call:
    ## lm(formula = MH ~ SM + OS + OP + FR + FM, data = d)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -3.2381 -0.7506 -0.0264  0.6952  2.7542 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  5.46025    0.06404  85.264  < 2e-16 ***
    ## SM          -0.54539    0.13557  -4.023 6.19e-05 ***
    ## OS           0.17871    0.03200   5.585 3.01e-08 ***
    ## OP           0.39410    0.03095  12.733  < 2e-16 ***
    ## FR          -1.00445    0.03316 -30.295  < 2e-16 ***
    ## FM           0.25824    0.03207   8.052 2.32e-15 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.027 on 994 degrees of freedom
    ## Multiple R-squared:  0.5913, Adjusted R-squared:  0.5893 
    ## F-statistic: 287.7 on 5 and 994 DF,  p-value: < 2.2e-16

We can see, in our simulated data, that the estimated direct effect is -0.55, which is close to its true value of -0.4.

## A more intereting example
Why does this matter? Because if we don’t account for the other paths we are underestimating the effect in our above example. But what if we change things a bit more? What if the other paths aren’t negative?

``` r
d_positive <- simulate_data(seed= 8675309,
                            coefs_mediators = c(.3, .4, 1, 2),
                            coefs_MH = c(.4, 1, .75, .3))

mod_positive <- lm(MH ~ SM, data = d_positive)

summary(mod_positive)
```

    ## 
    ## Call:
    ## lm(formula = MH ~ SM, data = d_positive)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -5.2474 -1.1742  0.0507  1.1777  6.8218 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)   5.4894     0.1065  51.541  < 2e-16 ***
    ## SM            1.3315     0.1868   7.128 1.95e-12 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.71 on 998 degrees of freedom
    ## Multiple R-squared:  0.04845,    Adjusted R-squared:  0.0475 
    ## F-statistic: 50.81 on 1 and 998 DF,  p-value: 1.945e-12

We can see here that the total causal effect is 1.33. If we do the math, we can see that the total causal effect is positive.

``` r
total_causal_effect_positive <- (.3 * .4) + # SM -> OS -> MH
  (.4 * 1) +   # SM -> OP -> MH
  (1 * .75) +  # SM -> FM -> MH
  (2 * .3) +   # SM -> FR -> MH
  -.4          # direct effect
  
total_causal_effect_positive
```

    ## [1] 1.47

And if we run our regression like normal, we can indeed see the direct effect is negative.

``` r
mod_positive_all <- lm(MH ~ SM + OS + OP + FR + FM, data = d_positive)

summary(mod_positive_all)
```

    ## 
    ## Call:
    ## lm(formula = MH ~ SM + OS + OP + FR + FM, data = d_positive)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -3.2381 -0.7506 -0.0264  0.6952  2.7542 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  5.46025    0.06404  85.264  < 2e-16 ***
    ## SM          -0.37932    0.13591  -2.791  0.00535 ** 
    ## OS           0.37871    0.03200  11.836  < 2e-16 ***
    ## OP           0.99410    0.03095  32.118  < 2e-16 ***
    ## FR           0.29555    0.03316   8.914  < 2e-16 ***
    ## FM           0.70824    0.03207  22.083  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.027 on 994 degrees of freedom
    ## Multiple R-squared:  0.6586, Adjusted R-squared:  0.6569 
    ## F-statistic: 383.5 on 5 and 994 DF,  p-value: < 2.2e-16

## Of course, it’s not that simple
In real life, we don’t know the total causal effect. That’s why we’re doing the work! Personally, I think there is probably a small negative direct effect of social media on mental health. I am agnostic about the indirect effects: I have no idea if they are positive, negative, or how they interact. Things that appear simple at the individual level can lead to complex, unpredictable outcomes at the network level.

## References and other resources
Bailey, Drew H., Alexander J. Jung, Adriene M. Beltz, Markus I. Eronen,
Christian Gische, Ellen L. Hamaker, Konrad P. Kording et al. “Causal
inference on human behaviour.” _Nature Human Behaviour_ 8, no. 8 (2024):
1448-1459. <https://doi.org/10.1038/s41562-024-01939-z>.

Bellemare, Marc F., Jeffrey R. Bloem, and Noah Wexler. “The Paper of
How: Estimating Treatment Effects Using the Front‐Door Criterion.”
_Oxford Bulletin of Economics and Statistics_ 86, no. 4 (2024): 951-993.
<https://doi.org/10.1111/obes.12598>.

Ding, Peng. _A first course in causal inference_. CRC Press, 2024.

Ferguson, Christopher J. “Do social media experiments prove a link with
mental health: A methodological and meta-analytic review.” _Psychology
of Popular Media_ (2024). <https://doi.org/10.1037/ppm0000541>.

Huntington-Klein, Nick. _The effect: An introduction to research design
and causality_. Chapman and Hall/CRC, 2021.
<https://www.taylorfrancis.com/books/mono/10.1201/9781003226055/effect-nick-huntington-klein>.

Lundberg, Ian, Rebecca Johnson, and Brandon M. Stewart. “What is your
estimand? Defining the target quantity connects statistical evidence to
theory.” _American Sociological Review_ 86, no. 3 (2021): 532-565.
<https://doi.org/10.1177/00031224211004187>.

Morgan, Stephen, and Christopher Winship. _Counterfactuals and causal
inference_. Cambridge University Press, 2015.

Pearl, Judea. _Causal inference in statistics: a primer_. John Wiley &
Sons, 2016.