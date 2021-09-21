---
layout: page
title: 2021 election forecast
permalink: /election-forecast/
---

Last updated: __September 20, 2021__

This is my forecast for the Canadian 2021 federal election on Sepetember 20, 2021. I use polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_2021_Canadian_federal_election) to try estimate underlying vote intention for each party. The predictions for voting intention and seat count (that is, for the period after 2019-10-21, the date of 2019 Canadian election) assume that the polling errors are the same both pre- and post- 2019 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including September 17, 2021, the CPC and LPC are virtually tied. Estimated vote intention for September 20th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 32.5%           | (30.6%, 34.3%)     |
|**CPC**      | 33.4%           | (31.7%, 35.0%)     |
|**NDP**      | 18.2%           | (16.7%, 19.7%)     |
|**BQ**       | 7.1%            | (6.4, 7.7%)       |
|**GPC**      | 2.1%            | (1.2%, 2.9%)       |
|**Other**    | 7.2%            | (6.3%, 8.0%)       |

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png "Density plot of estimated vote share per party.")

As we can see, vote share shifted over time. While the CPC held a narrow lead, they are now tied with the LPC.

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_campaign_period.png "Vote share of Canadian parties during campaign period.")

# Seat counts

While I have projected an CPC victory, it is close. Based on 10,000 simulations, if the election were held today the most likely outcome is an LPC minority government. Based on my projections, the LPC has a 52% chance of winning.

|**Party**    | **Projected seat count**  | **95% bounds**     |
|-------------|:-------------------------:|:------------------:|
|**LPC**      | 137                       | (93, 177)          |
|**CPC**      | 134                       | (109, 170)         |
|**NDP**      | 26                        | (17, 38)           |
|**BQ**       | 38                        | (26, 44)           |
|**GPC**      | 2                         | (1, 4)             |
|**Other**    | 1                         | (0, 1)             |

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_seat_count_on_election_date.png "Projected seat count of Canadian parties on September 20, 2021.")

You can find all of the code for these models [here](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png). The projections on this page come from a model written in Julia and Turing. You can find the script for the model [here](https://github.com/sjwild/Canandian_Election_2021/blob/main/Election%202021%20Turing.jl). 

Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from https://doi.org/10.17605/OSF.IO/2M9GB.  

Economist (2020.) Forecasting the US elections. Retrieved from https://projects.economist.com/us-2020-forecast/president. 

Ellis, P. (2019). ozfedelect R package. Retrieved from https://github.com/ellisp/ozfedelect.   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html.  

INWT Statistics GmbH (2021). Election forecast. Retrieved from https://github.com/INWTlab/lsTerm-election-forecast.  
