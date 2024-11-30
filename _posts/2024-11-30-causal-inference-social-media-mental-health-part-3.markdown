---
layout: post
title:  "Causal inference, social media, and mental health, part 3"
date:   2024-11-30 10:00:00 -0500
categories: blog
usemathjax: true
---
* TOC
{:toc}

I spent a while trying to figure out how best to arrange this post. Unlike the last couple posts, this one is going to be a bit more didactic. But I think it's worth it, because it illustrates how hard it is to estimate the direct effect of social media on mental health, **even when you have longitudinal data**.

Part of my inspiration comes from a recent article by [Rudolph and Kim (2024)](https://www.sciencedirect.com/science/article/pii/S235282732400123X), where they use an instrumental variable approach to try identify the effect of smartphone use on mental health. I don't think they have a valid instrument, but I think an instrumental variable approach is probably the only way we'll get reasonable estimates of the direct effect on the mental health of an individual when they reduce their social media use. This post is an attempt to explain why.

Compared to my earlier posts, I want this post to stand alone. I've therefore devoted some time time to briefly explain the concepts in the DAG, define a few terms, and so on. As always, feedback is welcome, especially if you think I am wrong.

# DAGs
I'm going to give a **very** brief overview of DAGs. That is, I will hopefully provide just enough detail to help you get acquainted with them if you are not already. This means that I am leaving a lot of important detail out. So don't consider this an introduction to DAGs. 

If you want to learn more about DAGs or think what I have written below is unclear, I suggest you consult some of these resources if you are interested. In terms of free open resources, I strongly recommend [Tennant et al (2020)](https://academic.oup.com/ije/article/50/2/620/6012812), [Rohrer 2018](https://journals.sagepub.com/doi/full/10.1177/2515245917745629), chapters 6 to 9 of [Huntington-Klein (2022)](https://theeffectbook.net/index.html), chapter 3 of [Cunningham (2021)](https://mixtape.scunning.com/03-directed_acyclical_graphs), and chapters 6 to 10 of [Robins and Hernan (2024)](https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/). Hernan also has a great [video series](https://www.edx.org/learn/data-analysis/harvard-university-causal-diagrams-draw-your-assumptions-before-your-conclusions) on DAGs (don't pay for it. You can currently watch it for free). [Bulbulia (2024a)](https://www.cambridge.org/core/journals/evolutionary-human-sciences/article/methods-in-causal-inference-part-1-causal-diagrams-and-confounding/E734F72109F1BE99836E268DF3AA0359) is a nice new addition.

Generally, everything I discuss below is inspired by or comes from the sources above, so consult them if you have questions. I have some more resources below to consult if you want more detail on DAGs or to see DAGs in application. But no [single world intervention graphs](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=89bd91b714f35759968555a87da06ce773a77f2f) (SWIGs) today.

## What are DAGs?
A DAG is Directed Acyclic Graph. They go by other names, including causal graphs, causal diagrams, and structural causal models. The basic idea is that we can draw arrows from one variable to another to show which direction we think causation flows. Using these causal paths, we can figure out which variables to include in our regression to make sure that all backdoor paths are closed OR no new paths are opened. Basically, it helps us figure out which variables to include or exclude from our regression.

One important things we want to try do is close **backdoor paths**. Backdoor paths are ways by which our variable of interest can be associated with the outcome but in a non-causal way.

### Confounding, colliders, and mediators
There are three primary relationships we are concerned about:  
* **confounding**: Where one variable causes two others. We want to include confounders in our regression.  
* **colliders**: When a variable is caused by two others. We generally want to exclude them from our regression, because they can open backdoor paths.  
* **mediators** when one variable is on the path from one variable to another. We generally want to exclue mediators from our regressions (some exceptions apply, especially in Structural Equation Modelling).  

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/confounding-collider-mediator.png  "Three simple Dags showing confounding, colliders, and mediators.")

To keep things simple, for our purposes we want to avoid conditioning on a collider or a mediator and we want to condition on a cofounder. Why?

Look at the image above. In the top DAG, we have an arrow going from $$U$$ to $$X$$ and from $$U$$ to $$Y$$. There is no arrow from $$X$$ to $$Y$$, meaning that $$X$$ does not cause $$Y$$. This means that $$X$$ and $$Y$$ will appear associated unless we control for $$U$$. Sometimes it's fine--we can see $$U$$ and control for it. But sometimes it isn't, especially when $$U$$ is unobserved. And $$U$$ is often unobserved. The key message here is that we want to control for confounding. If we don't control for it, we have a backdoor path from $$X \rightarrow Y$$.

The middle DAG shows a collider. Here, $$X$$ and $$Y$$ each have an arrow into $$C$$. There is no arrow from $$X$$ to $$Y$$. In this scenario, we do not want to control for $$C$$. Why? Because both $$X$$ and $$Y$$ cause the collider, so it will make $$X$$ and $$Y$$ appear associated even though they are not. An example helps. The standard example is beauty and talent in Hollywood actors and actresses. In the general population, acting talent and beauty are unrelated. That is, there is no arrow from $$X$$ (talent) to $$Y$$ (beauty) or vice versa. But to succeed in Hollywood, an actor or actress needs to be talented, beautiful or both. Talented actors and actresses do not need to be beautiful, and beautiful actors and actresses do not need to be talented. If we look only at Hollywood, we would think that individuals are either talented or beautiful, but not both. The key message about colliders is that we generally **do not** want to control for them. Sometimes we need to, especially if something is both a confounder and a collider. If all backdoor paths involving the collider can be closed otherwise, then we can condition on our collider.

The bottom DAG shows a mediator. We have an arrow going from $$X$$ to $$M$$, and another from $$M$$ to $$Y$$. There is no arrow that goes directly from $$X$$ to $$Y$$. Here, our causal relationship is mediated by $$M$$. If we control for $$M$$, we interrupt the path from $$X$$ to $$Y$$, and it will look like $$X$$ does not cause $$Y$$. Sometime we do not want to control for mediators, but sometimes we do. It's complicated.

### DAGs are acyclic
One key element of DAGs is that they are **acyclic**--that is, causation can only flow in one direction. $$X$$ can influence $$Y$$, but $$Y$$ cannot simultaneously influence $$X$$. This matters for us, because when we think about social media and mental health, there are feedback loops. My mental health influences how much social media I use, which influences my mental health. To account for this, we need to draw DAGs that account for the time element in our relationship. Which came first, the chicken or the egg, doesn't matter for us here. What matters is that we can use DAGs to illustrate the relationship now that social media is in place. The relationship won't be exact, but that's fine. DAGs merely help us illustrate our asumed relationship and make those assumptions clear to others. Whether we have accurately captured the relationship and whether are assumptions are reasonable is another thing entirely.

## Defining a few terms and variables
Before we continue, I'm going to define a few terms that I will use below.  
* **exposure**: this is the thing whose causal effect we wish to estimate. In our case, social media is our exposure.     
* **outcome**: this is the variable that we are monitoring during our study. Outcomes are affected by exposures.  
* **node**: a variable. It can be observed or unobserved.  
* **edges**: The arrows that flow from one variable to another.  

Next, we'll define our variables. You'll see these variables used in our DAG.
* $$SM1$$ and $$SM2$$ represent social media use at time 1 and time 2 (hereafter t1 and t2). $$SM2$$ is our exposure. To be specific (much more so than most studies in this area), use means how much time I spend on social media. For simplicity, let's assume that at the start of our study there is only 1 social media site. 
* $$MH1$$ and $$MH2$$ are mental health at t1 and t2. $$MH2$$ is our outcome variable.  
* $$X1$$ and $$X2$$ represent observed covariates for individuals in our study. These could be things like household income, gender, age, and so on.  
* $$Ui$$ is individual-level time-invariant unobserved variable. This is a variable that may affect an individual's mental health, observed covariates, and social media use but for which we don't have an observation. An example would be individual $$i$$'s personality, for instance.   
* $$U1$$ and $$U2$$ are time-invariant unobserved variables that affect the individual. These variables affect an individuals' mental health, social media use, and covariates ($$X1$$ and $$X2$$). Unlike $$Ui$$, however, they vary over time. An example would be a teen's parents getting a new job that requires them to be out of the house more. This would affect income, and maybe spending less time with the teen leads to poorer mental health for the teen, and gives them more time to spend on social media.  
* $$W1$$ and $$W2$$ are unobserved variables at t1 and t2 and are directly related only to social media use and mental health (but not observerd covariates). $$W1$$ and $$W2$$ are how social media can affect an individudal either through their social media use or even if they are not using social media. An example of this type of unobserved variable could include a new social media platform launching that causes someone to switch platforms, changes to an existing platform's algorithm that affect use and mental health, or changes in how your friends use social media, which in turn affects your mental health and how you use social media.   

# Building our DAG
To build up our DAG, we're going to start really simple and gradually make it more representative of the real world we'd encounter in an observational or experimental study. The point here is that DAG serves as a useful abstraction of the real world, not that it mimic the real world exactly.

To build up our DAG, we're going to assume that there are two timepoints. There could be more in the real world, but for our purposes more than two timepoints is unnecessary. With two timepoints, we can see everything we need to see about what we need to control for.

## First DAG and confounding
Let's start with a simple DAG to illustrate a time series. For what follows, I'll make use of the variables I defined up above.

To start with, we have social media ($$SM$$) at t1 and t2--like, for instance, in two waves of a survey, or when entering and completing a social media reduction experiment. $$SM$$ affects our mental health, $$MH$$. There are only arrows from $$SM$$ to $$MH$$ at each time point. There are no other paths to be concerned about here: no confounding, no colliders, no mediators.

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/simple_dag.png  "A simple dag showing an arrow from SM2 to MH2. There are no other relationships to worry about")

