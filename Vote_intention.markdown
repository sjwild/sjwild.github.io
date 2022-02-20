---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---


# Federal 
Last updated: __February 19, 2022__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post- 2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including February 19, 2022, the LPC and CPC are roughly tied. Estimated vote intention for February 19th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 31.2%           | (28.9%, 33.5%)     |
|**CPC**      | 37.1%           | (34.4%, 39.8%)     |
|**NDP**      | 15.8%           | (14.1%, 17.5%)     |
|**BQ**       | 7.7%            | (6.8%, 8.5%)       |
|**GPC**      | 2.3%            | (1.5%, 3.2%)       |
|**PPC**      | 4.5%            | (3.1%, 5.9%)       |
|**Other**    | 1.3%            | (0.9%, 1.8%)       |


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")

## Estimated house effects: 

![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/house_effects_pollsters_2019_2021.png "House effects of Canadian polling firms.")


# Ontario vote intention

Last updated: __February 19, 2022__

Sometime in the next few months, Ontario should be heading towards a provincial election. This is my estimate of Ontario vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/2022_Ontario_general_election#Opinion_polls). Because there are fewer polls here than at the federal level, the underlying vote intentional is much more impercise.

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**CPC**      | 36.5%           | (31.6%, 41.2%)     |
|**NDP**      | 29.0%           | (23.2%, 34.0%)     |
|**Liberal**  | 25.6%           | (19.3%, 32.1%)     |
|**Green**    | 3.5%            | (1.5%, 5.4%)       |
|**Other**    | 5.4%            | (2.5%, 8.5%)       |

![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_vote_intention_2022.png "Density plot of estimated vote share per party in Ontario, 2022.")


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_vote_intention_2014_2022.png "Vote share of Ontario parties from 2014 to 2022.")


## Estimated Ontario house effects

![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_house_effects_pollsters_2014_2022.png "House effects of polling firms surveying residents of Ontario, 2014 to 2022.")




## Credit where credit is due
Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from https://doi.org/10.17605/OSF.IO/2M9GB.  

Economist (2020.) Forecasting the US elections. Retrieved from https://projects.economist.com/us-2020-forecast/president. 

Ellis, P. (2019). ozfedelect R package. Retrieved from https://github.com/ellisp/ozfedelect.   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html.  

INWT Statistics GmbH (2021). Election forecast. Retrieved from https://github.com/INWTlab/lsTerm-election-forecast.  
