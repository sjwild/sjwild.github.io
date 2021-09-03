---
layout: post
title:  "Always center your variables in multilevel models"
date:   2021-09-02 21:00:00 -0400
categories: blog
---

This is a post about why you should always center your variables in multilevel models. Always. And by always, I mean it depends. But I think as a default, you should center your variables in a multilevel model unless there is a strong reason to do otherwise.

What inspired this post is a recent article, [Worldwide increases in adolescent loneliness](https://www.sciencedirect.com/science/article/pii/S0140197121000853), by Jean Twenge, Jonathan Haidt, et al. In the article, they claim to show that the psychological well-being of adolescents began to decline in 2012, and that this decline is associated with increased smart phone access and internet usage. Twitter had several threads or tweets ([here](https://twitter.com/sTeamTraen/status/1421860781503700993), [here](https://twitter.com/cjsewall9/status/1421461127892979712), and [here](https://twitter.com/academia_shores/status/1428052060512129029), for example) about why Twenge et al. were wrong. I have no informed view about whether smartphone access and internet usage are associated with loneliness. That isn't my area of expertise, and I don't want to give the impression that it is.

But I am able to critique their model.

Part of their argument rests on a multilevel model they conduct on smartphone access and internet usage. But they make a common but elementary error in how they structure their model. Once you properly structure the model, their effects mostly disappear.

Before I look at their model, I am going to make a few assumptions:
* There is no measurement error, that is, their constructs measure what they say the constructs should measure and does so accurately
* The predictors they include are correct and appropriate for what they are looking at
* Their decisions to include or exclude certain countries are justifiable
* Missing data is Missing Completely At Random (MCAR), so missing countries/year have no effect on the outcome
* It makes sense to aggregate the data to conduct an ecological regression

In short, I am going to assume that everything was done correctly except for the final two models.

You can find the code I used for my models [here](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-09-02-always_centre-variables-multilevel-model/Load_and_Prep_PISA_data.R). If I am wrong, please tell me so I can correct it.

# _Twenge et al._'s results
In their final two models, Twenge et al. run a comprehensive model using smartphone access and internet usage as their treatment variables--that is, as their main variables of interest. Here is a copy of their results.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-09-02-always-centre-variables-multilevel-model/Table_4_Twenge_et_al.png "Image of Table 4 from Twenge et al..")

In both their models, smartphone access and internet usage are statistically significant. Unfortunately, Twenge et al.'s model is misspecified, and their results showing smartphone access and internet usage are not significant once we make the requisite adjustments.

# How is the model misspecified?
Multilevel models are loved in some fields (looking at you, education and psychology) and reviled in others (looking at you, economics). The issue is the use of random effects. Random effects are awesome, but they lead to biased esimates when the fixed effects are correlated with the random effects.

To see what I mean, take a look at the image below. In it, I have chosen three illustrative countries and their smartphone access. As you can see, there is a relationship between smartphone access in 2012 and the rate of smartphone access increases over time. Countries with lower rates of smartphone access increase at faster rates. That is, we can say that the intercept (initial smartphone access) is negatively correlated with the slope (change in access over time): in countries with higher initial smartphone access, smartphone access increases more slowly compared to countries with lower initial smartphone access. As a result, smartphone access coverges over time.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-09-02-always-centre-variables-multilevel-model/example_smushed_effects.png "Illustrative example showing slopes increase faster for lower intial rates of smartphone access")

Here is what is happening in our multilevel model. The model is trying to estimate the effect of smartphone access in two areas: within each country, and between each country. The problem is that the model has no way to separate these two effects. Therefore the coefficient ends up "smushed" (the technical term, according to Hoffman, 2015), and reflects both within country and between country effects.

But we can help it by breaking the variable in two.

The most common way to make the adjustment is to center the predictors in the model. Three methods are common: group-mean centering, grand-mean centering, and baseline centering. 

With group-mean centering--also called adaptive centering, person-mean centering, or centering within context--for each observation in a group, we subtract out the mean for that group. So for a given predictor what we have is $x_{ij}$ - $\bar{x_{j}}$. Using this method, we can decompose our effect into within groups and between groups. Why? Because we took out the group differences. This type of centering is common in cross-sectional multilevel models.

