---
layout: page
title: 2021 election forecast
permalink: /election-forecast/
---

Last updated: __August 20, 2021__

This is my forecast for the Canadian 2021 federal election on Sepetember 20, 2021. I use polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_2021_Canadian_federal_election) to try estimate underlying vote intention for each party. The predictions for voting intention and seat count (that is, for the period after 2019-10-21, the date of 2019 Canadian election) assume that the polling errors are the same both pre- and post- 2019 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

As of August 19, 2021, I forecast a LPC victory. But it's important to note that there is lots of time until the election, and things can shift easily. 

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 35.6%           | (33.9%, 37.4%)     |
|**CPC**      | 31.5%           | (30.1%, 32.8%)     |
|**NDP**      | 18.6%           | (17.2%, 20.2%)     |
|**BQ**       | 6.9%            | (6.2%, 7.5%)       |
|**GPC**      | 3.6%            | (2.8%, 4.4%)       |
|**Other**    | 4.1%            | (3.4%, 4.9%)       |

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png "Density plot of estimated vote share per party.")

As we can see, vote share is shifting over time. 

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_2019_2021.png "Vote share of Canadian parties from 2019 to 2021.")

# Seat counts

While the data suggests an LPC victory, the total seat count is uncertain. Based on 10,000 simulations, the most likely outcome is an LPC minority government.

|**Party**    | **Seat count**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 156             | (146, 165)         |
|**CPC**      | 119             | (111, 126)         |
|**NDP**      | 25              | (22, 29)           |
|**BQ**       | 34              | (30, 38)           |
|**GPC**      | 2               | (2, 4)             |
|**Other**    | 1               | (0, 3)             |


You can find all of the code for these models [here](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_on_election_date.png). Right now this page is from a mishmash of models, but I will clean up the scripts in the near future. 

Nothing in these models is original, and I owe a debt to others who have done this before me. You can find selected references at the above link.
