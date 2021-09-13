---
layout: page
title: 2021 election forecast
permalink: /election-forecast/
---

Last updated: __September 13, 2021__

This is my forecast for the Canadian 2021 federal election on Sepetember 20, 2021. I use polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_2021_Canadian_federal_election) to try estimate underlying vote intention for each party. The predictions for voting intention and seat count (that is, for the period after 2019-10-21, the date of 2019 Canadian election) assume that the polling errors are the same both pre- and post- 2019 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

As of September 11, 2021, The CPC are in the lead. But it's important to note that there is lots of time until the election, and things can shift easily. Estimated vote intention for September 20th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 33.2%           | (30.3%, 36.1%)     |
|**CPC**      | 34.7%           | (32.2%, 37.2%)     |
|**NDP**      | 17.6%           | (15.4%, 19.9%)     |
|**BQ**       | 6.4%            | (5.5%, 7.2%)       |
|**GPC**      | 2.2%            | (1.0%, 3.4%)       |
|**Other**    | 6.1%            | (5.0%, 7.2%)       |

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png "Density plot of estimated vote share per party.")

As we can see, vote share is shifting over time. The CPC is now in a narrow lead, with the LPC second.

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_2019_2021.png "Vote share of Canadian parties from 2019 to 2021.")

# Seat counts

While I have projected an CPC victory, it is close. Based on 10,000 simulations, if the election were held today the most likely outcome is an CPC minority government. Based on my projections, the CPC has a 54% chance of winning.

|**Party**    | **Seat count**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 136             | (118, 152)         |
|**CPC**      | 138             | (124, 154)         |
|**NDP**      | 25              | (20, 30)           |
|**BQ**       | 36              | (31, 40)           |
|**GPC**      | 2               | (1, 3)             |
|**Other**    | 1               | (0, 4)             |

You can find all of the code for these models [here](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png). The projections on this page come from a model written in Julia and Turing. You can find the script for the model [here](https://github.com/sjwild/Canandian_Election_2021/blob/main/Election%202021%20Turing.jl). 

Nothing in these models is original, and I owe a debt to others who have done this before me. You can find selected references at the above link.