But of course this DAG is a poor representation of the real world. In the real world, we would expect social media use in t1 to influence use in t2. There's lots of reasons why. For instance, if I use social media more today, maybe I need to use it more tomorrow to respond to all the messages I received. Or maybe I use it lots today so I use it less tomorrow because I'm bored of it and need a break. Same for mental health. Our mental health today probably influences our mental health tomorrow, and it probably influences our social media use tomorrow as well. So let's add those arrows to our DAG.

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/simple_dag_confounding.png  "This DAG shows that social media use at each time affects our mental health at that time, plus our social media use in the next period. Our mental health in t1 influence social media use and our mental health in time 2.")

Remember our paths up above. If we look at our simple DAG we see that there is confounding: mental health at t1 ($$MH1$$) affects our mental health at t2 **AND** our social media use at t2. So we need to control for mental health at t1 if we want to estimate the causal effect of our exposure, social media use, at t2.

Now we can start to see why DAGs are useful. Without thinking through our assumptions, we wouldn't have known to control for mental health at t1. And as a result, we would fail to recover the causal effect of social media at t2 on our mental health at t2. 

## A more complicted DAG with covariates
Our DAG, though simple, is still missing a few things. There are things we measure, like age, that likely affect social media use. We need to make sure we include those. Things like age likely affect both social media use and mental health, so we'll draw arrows from our covariates to social media and mental health. What matters here for our purposes is that these are **measured** covariates--that is, we know their values. Common measured covariates include things like age, sex or gender, household income, and so on. For many--if not all--of these covariates, it is unlikely that social media causes them, so we **won't** draw an arrow from social media to our covariates.

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/more_complicated_dag.png "This DAG shows covariates affecting both social media use and mental health")

