---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---


## Federal 
Last updated: __April 29, 2022__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post- 2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including April 29, 2022, the CPC is ahead. Estimated vote intention for April 29th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 31.2%           | (28.5%, 33.9%)     |
|**CPC**      | 36.9%           | (33.8%, 40.0%)     |
|**NDP**      | 17.1%           | (15.2%, 19.0%)     |
|**BQ**       | 7.2%            | (6.1%, 8.2%)       |
|**GPC**      | 3.5%            | (2.2%, 4.8%)       |
|**PPC**      | 3.0%            | (1.5%, 4.3%)       |
|**Other**    | 1.1%            | (0.1%, 1.7%)       |


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Federal/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Federal/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")

### Estimated house effects: 

![alt text](https://github.com/sjwild/Canadian_Election_2021/blob/main/Images/Federal/can_house_effects_pollsters_2019_2022.png "House effects of Canadian polling firms from 2019 to 2022.")


## Ontario vote intention

Last updated: __April 29, 2022__

Sometime in the next few months, Ontario should be heading towards a provincial election. This is my estimate of Ontario vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/2022_Ontario_general_election#Opinion_polls). Because there are fewer polls here than at the federal level, the underlying vote intentional is much more impercise. nonetheless, we can see the PCs are well in the lead at this point. Interestingly, the NDP has lost support and the Liberals have gained enough that they are now in second place.

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**CPC**      | 37.7%           | (34.4%, 41.0%)     |
|**NDP**      | 23.8%           | (20.0%, 27.6%)     |
|**Liberal**  | 30.8%           | (26.5%, 35.1%)     |
|**Green**    | 3.7%            | (2.3%, 5.2%)       |
|**Other**    | 5.2%            | (3.7%, 6.8%)       |

![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_vote_intention_2022.png "Density plot of estimated vote share per party in Ontario, 2022.")


![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_vote_intention_2014_2022.png "Vote share of Ontario parties from 2014 to 2022.")


### Estimated Ontario house effects

![alt text](https://github.com/sjwild/Canadian_Election_2021/raw/main/Images/Ontario/ON_house_effects_pollsters_2014_2022.png "House effects of polling firms surveying residents of Ontario, 2014 to 2022.")




## Credit where credit is due
Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from https://doi.org/10.17605/OSF.IO/2M9GB.  

Economist (2020.) Forecasting the US elections. Retrieved from https://projects.economist.com/us-2020-forecast/president. 

Ellis, P. (2019). ozfedelect R package. Retrieved from https://github.com/ellisp/ozfedelect.   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html.  

INWT Statistics GmbH (2021). Election forecast. Retrieved from https://github.com/INWTlab/lsTerm-election-forecast.  