With grand-mean centering, we take out the grand mean or any other meaningful constant. We then have $x_{i}$ - $\bar{x}$. We often see this in bayesian modelling, where we center our predictors and then divide by the standard deviation (this helps the samplers run faster).

The third option is baseline centering. Baseline centering is similar to grand-mean centering. But instead of the grand-mean, we subtract out the value at a baseline--say, the value at time 0. This method is common for longitudinal data.

With all three centering methods, it is common to add the group means as predictors, to help detect any between group differences. This is relevant for the work in Twenge et al., because there might be an effect of smartphone access within a country, but not between countries, or vice versa. Or there might be an effect within and between countries. Or there might not be.

# What happens when we center our variables?
As you can see in the image for our illustrative example below, one we remove the means for our baseline year, 2012, the slopes are not longer correlated with the values at year 0. The model can therefore pick up both within and between effects if me include the initial values in the model as well. Mission accomplished.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-09-02-always-centre-variables-multilevel-model/example_smushed_effects_0_intercept.png "Illustrative example showing intercept at zero")

# Modelling PISA data
Moving on to Twenge et al. Let's take a look at their comprehensive model for the effect of smartphone access. I've done some data cleaning to try duplicate their coding, and I think I managed to get reasonably close to their results. 

```r

> mod_sp <- lmer(loneliness ~ 1 + Smartphone + 
                 year +
                 SL.UEM.TOTL.ZS +
                 I(NY.GDP.MKTP.CD / 1e10) +
                 SI.POV.GINI + 
                 SP.DYN.TFRT.IN + 
                 (1 + year | cnt),
               data = df)
> summary(mod_sp)

Linear mixed model fit by REML ['lmerMod']
Formula: loneliness ~ 1 + Smartphone + year + SL.UEM.TOTL.ZS + I(NY.GDP.MKTP.CD/1e+10) +  
    SI.POV.GINI + SP.DYN.TFRT.IN + (1 + year | cnt)
   Data: df

REML criterion at convergence: -71

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.79360 -0.53023 -0.02428  0.51172  1.37118 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr
 cnt      (Intercept) 1.318e-02 0.114801     
          year        5.884e-05 0.007671 0.02
 Residual             2.103e-03 0.045855     
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                          Estimate Std. Error t value
(Intercept)              1.3885407  0.1793727   7.741
Smartphone               0.0036840  0.0011172   3.298
year                     0.0181475  0.0056562   3.208
SL.UEM.TOTL.ZS          -0.0034440  0.0037136  -0.927
I(NY.GDP.MKTP.CD/1e+10) -0.0005470  0.0003473  -1.575
SI.POV.GINI              0.0083550  0.0044505   1.877
SP.DYN.TFRT.IN          -0.0460839  0.0634102  -0.727

Correlation of Fixed Effects:
            (Intr) Smrtph year   SL.UEM I(NY.G SI.POV
Smartphone  -0.624                                   
year         0.384 -0.752                            
SL.UEM.TOTL -0.125 -0.023  0.366                     
I(NY.GDP.MK  0.129  0.030 -0.002  0.137              
SI.POV.GINI -0.594  0.198 -0.242 -0.345 -0.398       
SP.DYN.TFRT -0.324 -0.016  0.129  0.347  0.055 -0.373



> mod_int <- lmer(loneliness ~ 1 + Internet + 
                  year +
                  SL.UEM.TOTL.ZS +
                  I(NY.GDP.MKTP.CD / 1e9) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                  (1 + year | cnt),
                data = df)
boundary (singular) fit: see ?isSingular
Warning message:
Some predictor variables are on very different scales: consider rescaling 

> summary(mod_int)
Linear mixed model fit by maximum likelihood  ['lmerMod']
Formula: loneliness ~ 1 + Internet + year + SL.UEM.TOTL.ZS + I(NY.GDP.MKTP.CD/1e+09) +  
    SI.POV.GINI + SP.DYN.TFRT.IN + (1 + year | cnt)
   Data: df

     AIC      BIC   logLik deviance df.resid 
  -109.9    -86.7     66.0   -131.9       50 

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.96300 -0.46962 -0.02869  0.58109  1.76058 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr
 cnt      (Intercept) 8.200e-03 0.090551     
          year        1.218e-05 0.003489 1.00
 Residual             2.656e-03 0.051540     
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                          Estimate Std. Error t value
(Intercept)              1.562e+00  1.507e-01  10.363
Internet                 7.123e-02  3.320e-02   2.145
year                     1.797e-02  7.701e-03   2.333
SL.UEM.TOTL.ZS          -3.172e-03  3.358e-03  -0.945
I(NY.GDP.MKTP.CD/1e+09) -4.102e-05  3.139e-05  -1.307
SI.POV.GINI              5.155e-03  3.922e-03   1.314
SP.DYN.TFRT.IN          -3.638e-02  5.663e-02  -0.643

Correlation of Fixed Effects:
            (Intr) Intrnt year   SL.UEM I(NY.G SI.POV
Internet    -0.584                                   
year         0.464 -0.887                            
SL.UEM.TOTL -0.173  0.022  0.215                     
I(NY.GDP.MK  0.117  0.061 -0.038  0.155              
SI.POV.GINI -0.443 -0.076  0.000 -0.358 -0.441       
SP.DYN.TFRT -0.409  0.133 -0.040  0.377  0.101 -0.412
fit warnings:
Some predictor variables are on very different scales: consider rescaling
optimizer (nloptwrap) convergence code: 0 (OK)
boundary (singular) fit: see ?isSingular


```