Now we're starting to get to something more realistic. Our DAG features our exposure (social media use at t2), our outcome (mental health at t2), and covariates that affect our mental health and social media use. Even though it is more complicated that the simpler one we presented above, we can still recover our causal effect if we control for mental health at t1 and our covariates at t2. That is, we need to control for $$MH1$$ and $$X2$$. Careful readers will notice that $$MH1$$ is both a collider and a confounder. Yet we want to control for it here. Although there are a bunch of arrows, including these two variables allow us to close all the backdoor paths.

But of course our DAG isn't entirely reasonable yet. We are missing a couple of other really important variables that we need to include.

## A reasonable DAG for the effect of social media on mental health
So what are missing? Our unobserved variables--the things that affect social media use and mental health but that we do not observe. 

The first sort of unobserved variable is a time-invariant variable. This is something that is constant across time (hence invariant). As you can see from the DAG below, it affects everything. While it looks scary here, we can adjust for it in a model by including something like fixed effects or a random intercept. (But it is reasonable to ask what exactly is invariant and what we are controlling for when use things like fixed effects, especially at a crucial time like the teenage years. See, eg, [Millimet and Bellemare (2023)](https://docs.iza.org/dp16202.pdf) who discuss some potential solutions in more detail). You can see this time invariant unobserved confounder in the DAG below, represented by Ui.  

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/Ui_dag.png "This DAG shows covariates affecting both social media use and mental health, and it shows time-invariant unobserved confounding.")

The second sort is much harder to control for. These are time-varying unobserved variables. You can see them below represented by $$U1$$, $$U2$$, $$W1$$ and $$W2$$. I've also coloured the nodes and edges grey to distinguish them from our observed variables (I have left $$Ui$$ black because we are controlling for it).

It's these variables that are going to cause the most trouble. So much trouble, in fact, that it becomes impossible (at least so far as I know) to recover an unbiased causal effect. They key reason is that they are unobserved, so cannot completely control for them. 

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/u_w_unobserved_dag.png "This DAG shows covariates affecting both social media use and mental health, and it shows time-invariant unobserved confounding. It adds time invariant confounding to it. This is a problem.")

