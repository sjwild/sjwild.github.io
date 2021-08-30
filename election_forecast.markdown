---
layout: page
title: 2021 election forecast
permalink: /election-forecast/
---

Last updated: __August 30, 2021__

This is my forecast for the Canadian 2021 federal election on Sepetember 20, 2021. I use polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_2021_Canadian_federal_election) to try estimate underlying vote intention for each party. The predictions for voting intention and seat count (that is, for the period after 2019-10-21, the date of 2019 Canadian election) assume that the polling errors are the same both pre- and post- 2019 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

As of August 30, 2021, The CPC are in the lead. But it's important to note that there is lots of time until the election, and things can shift easily. Estimated vote intention on August 29th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 31.3%           | (29.6%, 32.9%)     |
|**CPC**      | 36.9%           | (35.5%, 38.3%)     |
|**NDP**      | 18.4%           | (17.0%, 19.7%)     |
|**BQ**       | 6.7%            | (6.1%, 7.2%)       |
|**GPC**      | 2.5%            | (1.8%, 3.3%)       |
|**Other**    | 4.2%            | (3.6%, 4.9%)       |

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png "Density plot of estimated vote share per party.")

As we can see, vote share is shifting over time. The CPC is now in the lead, with the LPC second.

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_2019_2021.png "Vote share of Canadian parties from 2019 to 2021.")

# Seat counts

While the data suggests an CPC victory, the total seat count is uncertain. Based on 10,000 simulations, if the election were held today the most likely outcome is an CPC minority government. If the election were held August 30, the CPC has a 99% chance winning.

|**Party**    | **Seat count**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 120             | (108, 131)         |
|**CPC**      | 153             | (142, 164)         |
|**NDP**      | 26              | (21, 30)           |
|**BQ**       | 37              | (32, 41)           |
|**GPC**      | 2               | (1, 3)             |
|**Other**    | 1               | (0, 3)             |


You can find all of the code for these models [here](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png). Right now this page is from a mishmash of models, but I will clean up the scripts in the near future. 

Nothing in these models is original, and I owe a debt to others who have done this before me. You can find selected references at the above link.