They made an interesting choice here with GDP. I think they took gross GDP and then divided by 1 billion. When I do so, I get coefficients that are similar. 

If you look at the correlation of the fixed effects, you can see that they are -0.624 for smartphone access and -0.584 for internet usage. Those are pretty strong, and are good suggestions that our coefficients are biased.


## Centering the variables
Now let's center our variables at their first observed values. For most countries, this is 2012, but for a few it is 2015. We are also going to grand-mean center the baseline means, to help break the correlation between the random effects and the fixed effects.


```r

> df <- df %>%
  group_by(cnt) %>%
  mutate(Smartphone_2012 = dplyr::first(Smartphone, order_by = year),
         Internet_2012 = dplyr::first(Internet, order_by = year),
         SL.UEM.TOTL.ZS_2012 = dplyr::first(SL.UEM.TOTL.ZS, order_by = year),
         NY.GDP.MKTP.CD_2012 = dplyr::first(log(NY.GDP.MKTP.CD), order_by = year),
         NY.GDP.MKTP.CD_2012_unlogged = dplyr::first(NY.GDP.MKTP.CD, order_by = year) / 1e10,
         NY.GDP.PCAP.CD_2012 = dplyr::first(log(NY.GDP.PCAP.CD), order_by = year),
         SI.POV.GINI_2012 = dplyr::first(SI.POV.GINI, order_by = year),
         SP.DYN.TFRT.IN_2012 = dplyr::first(SP.DYN.TFRT.IN, order_by = year),
         Smartphone_tc = Smartphone - Smartphone_2012,
         Internet_tc = Internet - Internet_2012,
         SL.UEM.TOTL.ZS_tc = SL.UEM.TOTL.ZS - SL.UEM.TOTL.ZS_2012,
         NY.GDP.MKTP.CD_tc = log(NY.GDP.MKTP.CD) - NY.GDP.MKTP.CD_2012,
         NY.GDP.PCAP.CD_tc_unlogged = (NY.GDP.PCAP.CD / 1e10) - NY.GDP.MKTP.CD_2012_unlogged,
         NY.GDP.PCAP.CD_tc = log(NY.GDP.PCAP.CD) - NY.GDP.PCAP.CD_2012,
         SI.POV.GINI_tc = SI.POV.GINI - SI.POV.GINI_2012,
         SP.DYN.TFRT.IN_tc = SP.DYN.TFRT.IN - SP.DYN.TFRT.IN_2012) %>%
  ungroup() %>%
  mutate(Smartphone_2012 = Smartphone_2012 - mean(Smartphone_2012),
         Internet_2012 = Internet_2012 - mean(Internet_2012),
         SL.UEM.TOTL.ZS_2012 = SL.UEM.TOTL.ZS_2012 - mean(SL.UEM.TOTL.ZS_2012),
         NY.GDP.MKTP.CD_2012 = NY.GDP.MKTP.CD_2012 - mean(NY.GDP.MKTP.CD_2012),
         NY.GDP.MKTP.CD_2012_unlogged = NY.GDP.MKTP.CD_2012_unlogged - mean(NY.GDP.MKTP.CD_2012_unlogged),
         NY.GDP.PCAP.CD_2012 = NY.GDP.PCAP.CD_2012 - mean(NY.GDP.PCAP.CD_2012),
         SI.POV.GINI_2012 = SI.POV.GINI_2012 - mean(SI.POV.GINI_2012),
         SP.DYN.TFRT.IN_2012 = SP.DYN.TFRT.IN_2012 - mean(SP.DYN.TFRT.IN_2012))

```