These variables--$$U1$$, $$U2$$, $$W1$$ and $$W2$$--lead to **time-varying confounding**. Time-varying confounding occurs when we have a variable, observed or unobserved, that affects both our treatment (social media use) and our mental health, and that variable changes over time. Take how your friends use social media. If they use social media more, you use it more. Because you use it more, your social media use also affects your mental health. And because you friends are on social media so much, they can't hang out with you. This also affects your mental health, but through a path other than **your** social media use. Unless you can control for that, you have no way of attributing the variation in your mental health to your social media use, to your friends, or some combination thereof. It all gets jumbled together. 

# What does it mean?
Herein is where the difficulty arises. Our time-varying confounders are unobserved, so we can't control for them. This means that we are going to have an extremely difficult time recovering unbiased causal effects using observational data. Recovering an unbiased causal effect with these time-varying confounders can only be done in a few ways. I want to highlight two of them here.

## Observational longitudinal studies
$$U1$$, $$U2$$, $$W1$$ and $$W2$$ imply a violation of parallel trends and lack of sequential exchangability, which means that many of our usual approaches may not work well. How well they could work depends on the severity of the violations.

Our first hope is that we can find sufficient variables to close the back door paths. One way to do this is to simply to collect even more variables in our longitudinal surveys. The problem here is that we can never collect enough, and that every new variable we use has the potential to be a [bad control](https://journals.sagepub.com/doi/full/10.1177/00491241221099552). Given the state of lot of research in this area, I suspect most variables will end up being bad controls. 

A second potential way to address this is to restrict our longitudinal analysis to users who exclusively use one specific social media platform (say, only TikTok), or who meet other prescribed criteria (think about how specific my assumption was above that there was only 1 platform). While this can work, the risk is we shrink our sample size down to an unworkable level. We also have the risk that our causal effects may not be transportable or generalizable--that is, they may not apply to other social media sites, or to other users of the same site, and so on. If we add more sites, we are adding more unobserved variables, and more ways to introduce time-varying confounding.

A third potential way is to use a model that can handle unobserved time-varying confounding. There is some work in this area, but I don't know of any methods can solve the problem. If you do, please share.

## Instrumental variables and social media reduction experiments
I think our only real hope to estimate the direct effect of social media use is to use an instrumental variable-type approach. This is what happens in social media reduction studies. We can illustrate this with a DAG.

When someone agrees to participate in a social media reduction experiment, they are randomly assigned to one of two groups: a treatment group, under which they reduce their use of social media, or a control group, under which they continue to use social media as they normally would. What matters here is that the researchers are **not** experimentally manipulating participants social media use. Instead, the researchers are encouraging the participants to reduce their use, and the participants comply. This is a classic set up for an instrumental variable.

In the DAG below, you can see our instrument, $$Z$$, with an arrow heading into $$SM2$$. There are no other arrows from $$Z$$ to $$MH2$$, and no arrows heading into $$Z$$. And we know there are no arrows heading into $$Z$$ because $$Z$$ is randomly assigned by the researchers.

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/u_w_z_unobserved_iv_dag.png "This DAG shows an instrumental variable approach to estimating the direct effect of social media use on mental health")

