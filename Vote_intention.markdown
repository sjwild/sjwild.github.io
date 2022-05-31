---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---


## Federal 
Last updated: __May 31, 2022__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post- 2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including May 16, 2022, the CPC is ahead. Estimated vote intention for May 16th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 32.1%           | (29.5%, 34.7%)     |
|**CPC**      | 35.0%           | (32.0%, 38.1%)     |
|**NDP**      | 17.5%           | (15.7%, 19.4%)     |
|**BQ**       | 7.2%            | (6.0%, 8.3%)       |
|**GPC**      | 3.7%            | (2.5%, 4.9%)       |
|**PPC**      | 3.0%            | (1.3%, 4.6%)       |
|**Other**    | 1.3%            | (0.1%, 1.9%)       |


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_house_effects_pollsters_2019_2022.png "House effects of Canadian polling firms from 2019 to 2022.")




## Ontario vote intention

Last updated: __May 31, 2022__

Sometime in the next few months, Ontario should be heading towards a provincial election. This is my estimate of Ontario vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/2022_Ontario_general_election#Opinion_polls). Because there are fewer polls here than at the federal level, the underlying vote intentional is much more impercise. nonetheless, we can see the PCs are well in the lead at this point. 

PC: [0.37286801825000004, 0.34696869999999996, 0.39807657500000004]
NDP: [0.24869677299999995, 0.2196887, 0.275815875]
Liberal: [0.276324122, 0.24753350000000002, 0.30585855]
Green: [0.059164289249999995, 0.04475937, 0.0732684725]
Other: [0.04810306522499999, 0.039100205, 0.05715383]

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**CPC**      | 37.3%           | (34.7%, 39.8%)     |
|**NDP**      | 24.7%           | (22.0%, 27.6%)     |
|**Liberal**  | 27.6%           | (24.8%, 30.5%)     |
|**Green**    | 5.9%            | (4.5%, 7.3%)       |
|**Other**    | 4.8%            | (3.9%, 5.7%)       |

![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_vote_intention_2022.png "Density plot of estimated vote share per party in Ontario, 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_vote_intention_2014_2022.png "Vote share of Ontario parties from 2014 to 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_house_effects_pollsters_2014_2022.png "House effects of polling firms surveying residents of Ontario, 2014 to 2022.")




## Credit where credit is due
Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from https://doi.org/10.17605/OSF.IO/2M9GB.  

Economist (2020.) Forecasting the US elections. Retrieved from https://projects.economist.com/us-2020-forecast/president. 

Ellis, P. (2019). ozfedelect R package. Retrieved from https://github.com/ellisp/ozfedelect.   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html.  

INWT Statistics GmbH (2021). Election forecast. Retrieved from https://github.com/INWTlab/lsTerm-election-forecast.  