We're going to run the model and look at the results. I've included the baseline means in the model, but given the number of observations (61), this is asking a lot of the data. For 64 observations, there's 11 predictors plus the random intercepts and slopes for year. This model is almost certainly overfit (though I think their original model is too).

In the model below, I have also used the natural log of gross GDP, which makes more sense to me (so much as using gross GDP makes sense).

```r

> mod_sp_tc <- lmer(loneliness ~ 1 + Smartphone_tc + 
                     year +
                     SL.UEM.TOTL.ZS_tc +
                     NY.GDP.MKTP.CD_tc +
                     SI.POV.GINI_tc + 
                     SP.DYN.TFRT.IN_tc + 
                     Internet_2012  +
                     SL.UEM.TOTL.ZS_2012 +
                     NY.GDP.MKTP.CD_2012 +
                     SI.POV.GINI_2012 + 
                     SP.DYN.TFRT.IN_2012 + 
                     (1 + year | cnt),
                   data = df)
> summary(mod_sp_tc)

Linear mixed model fit by REML ['lmerMod']
Formula: loneliness ~ 1 + Smartphone_tc + year + SL.UEM.TOTL.ZS_tc + NY.GDP.MKTP.CD_tc +  
    SI.POV.GINI_tc + SP.DYN.TFRT.IN_tc + Smartphone_2012 + SL.UEM.TOTL.ZS_2012 +  
    NY.GDP.MKTP.CD_2012 + SI.POV.GINI_2012 + SP.DYN.TFRT.IN_2012 +      (1 + year | cnt)
   Data: df

REML criterion at convergence: -59.4

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.54401 -0.39900  0.03901  0.40098  1.43279 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr 
 cnt      (Intercept) 0.0135895 0.116574      
          year        0.0000978 0.009889 -0.35
 Residual             0.0015830 0.039787      
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                     Estimate Std. Error t value
(Intercept)          1.794916   0.025806  69.554
Smartphone_tc        0.001882   0.001317   1.429
year                 0.026335   0.006494   4.055
SL.UEM.TOTL.ZS_tc   -0.005489   0.006203  -0.885
NY.GDP.MKTP.CD_tc   -0.249820   0.100478  -2.486
SI.POV.GINI_tc      -0.004329   0.009862  -0.439
SP.DYN.TFRT.IN_tc   -0.087007   0.116167  -0.749
Smartphone_2012      0.003587   0.002286   1.569
SL.UEM.TOTL.ZS_2012 -0.008922   0.004819  -1.851
NY.GDP.MKTP.CD_2012 -0.029471   0.018625  -1.582
SI.POV.GINI_2012     0.010315   0.004443   2.322
SP.DYN.TFRT.IN_2012 -0.079967   0.070667  -1.132

Correlation of Fixed Effects:
                 (Intr) Smrtp_ year   SL.UEM.TOTL.ZS_t NY.GDP.MKTP.CD_t SI.POV.GINI_t SP.DYN.TFRT.IN_t
Smartphn_tc       0.044                                                                               
year             -0.267 -0.781                                                                        
SL.UEM.TOTL.ZS_t -0.004  0.247  0.134                                                                 
NY.GDP.MKTP.CD_t  0.088  0.582 -0.414  0.594                                                          
SI.POV.GINI_t    -0.018 -0.076 -0.046 -0.570           -0.439                                         
SP.DYN.TFRT.IN_t -0.016  0.074  0.056  0.353            0.284           -0.287                        
Smrtph_2012      -0.012  0.336 -0.305  0.033            0.159           -0.135        -0.045          
SL.UEM.TOTL.ZS_2 -0.013 -0.040  0.102  0.153            0.027           -0.075        -0.018          
NY.GDP.MKTP.CD_2  0.041  0.020 -0.065 -0.091            0.048            0.072        -0.024          
SI.POV.GINI_2    -0.015  0.211 -0.193  0.033            0.145            0.010         0.087          
SP.DYN.TFRT.IN_2 -0.076 -0.062  0.054 -0.070           -0.124            0.041         0.065          
                 S_2012 SL.UEM.TOTL.ZS_2 NY.GDP.MKTP.CD_2 SI.POV.GINI_2
Smartphn_tc                                                            
year                                                                   
SL.UEM.TOTL.ZS_t                                                       
NY.GDP.MKTP.CD_t                                                       
SI.POV.GINI_t                                                          
SP.DYN.TFRT.IN_t                                                       
Smrtph_2012                                                            
SL.UEM.TOTL.ZS_2  0.275                                                
NY.GDP.MKTP.CD_2 -0.045  0.042                                         
SI.POV.GINI_2     0.072 -0.268           -0.293                        
SP.DYN.TFRT.IN_2  0.095  0.413            0.015           -0.434           

```