### Caution is always warranted
In social media reduction experiments, however, we need to be careful with our instrumental variable. The reason here is subtle: our instrumental variable may influence mental health directly in addition to doing so through social media use. How? If I am participating in one of these trials, the treatment isn't blinded--that is, I know I am reducing my social media use because the researchers told me to do so. That knowledge may influence my mental health even if my social media use did not decrease.

We can illustrate this violation with our DAG. We can draw a line from $$Z$$ to our mental health at t2 ($$MH2$$) to show this violation. I've coloured the edge red to make it clear.

![alt text](/assets/2024-11-30-causal-inference-social-media-mental-health-part-3/u_w_z_unobserved_iv_violation_dag.png "This DAG shows an instrumental variable approach to estimating the direct effect of social media use on mental health")

How bad is this violation? I am not sure, though I suspect the violation is large enough that we should be cautious interpreting the results of these trials as reflecting reduced social media use.

# Putting it all together
Putting it all together, I'm brought to a somewhat gloomy conclusion: estimating the total causal effect of social media use is probably impossible given current techniques. Yet I am less gloomy than when I started this post. Drawing out the problem has helped crystallize where the issues lie. And that is part of the step towards solving the problem. Maybe a fancy Bayesian model could help. Baby steps.

Even if the problem is intractable right now, that doesn't mean we should give up--after all, there is something to be said for the [shoe leather approach](https://www.jstor.org/stable/270939?casa_token=m04CuR0Ll8MAAAAA%3AaDMfVwnVZIacppHuxg-93IwWcUo20B0CTf8V-ujsqnQAnv0CAFUcLtFSXgqWufHAxWWCLCWm8CWOXtKMSGdjkFakPtfeeUbf30J3jpp6jD01GXJi6Uus). But it does mean I think we need to be careful with our language and tentative in our conclusions until better techniques come along. There is a lot of work trying to address problems like time-varying confounding, interference, and other issues that arise in social networks. Let's see where it goes.

# Thank you, references, and other reading
I owe a big thank you to Joe Bak-Coleman, Matthew Kay, and Jorge Loria for reading an early draft of this post. The usual disclaimers apply. All the good stuff belongs to others, the bad stuff is me. Typos are due to the Typo Gnome.

Here is a list of references and other reading that has influenced my views on this topic. 

## References and other reading
Arnold, Kellyn F., Wendy J. Harrison, Alison J. Heppenstall, and Mark S. Gilthorpe. "DAG-informed regression modelling, agent-based modelling and microsimulation modelling: a critical comparison of methods for causal inference." _International journal of epidemiology_ 48, no. 1 (2019): 243-253. <https://academic.oup.com/ije/article/48/1/243/5231935>

