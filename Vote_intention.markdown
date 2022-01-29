---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---

Last updated: __January 27, 2022__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post- 2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including January 27, 2022, the LPC and CPC are tied. Estimated vote intention for January 27th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 32.2%           | (30.0%, 34.3%)     |
|**CPC**      | 32.1%           | (29.6%, 34.5%)     |
|**NDP**      | 17.4%           | (15.9%, 18.8%)     |
|**BQ**       | 7.3%            | (6.4%, 8.1%)       |
|**GPC**      | 3.1%            | (2.3%, 4.0%)       |
|**PPC**      | 5.9%            | (4.6%, 7.3%)       |
|**Other**    | 1.6%            | (1.1%, 2.1%)       |


![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")

Here are the estimated house effects: 

![alt text](https://github.com/sjwild/Canandian_Election_2021/raw/main/house_effects_pollsters_2019_2021.png "House effects of Canadian polling firms.")


## Credit where credit is due
Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from https://doi.org/10.17605/OSF.IO/2M9GB.  

Economist (2020.) Forecasting the US elections. Retrieved from https://projects.economist.com/us-2020-forecast/president. 

Ellis, P. (2019). ozfedelect R package. Retrieved from https://github.com/ellisp/ozfedelect.   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html.  

INWT Statistics GmbH (2021). Election forecast. Retrieved from https://github.com/INWTlab/lsTerm-election-forecast.  