You can see now that within countries, smartphone access is no longer statistically significant , nor is it significant between countries (t-value < 1.96 for both). We can also see that the fixed effects are not correlated with the intercept, as the correlations are below 0.1. The results are substantively similar with group-mean centering. If you're curious about the difference, you can check out the code.

We see a similar pattern with internet access: we get lower t-values when the predictor is split to account for within and between country effects.

```r

> mod_int_tc <- lmer(loneliness ~ 1 + Internet_tc + 
                         year +
                         SL.UEM.TOTL.ZS_tc +
                         NY.GDP.MKTP.CD_tc +
                         SI.POV.GINI_tc + 
                         SP.DYN.TFRT.IN_tc + 
                         Internet_2012  +
                         SL.UEM.TOTL.ZS_2012 +
                         NY.GDP.MKTP.CD_2012 +
                         SI.POV.GINI_2012 + 
                         SP.DYN.TFRT.IN_2012 + 
                         (1 + year | cnt),
                       data = df)
> summary(mod_int_tc)


Linear mixed model fit by REML ['lmerMod']
Formula: loneliness ~ 1 + Internet_tc + year + SL.UEM.TOTL.ZS_tc + NY.GDP.MKTP.CD_tc +  
    SI.POV.GINI_tc + SP.DYN.TFRT.IN_tc + Internet_2012 + SL.UEM.TOTL.ZS_2012 +  
    NY.GDP.MKTP.CD_2012 + SI.POV.GINI_2012 + SP.DYN.TFRT.IN_2012 +      (1 + year | cnt)
   Data: df

REML criterion at convergence: -72.8

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.96459 -0.34791 -0.03333  0.37145  1.68167 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr 
 cnt      (Intercept) 1.124e-02 0.10601       
          year        7.691e-05 0.00877  -0.08
 Residual             1.730e-03 0.04159       
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                     Estimate Std. Error t value
(Intercept)          1.797110   0.024049  74.728
Internet_tc          0.040006   0.035844   1.116
year                 0.025601   0.008544   2.996
SL.UEM.TOTL.ZS_tc   -0.006334   0.006083  -1.041
NY.GDP.MKTP.CD_tc   -0.302126   0.086721  -3.484
SI.POV.GINI_tc      -0.003565   0.010082  -0.354
SP.DYN.TFRT.IN_tc   -0.087549   0.117947  -0.742
Internet_2012        0.090039   0.049641   1.814
SL.UEM.TOTL.ZS_2012 -0.007012   0.004628  -1.515
NY.GDP.MKTP.CD_2012 -0.016003   0.019074  -0.839
SI.POV.GINI_2012     0.006421   0.004665   1.376
SP.DYN.TFRT.IN_2012 -0.053932   0.070147  -0.769

Correlation of Fixed Effects:
                 (Intr) Intrn_ year   SL.UEM.TOTL.ZS_t NY.GDP.MKTP.CD_t SI.POV.GINI_t SP.DYN.TFRT.IN_t
Internet_tc       0.128                                                                               
year             -0.242 -0.883                                                                        
SL.UEM.TOTL.ZS_t -0.013  0.048  0.212                                                                 
NY.GDP.MKTP.CD_t  0.107  0.221 -0.164  0.566                                                          
SI.POV.GINI_t    -0.035 -0.056 -0.025 -0.576           -0.498                                         
SP.DYN.TFRT.IN_t -0.007  0.017  0.070  0.364            0.306           -0.307                        
Intrnt_2012       0.059  0.300 -0.304 -0.007            0.086           -0.104        -0.001          
SL.UEM.TOTL.ZS_2 -0.009 -0.055  0.085  0.114            0.039           -0.059         0.007          
NY.GDP.MKTP.CD_2  0.031 -0.033 -0.003 -0.066            0.032            0.006        -0.016          
SI.POV.GINI_2    -0.012  0.090 -0.088 -0.009            0.029            0.052         0.045          
SP.DYN.TFRT.IN_2 -0.059  0.020 -0.022 -0.041           -0.071            0.012         0.037          
                 I_2012 SL.UEM.TOTL.ZS_2 NY.GDP.MKTP.CD_2 SI.POV.GINI_2
Internet_tc                                                            
year                                                                   
SL.UEM.TOTL.ZS_t                                                       
NY.GDP.MKTP.CD_t                                                       
SI.POV.GINI_t                                                          
SP.DYN.TFRT.IN_t                                                       
Intrnt_2012                                                            
SL.UEM.TOTL.ZS_2  0.259                                                
NY.GDP.MKTP.CD_2  0.294  0.173                                         
SI.POV.GINI_2    -0.346 -0.371           -0.407                        
SP.DYN.TFRT.IN_2  0.244  0.453            0.120           -0.488      


```