Bailey, Drew H., Alexander J. Jung, Adriene M. Beltz, Markus I. Eronen,
Christian Gische, Ellen L. Hamaker, Konrad P. Kording et al. “Causal
inference on human behaviour.” _Nature Human Behaviour_ 8, no. 8 (2024):
1448-1459. <https://doi.org/10.1038/s41562-024-01939-z>.

Bulbulia, Joseph A. "Methods in causal inference part 1: Causal diagrams and confounding." _Evolutionary Human Sciences_ (2024a): 1-39. <https://doi.org/10.1017/ehs.2024.35>

Bulbulia, Joseph A. "Methods in causal inference part 2: Interaction, mediation, and time-varying treatments." _Evolutionary Human Sciences_ (2024b): 1-33. <https://doi.org/10.1017/ehs.2024.32>

Bellemare, Marc F., Jeffrey R. Bloem, and Noah Wexler. “The Paper of
How: Estimating Treatment Effects Using the Front‐Door Criterion.”
_Oxford Bulletin of Economics and Statistics_ 86, no. 4 (2024): 951-993.
<https://doi.org/10.1111/obes.12598>

Caetano, Carolina, Brantly Callaway, Stroud Payne, and Hugo Sant’Anna Rodrigues. "Difference in differences with time-varying covariates." _arXiv preprint arXiv:2202.02903_ (2022). <https://arxiv.org/abs/2202.02903>

Cinelli, Carlos, Andrew Forney, and Judea Pearl. "A crash course in good and bad controls." _Sociological Methods & Research_ 53, no. 3 (2024): 1071-1104. <https://journals.sagepub.com/doi/full/10.1177/00491241221099552>

Clare, Philip J., Timothy A. Dobbins, and Richard P. Mattick. "Causal models adjusting for time-varying confounding—a systematic review of the literature." _International journal of epidemiology_ 48, no. 1 (2019): 254-265. <https://academic.oup.com/ije/article/48/1/254/5144425>

Cunningham, Scott. _Causal inference: The mixtape_. Yale university press, 2021. <https://mixtape.scunning.com/>

Ding, Peng. _A first course in causal inference_. CRC Press, 2024.

Ferguson, Christopher J. “Do social media experiments prove a link with
mental health: A methodological and meta-analytic review.” _Psychology
of Popular Media_ (2024). <https://doi.org/10.1037/ppm0000541>.

Freedman, David A. "Statistical models and shoe leather." _Sociological methodology_ (1991): 291-313.

Hamaker, Ellen L. "The within-between dispute in cross-lagged panel research and how to move forward." _Psychological Methods_ (2023). <https://psycnet.apa.org/fulltext/2024-20850-001.html>

Hernán, Miguel A., and James M. Robins. _Causal inference: What if?_. 2024. <https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/>

Huntington-Klein, Nick. _The effect: An introduction to research design
and causality_. Chapman and Hall/CRC, 2021.
<https://www.taylorfrancis.com/books/mono/10.1201/9781003226055/effect-nick-huntington-klein>

Imai, Kosuke, and In Song Kim. "When should we use unit fixed effects regression models for causal inference with longitudinal data?." _American Journal of Political Science_ 63, no. 2 (2019): 467-490. <https://onlinelibrary.wiley.com/doi/abs/10.1111/ajps.12417> 

Loh, Wen Wei, and Dongning Ren. "A tutorial on causal inference in longitudinal data with time-varying confounding using g-estimation." _Advances in Methods and Practices in Psychological Science_ 6, no. 3 (2023): 25152459231174029. <https://journals.sagepub.com/doi/full/10.1177/25152459231174029>

Lucas, Richard E. "Why the cross-lagged panel model is almost never the right choice." _Advances in Methods and Practices in Psychological Science_ 6, no. 1 (2023): 25152459231158378. <https://journals.sagepub.com/doi/full/10.1177/25152459231158378>

