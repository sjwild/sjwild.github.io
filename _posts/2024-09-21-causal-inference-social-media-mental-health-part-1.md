---
layout: post
title:  "Causal inference, social media, and mental health, part 1"
date:   2024-09-21 08:00:00 -0400
categories: blog
usemathjax: true

---

_This is part 1 of a ? part series_

What can we learn from some RCTs about the effect of social media on mental health? Zach Rausch and Jon Haidt have started a four-part (?) [critique](https://www.afterbabel.com/p/the-case-for-causality-part-1) of a recent [meta analysis](https://psycnet.apa.org/doiLanding?doi=10.1037%2Fppm0000541) by Chris Ferguson. This led to a bit of kerfuffle on social media after Matthew Jané [critiqued](https://matthewbjane.com/blog-posts/blog-post-6.html) Rausch and Haidt's critique. Rausch and Haidt updated their blog post, which Jané responded to [here](https://matthewbjane.com/blog-posts/blog-post-7.html). Rausch and Haidt post part two [here]().

This kerfuffle has led me to decide to devote a few blog posts to various topics around estimating causal effects from social media. So far I have 4 to 5 planned posts in my head, so we'll see where this series goes. If I proceed as planned, the next post will build on this one by simulating data and showing the causal effect of closing different paths. Posts 3 and 4 will add in the time series element. Then we'll see.

For the purposes of this post, the key quote comes from Jané's response to Rausch and Haidt's response. 

> In reality, I actually think that social media probably does have an average negative effect on mental health. I also probably agree that the RCTs in this meta-analysis probably won’t find any convincing causal estimates.

Jané is correct (Ferguson makes similar statements in his meta analysis, noting that the "studies are "study designs are not capable of answering causal questions"). I have no intention of discussing those studies individually or setting out what weaknesses may threaten their internal and external validity. Read the Ferguson meta analysis for a bit more. Instead, I want to lay out why those studies, even if they had been conducted perfectly, could at best only ever let us estimate a small portion of the total causal effect of social media on mental health. I think this matters, because the discussion around these studies seems to imply that these studies estimate _the_ total causal effect. They do not.

## Enter DAGs
To illustrate my case, I am going to make use of Directed Acyclic Graphs (DAGs). If you don't know much about DAGs, you can stop reading here and read a great introduction to them in chapter 6 of Nick Huntington-Klein's [The Effect](https://theeffectbook.net/ch-CausalDiagrams.html). If you want more resources, I'll list a few below at the end of the post.

For what follows, I am going to use a few simple DAGs to make my point. I'm going to be a bit unorthodox with a couple of them. Because I am keeping them simple, I am going to limit the amount of information I include on them, including all the potential variables and causal paths. I'm not going to consider temporal sequence. So if you look at these DAGs and say to yourself, "These are wrong! It is much more complicated. I can do a better job!", don't worry: You are correct. I encourage you to draw them out and share them. Maybe even write a blog post explaining why I am wrong and showing us your ideal DAG.

Let's start with simple DAG. We have social media, our exposure. How am I defining social media here? It doesn't matter. Social media can include Twitter, facebook, Youtube, whatever you want. For the purposes of our DAG, it's all getting lumped together (that is also a major problem with social media research, but I digress).

On to the DAG. Social media influences mental health, so we have the following DAG:

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/simple-dag.png  "A simple DAG showing a direct path from social media to mental health.")

You can clearly see here that social media is affecting my mental health. The arrow goes straight from social media to my mental health. _How_ it does this, the mechanism by which social media affects my mental health, is unimportant here. All that matters for our purposes is that social media affects my mental health.

According to Rausch and Haidt, the interventions in the Ferguson meta analysis take two forms: either reduction experiments or lab exposures. For simplicty, we're going to focus on the reduction experiments. In a reduction study, participants assigned to the treatment group are instructed to reduce their time on social media. Most participants in the treatment groups still use social media, they just use less of it. This makes "time on social media" a moderator. That is, social media affects our mental health based on how much time users spend on it. More time, worse mental health impacts, for instance. DAGs generally don't include moderators, but for our purposes (because this is illustrative and I'm being unorthodox) we're going to have it point to the causal arrow from social media to mental health. We can include it in our DAG using a [few tricks](https://github.com/r-causal/ggdag/issues/6), like so:

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/simple-dag-moderator.png  "A simple DAG showing a direct path from social media to mental health. Time is entered as a moderator, with a line that intersects with the direct path from social media to mental health.")

## A more complicated DAG
But who else is social media affecting? Well, social media affects my friends ("FR"), for starters. All my friends are on it too, so it affects them as well. Even if social media doesn't affect their mental health at all, they could be too busy (maybe being on social media) to hang out with me, and that affects my mental health. We can add that to our DAG.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/dag-friends.png  "A simple DAG showing a direct path from social media to mental health. Time is entered as a moderator, with a line that intersects with the direct path from social media to mental health. There is now a path from social media to friends to mental health.")

And who else? People who aren't my friends. Maybe my family ("FM"). Maybe other people ("OP"). So let's add them. And social media has also contributed to other stuff ("OS"), like news coverage. Even if I'm not on social media, news headlines are optimized for them, so too the content and topics of news stories. So even if I'm not on social media, they can still affect me through this channel. So let's add that.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/multiple-paths-dag.png  "A DAG showing a direct path from social media to mental health. Time is entered as a moderator, with a line that intersects with the direct path from social media to mental health. There are multiple paths through friends, family, other people from social media to mental health.")

## But I reduced my use of social media
Now let's assume I join one of these experiments, and I reduce my social media use to zero. I throw my phone in the ocean, maybe. There is no longer a direct path from social media to me, because I am no longer using it. So let's keep being unorthodox and take that line out of our DAG, along with the moderator. This isn't exactly how DAGs work, but it's very helpful here.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/direct-path-removed-dag.png  "The DAG no longer shows a direct path from social media to mental health. But there are still multiple paths through friends, family, other people from social media to mental health.")

Our DAG is still missing something. There are other things that affect my mental health. Exercise, for instance. Or spending time with friends. Or engaging in hobbies (like writing a blog post 3 people will read). So let's add them together as other activities ("OA") and draw an arrow to mental health.

![alt text](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2024-09-21-causal-inference-social-media-mental-health-part-1/direct-path-removed-OA-dag.png  "The DAG no longer shows a direct path from social media to mental health. But there are still multiple paths through friends, family, other people from social media to mental health. Other activities now have a direct path to mental health")

So do we see? We can see that social media still affects my mental health through my friends and through everyone else. But this DAG lets us see something clearly: what we're estimating in time reduction experiments. At best, we are estimating the causal effect of _reducing one's own time on social media and filling that time with different activities when everyone else still uses social media as they did before one participated in the experiment_. 

So is the causal effect social media or something else? It's hard to say. There's a fixed number of hours in a day, and I need to be doing something with that time. So our causal effect may not actually the effect of social media, but could be other things. I get more exercise, maybe, which improves my mental health. Or I spend some more time with my friends, which also improves my mental health. Either of those could have improved my mental health had I replaced other activities with them and spent the same amount of time on social media.

## So what to do with the RCTs in the Ferguson meta analysis?
The answer here isn't to throw out those RCTs. They do tell us something, even if it's not what we think it is (or, at the very least, what we seem to be arguing over). But it does mean that we need to think carefully about our estimand when we conduct RCTs, and it means designing RCTs that target the estimand we want. I want to be clear that I don't know what those RCTs should look like. But there are lots of clever and competent people who do. Let's fund them and let them do their job.

## A few thank yous and some references
I want to thank Joe Bak-Coleman and Craig Sewall, who read this post in advance and gave feedback. All errors are mine, good things theirs. Before writing this post, I also put out a call on Twitter for a list of resources about the weaknesses of RCTs. I got some great articles, and a few of them have been helpful in getting me to think through how we might design different RCTs. You can find a few of them listed in the references section below.

## References and other reading
Attia, John, Elizabeth Holliday, and Christopher Oldmeadow. "A proposal for capturing interaction and effect modification using DAGs." _International Journal of Epidemiology_ 51, no. 4 (2022): 1047-1053. [https://doi.org/10.1093/ije/dyac126](https://doi.org/10.1093/ije/dyac126).

Bailey, Drew H., Alexander J. Jung, Adriene M. Beltz, Markus I. Eronen, Christian Gische, Ellen L. Hamaker, Konrad P. Kording et al. "Causal inference on human behaviour." _Nature Human Behaviour_ 8, no. 8 (2024): 1448-1459. [https://doi.org/10.1038/s41562-024-01939-z](https://doi.org/10.1038/s41562-024-01939-z).

Cook, Thomas D. "Twenty-six assumptions that have to be met if single random assignment experiments are to warrant “gold standard” status: A commentary on Deaton and Cartwright." _Social science & medicine_ 210 (2018): 37-40. [https://doi.org/10.1016/j.socscimed.2018.04.031](https://doi.org/10.1016/j.socscimed.2018.04.031).

Deaton, Angus, and Nancy Cartwright. "Understanding and misunderstanding randomized controlled trials." _Social science & medicine_ 210 (2018): 2-21. [https://doi.org/10.1016/j.socscimed.2017.12.005](https://doi.org/10.1016/j.socscimed.2017.12.005).

Ferguson, Christopher J. "Do social media experiments prove a link with mental health: A methodological and meta-analytic review." _Psychology of Popular Media_ (2024). [https://doi.org/10.1037/ppm0000541](https://doi.org/10.1037/ppm0000541).

Fumagalli, Elena, L. J. Shrum, and Tina M. Lowrey. "The effects of social media consumption on adolescent psychological well-being." _Journal of the Association for Consumer Research_ 9, no. 2 (2024): 119-130. [https://doi.org/10.1086/728739](https://doi.org/10.1086/728739).

Huntington-Klein, Nick. _The effect: An introduction to research design and causality_. Chapman and Hall/CRC, 2021. [https://www.taylorfrancis.com/books/mono/10.1201/9781003226055/effect-nick-huntington-klein](https://www.taylorfrancis.com/books/mono/10.1201/9781003226055/effect-nick-huntington-klein).

Lundberg, Ian, Rebecca Johnson, and Brandon M. Stewart. "What is your estimand? Defining the target quantity connects statistical evidence to theory." _American Sociological Review_ 86, no. 3 (2021): 532-565. [https://doi.org/10.1177/00031224211004187](https://doi.org/10.1177/00031224211004187).

Morgan, Stephen, and Christopher Winship. _Counterfactuals and causal inference_. Cambridge University Press, 2015.

Pearl, Judea. _Causal inference in statistics: a primer_. John Wiley & Sons, 2016.