# But wait, what if we use per capita GDP?
Now it starts to get more interesting. I mentioned earlier that I think they use gross GDP as one of their predictors. Gross GDP is an odd choice because it does not properly adjust for population size. Using gross GDP, the country with a greater population would have higher GDP even if the countries had an equal GDP per capita. That is not the measure what we want to use.

Think of it this way. Imagine we had two schools where, on average, students had the same scores. But to figure out which school has "smarter" students, we simply added up the scores of the students and used that as our total. Now imagine that the larger school has more students but a lower aerage test score. The greater number of students means that the lower-scoring school can have a higher gross score, even if the average student is less smart than the smaller school.

Put simply, but using gross GDP, Twenge et al. are not using a predictor that measures what we want to adjust for, which is how well off the country is _per person_.


```r

> mod_sp_tc2 <- lmer(loneliness ~ 1 + Smartphone_tc + 
                         year +
                         SL.UEM.TOTL.ZS_tc +
                         NY.GDP.PCAP.CD_tc +
                         SI.POV.GINI_tc + 
                         SP.DYN.TFRT.IN_tc + 
                         Smartphone_2012  +
                         SL.UEM.TOTL.ZS_2012 +
                         NY.GDP.PCAP.CD_2012 +
                         SI.POV.GINI_2012 + 
                         SP.DYN.TFRT.IN_2012 + 
                         (1 + year | cnt),
                     data = df)
> summary(mod_sp_tc2)

Linear mixed model fit by REML ['lmerMod']
Formula: loneliness ~ 1 + Smartphone_tc + year + SL.UEM.TOTL.ZS_tc + NY.GDP.PCAP.CD_tc +  
    SI.POV.GINI_tc + SP.DYN.TFRT.IN_tc + Smartphone_2012 + SL.UEM.TOTL.ZS_2012 +  
    NY.GDP.PCAP.CD_2012 + SI.POV.GINI_2012 + SP.DYN.TFRT.IN_2012 +      (1 + year | cnt)
   Data: df

REML criterion at convergence: -71.9

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.78007 -0.43656 -0.02092  0.39519  1.40685 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr 
 cnt      (Intercept) 6.641e-03 0.08150       
          year        8.208e-05 0.00906  -0.11
 Residual             1.593e-03 0.03992       
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                     Estimate Std. Error t value
(Intercept)          1.794731   0.019156  93.692
Smartphone_tc        0.001776   0.001271   1.398
year                 0.025929   0.006038   4.294
SL.UEM.TOTL.ZS_tc   -0.006048   0.006331  -0.955
NY.GDP.PCAP.CD_tc   -0.270802   0.098602  -2.746
SI.POV.GINI_tc      -0.002465   0.009726  -0.253
SP.DYN.TFRT.IN_tc   -0.066107   0.113767  -0.581
Smartphone_2012      0.005225   0.001838   2.844
SL.UEM.TOTL.ZS_2012 -0.002432   0.003800  -0.640
NY.GDP.PCAP.CD_2012 -0.140300   0.033194  -4.227
SI.POV.GINI_2012    -0.005088   0.004498  -1.131
SP.DYN.TFRT.IN_2012  0.026188   0.058734   0.446

Correlation of Fixed Effects:
                 (Intr) Smrtp_ year   SL.UEM.TOTL.ZS_t NY.GDP.PCAP.CD_t SI.POV.GINI_t SP.DYN.TFRT.IN_t
Smartphn_tc       0.045                                                                               
year             -0.243 -0.751                                                                        
SL.UEM.TOTL.ZS_t -0.009  0.266  0.174                                                                 
NY.GDP.PCAP.CD_t  0.095  0.552 -0.310  0.638                                                          
SI.POV.GINI_t    -0.023 -0.047 -0.108 -0.570           -0.435                                         
SP.DYN.TFRT.IN_t -0.019  0.050  0.103  0.345            0.252           -0.280                        
Smrtph_2012       0.019  0.322 -0.315  0.014            0.114           -0.062        -0.038          
SL.UEM.TOTL.ZS_2 -0.022 -0.040  0.090  0.111           -0.013           -0.057        -0.004          
NY.GDP.PCAP.CD_2  0.003 -0.045  0.029 -0.035            0.027           -0.016        -0.028          
SI.POV.GINI_2     0.014  0.128 -0.142 -0.027            0.117            0.023         0.019          
SP.DYN.TFRT.IN_2 -0.067 -0.013  0.008 -0.036           -0.104            0.032         0.055          
                 S_2012 SL.UEM.TOTL.ZS_2 NY.GDP.PCAP.CD_2 SI.POV.GINI_2
Smartphn_tc                                                            
year                                                                   
SL.UEM.TOTL.ZS_t                                                       
NY.GDP.PCAP.CD_t                                                       
SI.POV.GINI_t                                                          
SP.DYN.TFRT.IN_t                                                       
Smrtph_2012                                                            
SL.UEM.TOTL.ZS_2  0.334                                                
NY.GDP.PCAP.CD_2 -0.306 -0.278                                         
SI.POV.GINI_2    -0.153 -0.380            0.687                        
SP.DYN.TFRT.IN_2  0.218  0.487           -0.403           -0.568   

```