Lundberg, Ian, Rebecca Johnson, and Brandon M. Stewart. “What is your
estimand? Defining the target quantity connects statistical evidence to
theory.” _American Sociological Review_ 86, no. 3 (2021): 532-565.
<https://doi.org/10.1177/00031224211004187>.

Mansournia, Mohammad Ali, Mahyar Etminan, Goodarz Danaei, Jay S. Kaufman, and Gary Collins. "Handling time varying confounding in observational research." _bmj_ 359 (2017). <https://www.bmj.com/content/359/bmj.j4587>

Matthay, Ellicott C., and M. Maria Glymour. "A graphical catalog of threats to validity: Linking social science with epidemiology." _Epidemiology_ 31, no. 3 (2020): 376-384. <https://journals.lww.com/epidem/fulltext/2020/05000/A_Graphical_Catalog_of_Threats_to_Validity_.11.aspx>

Millimet, Daniel L., and Marc Bellemare. _Fixed effects and causal inference_. No. 16202. IZA Discussion Papers, 2023. <https://docs.iza.org/dp16202.pdf>

Morgan, Stephen, and Christopher Winship. _Counterfactuals and causal
inference_. Cambridge University Press, 2015.

Murayama, Kou, and Thomas Gfrörer. "Thinking clearly about time-invariant confounders in cross-lagged panel models: A guide for choosing a statistical model from a causal inference perspective." _Psychological Methods_ (2024). <https://psycnet.apa.org/fulltext/2025-25768-001.html>

Myint, Leslie. "Controlling time-varying confounding in difference-in-differences studies using the time-varying treatments framework." _Health Services and Outcomes Research Methodology_ 24, no. 1 (2024): 95-111. <https://link.springer.com/article/10.1007/s10742-023-00305-2>

Pearl, Judea. _Causal inference in statistics: a primer_. John Wiley &
Sons, 2016.

Richardson, Thomas S., and James M. Robins. "Single world intervention graphs (SWIGs): A unification of the counterfactual and graphical approaches to causality." _Center for the Statistics and the Social Sciences, University of Washington Series_. Working Paper 128, no. 30 (2013): 2013.

Robitzsch, Alexander, and Oliver Lüdtke. "A note on the occurrence of the illusory between-person component in the random intercept cross-lagged panel model." Structural Equation Modeling: A Multidisciplinary Journal (2024): 1-10. <https://www.tandfonline.com/doi/full/10.1080/10705511.2024.2379495>

Rohrer, Julia M. "Thinking clearly about correlations and causation: Graphical causal models for observational data." _Advances in methods and practices in psychological science_ 1, no. 1 (2018): 27-42. <https://journals.sagepub.com/doi/full/10.1177/2515245917745629>

Rohrer, Julia M., and Kou Murayama. "These are not the effects you are looking for: causality and the within-/between-persons distinction in longitudinal data analysis." _Advances in methods and practices in psychological science_ 6, no. 1 (2023): 25152459221140842. <https://journals.sagepub.com/doi/full/10.1177/25152459221140842>

Rudolf, Robert, and Najung Kim. "Smartphone use, gender, and adolescent mental health: Longitudinal evidence from South Korea." _SSM-Population Health_ (2024): 101722. <https://www.sciencedirect.com/science/article/pii/S235282732400123X>

Runge, Jakob, Andreas Gerhardus, Gherardo Varando, Veronika Eyring, and Gustau Camps-Valls. "Causal inference for time series." _Nature Reviews Earth & Environment_ 4, no. 7 (2023): 487-505. <https://www.nature.com/articles/s43017-023-00431-y>

Tennant, Peter WG, Eleanor J. Murray, Kellyn F. Arnold, Laurie Berrie, Matthew P. Fox, Sarah C. Gadd, Wendy J. Harrison et al. "Use of directed acyclic graphs (DAGs) to identify confounders in applied health research: review and recommendations." _International journal of epidemiology_ 50, no. 2 (2021): 620-632. <https://academic.oup.com/ije/article/50/2/620/6012812>

