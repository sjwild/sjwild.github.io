---
layout: post
title:  "How correlated predictors inflate your standard errors"
date:   2022-01-28 08:00:00 -0400
categories: blog
---

On Twitter, Nicolai Birk [asks a very good question](https://twitter.com/nicolaiberk/status/1483498750375079936?s=20): Why are standard errors infalted when predictors are correlated?

The answer requires us to look at linear regression using linear algebra. 

Before we begin I am goin to lay out a few of my assumptions:
* You have a basic understanding of R
* You understand basic linear algebra
* You understand the jargon and linear algebra of linear regression
* You care about what I have to say

With that out of the way, let's load R and simulate some data.


```R
> library(tidyverse)

# set seed for reproducibility
> set.seed(4318431)


# number of observations and predictors
> N <- 10000 
> k <- 4

# beta coefficients
> beta <- c(1, 2, 3, 4)

# create uncorrelated predictors
> X1 <- rnorm(N)
> X2 <- rnorm(N)
> X3 <- rnorm(N)
> X4 <- rnorm(N)

# create correlated predictor by adding error to X3
> X4c <- rnorm(N, mean = X3, sd = 0.6)

# create error
> epsilon <- rnorm(N)

# create two matrices for matrix multiplication
> X <- cbind(X1, X2, X3, X4)
> Xc <- cbind(X1, X2, X3, X4c)

# create y variable
> y <- X %*% beta + epsilon
> yc <- Xc %*% beta + epsilon

# create dataframe for lm
> df <- data.frame(y = y,
                   yc = yc,
                   X1 = X1,
                   X2 = X2,
                   X3 = X3, 
                   X4 = X4,
                   X4c = X4c)

```

Let's look at the correlations between our variables.

```R
> cor(X)
             X1            X2          X3            X4
X1  1.000000000  0.0068828292 -0.01765323 -0.0048219861
X2  0.006882829  1.0000000000 -0.00114330 -0.0001925307
X3 -0.017653232 -0.0011432996  1.00000000 -0.0159224522
X4 -0.004821986 -0.0001925307 -0.01592245  1.0000000000

> cor(Xc)
              X1           X2          X3          X4c
X1   1.000000000  0.006882829 -0.01765323 -0.021663734
X2   0.006882829  1.000000000 -0.00114330  0.002480374
X3  -0.017653232 -0.001143300  1.00000000  0.858805628
X4c -0.021663734  0.002480374  0.85880563  1.000000000

```

In the first matrix, we can see from these correlation between predictors is essentially 0. In the second matrix, we can see the correlation between predictors 3 and 4. The correlation is .86, which is (intentionally) high.

Now we're to get into the linear algebra. To make sure we estimated the data properly, we'll start by using `lm()` to make sure we get the proper coefficients. We'll be comparing our linear algebra results with the output below.

```R
> summary(lm(y ~ 0 + X1 + X2 + X3 + X4, data = df))

Call:
lm(formula = y ~ 0 + X1 + X2 + X3 + X4, data = df)

Residuals:
    Min      1Q  Median      3Q     Max 
-4.1776 -0.6744  0.0103  0.6877  3.5138 

Coefficients:
   Estimate Std. Error t value Pr(>|t|)    
X1 1.006688   0.009895   101.7   <2e-16 ***
X2 1.997917   0.009786   204.2   <2e-16 ***
X3 2.990470   0.009867   303.1   <2e-16 ***
X4 4.003829   0.009826   407.5   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.9902 on 9996 degrees of freedom
Multiple R-squared:  0.9684,	Adjusted R-squared:  0.9684 
F-statistic: 7.655e+04 on 4 and 9996 DF,  p-value: < 2.2e-16

> summary(lm(yc ~ 0 + X1 + X2 + X3 + X4c, data = df))

Call:
lm(formula = yc ~ 0 + X1 + X2 + X3 + X4c, data = df)

Residuals:
    Min      1Q  Median      3Q     Max 
-4.1718 -0.6740  0.0099  0.6881  3.5155 

Coefficients:
    Estimate Std. Error t value Pr(>|t|)    
X1  1.006696   0.009895   101.7   <2e-16 ***
X2  1.997946   0.009789   204.1   <2e-16 ***
X3  2.989428   0.019204   155.7   <2e-16 ***
X4c 4.001003   0.016569   241.5   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.9902 on 9996 degrees of freedom
Multiple R-squared:  0.9837,	Adjusted R-squared:  0.9837 
F-statistic: 1.512e+05 on 4 and 9996 DF,  p-value: < 2.2e-16

```

That's perfect. Our coefficients are close to 1, 2, 3, and 4, which is exactly how we set them up in the code above. Now to the linear algebra. First, we're going to calculate the Gram matrix, then we're going to calculate the coefficients. We'll need to save all our values for later.

```R
> XtX <- t(X) %*% X
> beta_est <- as.matrix(solve(XtX)) %*% t(X) %*% y
> beta_est
       [,1]
X1 1.006688
X2 1.997917
X3 2.990470
X4 4.003829

```

As we can see, our beta estimates are pretty close! Not exactly the same, but approximately the same to 2 decimal places. 

Now we're going to produce the hat matrix. We will use this to compute yhat and get our residuals. We can then compute sigma, or the standard deviation of the residuals. We'll need sigma to compute our standard errors.

```R
> hat <- X %*% as.matrix(solve(XtX)) %*% t(X)
> yhat <- hat %*% y
> resids <- y - yhat
> dof <- N-k
> sigma <- sqrt(sum(resids^2) / (dof))

```

Now, to compute our standard errors. 

```R
> ses <- sqrt(diag(XtXinv)) * sigma
> ses
         X1          X2          X3          X4 
0.009894676 0.009785941 0.009867064 0.009825521 

```

Those values are almost identical to the values that we got using `lm()`. Success! You can see that the standard errors are almost completely the same. They should be, in this case, because each predictor has similar variance. But what happens when we repeat this process with our correlated predictors?

```R
> XctXc <- t(Xc) %*% Xc
> beta_est_c <- as.matrix(solve(XctXc)) %*% t(Xc) %*% yc
> beta_est_c
        [,1]
X1  1.006696
X2  1.997946
X3  2.989428
X4c 4.001003

> hat_c <- Xc %*% as.matrix(solve(XctXc)) %*% t(Xc)
> yhat_c <- hat_c %*% yc
> resids_c <- yc - yhat_c
> sigma_c <- sqrt(sum(resids_c^2) / (dof))
> XctXcinv <- solve(XctXc)
> ses_c <- sqrt(diag(XctXcinv)) * sigma_c
> ses_c
         X1          X2          X3         X4c 
0.009894765 0.009788536 0.019203585 0.016568743

```

This time, we can see the standard errors for X3 and X4c are twice as large as the uncorrelated predictors. What is going on? Simply put, we are having a hard time separating the effects of X3 and X4c because they are correlated--that is, they move together.

To keep going, I want to spend a little bit of time looking at the two key matrices that get us our standard errors. 

```R
> XtXinv <- solve(XtX)
> XtX
            X1          X2         X3          X4
X1 10022.53614    36.58272  -268.4263    26.80182
X2    36.58272 10242.12974  -128.7449   118.50923
X3  -268.42633  -128.74490 10081.5466  -121.57116
X4    26.80182   118.50923  -121.5712 10159.56235

> XtX / N
             X1           X2          X3           X4
X1  1.002253614  0.003658272 -0.02684263  0.002680182
X2  0.003658272  1.024212974 -0.01287449  0.011850923
X3 -0.026842633 -0.012874490  1.00815466 -0.012157116
X4  0.002680182  0.011850923 -0.01215712  1.015956235

```

Our first matrix is XtX. Rembember, we got XtX by going `XtX <- t(X) %*% X`. XtX is a square matrix. If the predictors were truly uncorrelated with one another, only the diagonal cells would have any values; all the others would be zero. You can see that there is very little covariance between the predictors. The off-diagonal elements are still essentially zero when compared to the diagonal elements. To better illustrate this, we can take XtX and divid it by the number of observations. This gets us an approximate covariance matrix. As you can see, the off-diagonal elements are roughly zero, while the diagonal elements are roughly one. At the beginning of this post, we simulated each predictor to have a mean zero and standard deviation of one. You can see the variance reflected in the diagonal elements. 

Our next matrix is the inverse of XtX. 

```R
> XtXinv
              X1            X2           X3            X4
X1  9.984794e-05 -3.206666e-07 2.651659e-06 -2.279369e-07
X2 -3.206666e-07  9.766549e-05 1.225134e-06 -1.123742e-06
X3  2.651659e-06  1.225134e-06 9.929145e-05  1.166853e-06
X4 -2.279369e-07 -1.123742e-06 1.166853e-06  9.845711e-05

```

Intuitively, we find the inverse of a matrix by finding the row operations that "undo" the row operations necessary to transform the identiy matrix into XtX. The identiy matrix, recall, is ones on the diagonal and zeros everywhere else.

```R
> diag(4)
     [,1] [,2] [,3] [,4]
[1,]    1    0    0    0
[2,]    0    1    0    0
[3,]    0    0    1    0
[4,]    0    0    0    1

```

So, in the case of uncorrelated predictors, most of the information we need to transform XtX into the identity matrix is contained in the diagonal elements of XtX. Therefore there are relatively few operations involving the other cells of XtX. In this sense, information is "concentrated" in one area.

But what happens when predictors are correlated?

```R
> XctXc
             X1          X2         X3         X4c
X1  10022.53614    36.58272  -268.4263  -249.09859
X2     36.58272 10242.12974  -128.7449    25.89597
X3   -268.42633  -128.74490 10081.5466 10022.20725
X4c  -249.09859    25.89597 10022.2072 13537.39397
> XctXc / N
              X1           X2          X3          X4c
X1   1.002253614  0.003658272 -0.02684263 -0.024909859
X2   0.003658272  1.024212974 -0.01287449  0.002589597
X3  -0.026842633 -0.012874490  1.00815466  1.002220725
X4c -0.024909859  0.002589597  1.00222072  1.353739397

```

Wait! We can see that, while most of the elements are nearly zero, two elements are much larger: XctXc[3, 4] and XctXc[4, 3]. So to transform XctXc into the identity matrix, our operations also need to account for the information contained in those two cells. In this sense, information is more dispersed. This is reflected in the values along the diagonal of the inverse of XctXc. 

```R
> XctXcinv
               X1            X2            X3           X4c
X1   9.984825e-05 -3.160249e-07  3.133833e-06 -4.821966e-07
X2  -3.160249e-07  9.771584e-05  5.420199e-06 -4.205501e-06
X3   3.133833e-06  5.420199e-06  3.760920e-04 -2.783868e-04
X4c -4.821966e-07 -4.205501e-06 -2.783868e-04  2.799682e-04

```

So what can we do? Like always, it depends. Sometimes it doesn't matter, so you can leave it alone. Other times, you need to break the correlation, maybe by mean-centering or standaridizing your variables. Maybe you pick one predictor and leave the other. Ask your local statistician.

And with that, I've done what I came do: give an intuitive sense via linear algebra of why correlated predictors have higher standard errors.

Oh right, the standard errors. Here they are one last time.

```R
> ses
         X1          X2          X3          X4 
0.009894676 0.009785941 0.009867064 0.009825521 

> ses_c
         X1          X2          X3         X4c 
0.009894765 0.009788536 0.019203585 0.016568743 
```