In this model, we can see that within countries, smartphone access is not a stastically significant predictor of loneliness. But differences between countries' rates of smartphone access in 2012 is statistically significant predictor. So, had they used this model, they might have been able to use this result to strengthen their case that smartphone access is associated with loneliness, but only between countries, not within countries.

But what if we look at both internet use __and__ smartphone access? 

```r

> mod_sp_tc3 <- lmer(loneliness ~ 1 + Smartphone_tc + 
                     Internet_tc +
                     year +
                     SL.UEM.TOTL.ZS_tc +
                     NY.GDP.PCAP.CD_tc +
                     SI.POV.GINI_tc + 
                     SP.DYN.TFRT.IN_tc + 
                     Smartphone_2012  +
                     Internet_2012 +
                     SL.UEM.TOTL.ZS_2012 +
                     NY.GDP.PCAP.CD_2012 +
                     SI.POV.GINI_2012 + 
                     SP.DYN.TFRT.IN_2012 + 
                     (1 + year | cnt),
                   data = df)
> summary(mod_sp_tc3)

Linear mixed model fit by REML ['lmerMod']
Formula: loneliness ~ 1 + Smartphone_tc + Internet_tc + year + SL.UEM.TOTL.ZS_tc +  
    NY.GDP.PCAP.CD_tc + SI.POV.GINI_tc + SP.DYN.TFRT.IN_tc +  
    Smartphone_2012 + Internet_2012 + SL.UEM.TOTL.ZS_2012 + NY.GDP.PCAP.CD_2012 +  
    SI.POV.GINI_2012 + SP.DYN.TFRT.IN_2012 + (1 + year | cnt)
   Data: df

REML criterion at convergence: -63.9

Scaled residuals: 
     Min       1Q   Median       3Q      Max 
-1.72288 -0.40690 -0.07131  0.37473  1.41784 

Random effects:
 Groups   Name        Variance  Std.Dev. Corr 
 cnt      (Intercept) 6.967e-03 0.083470      
          year        9.413e-05 0.009702 -0.10
 Residual             1.532e-03 0.039136      
Number of obs: 61, groups:  cnt, 24

Fixed effects:
                     Estimate Std. Error t value
(Intercept)          1.797047   0.019667  91.373
Smartphone_tc        0.001593   0.001344   1.185
Internet_tc          0.025369   0.036619   0.693
year                 0.021199   0.008644   2.453
SL.UEM.TOTL.ZS_tc   -0.006155   0.006376  -0.965
NY.GDP.PCAP.CD_tc   -0.265332   0.099032  -2.679
SI.POV.GINI_tc      -0.003345   0.009856  -0.339
SP.DYN.TFRT.IN_tc   -0.067687   0.114965  -0.589
Smartphone_2012      0.004146   0.002287   1.813
Internet_2012        0.046150   0.047559   0.970
SL.UEM.TOTL.ZS_2012 -0.002412   0.003883  -0.621
NY.GDP.PCAP.CD_2012 -0.131473   0.036442  -3.608
SI.POV.GINI_2012    -0.005148   0.004596  -1.120
SP.DYN.TFRT.IN_2012  0.031158   0.060145   0.518

Correlation matrix not shown by default, as p = 14 > 12.
Use print(x, correlation=TRUE)  or
    vcov(x)        if you need it

```

Our model now has nearly as many predictors and random effects as there are observations. But we can see that both smartphone access and internet usage are no longer statistically significant. 


# Final thoughts
Twenge et al.'s mistake is common. The main multilevel modelling textbooks barely cover it (e.g., Snjiders & Bosker, 2011; ). They mention it briefly, and then rarely make use of it the rest of the book. 

To be clear, I don't think that Twenge et al.'s model (or mine in this post) is appropriate for what they are trying to measure. There's too few observations, too many preditors, and variables that don't make sense (like gross GDP). By aggregating their data, they have a study that is underpowered and noisy.

# References
Below are a few references I've found helpful in using mixed effects models to model longitudinal data. In particular, I recommend Lesa Hoffman's _Longitudinal analysis: Modeling within-person fluctuation and change_. To understand group-mean centering, I also recommend the articles by Bell and coauthors. 

## Centering
Bell, A., Fairbrother, M., & Jones, K. (2019). Fixed and random effects models: making an informed choice. _Quality & Quantity_, _53_(2), 1051-1074.

Bell, A., & Jones, K. (2015). Explaining fixed effects: Random effects modeling of time-series cross-sectional and panel data. _Political Science Research and Methods_, _3_(1), 133-153.

Bell, A., Jones, K., & Fairbrother, M. (2018). Understanding and misunderstanding group mean centering: a commentary on Kelley et al.’s dangerous practice. _Quality & quantity_, _52_(5), 2031-2036.

Enders, C. K. & Tofighi, D. (2007). Centering Predictor Variables in Cross-Sectional Multilevel Models: A New Look at an Old Issue. _Psychological Methods_, _12_(2). 121-138

Hamaker, E. L., & Grasman, R. P. (2015). To center or not to center? Investigating inertia with a multilevel autoregressive model. _Frontiers in psychology_, _5_, 1492.

Hamaker, E. L., & Muthén, B. (2020). The fixed versus random effects debate and how it relates to centering in multilevel modeling. _Psychological methods_, _25_(3), 365.

Hoffman, L. (2015). _Longitudinal analysis: Modeling within-person fluctuation and change_. Routledge.

Raudenbush, S. W., & Bryk, A. S. (2002). _Hierarchical linear models: Applications and data analysis methods_. sage.

Snijders, T. A., & Bosker, R. J. (2011). _Multilevel analysis: An introduction to basic and advanced multilevel modeling_. sage.


## Twenge et al.
Twenge, J. M., Haidt, J., Blake, A. B., McAllister, C., Lemon, H., & Le Roy, A. (2021). Worldwide increases in adolescent loneliness. _Journal of Adolescence_.
