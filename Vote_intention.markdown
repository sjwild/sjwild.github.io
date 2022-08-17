---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---


## Federal 
Last updated: __August 16, 2022__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post- 2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including August 16, 2022, the CPC is ahead. Estimated vote intention for August 16th was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 32.2%           | (29.5%, 35.1%)     |
|**CPC**      | 34.4%           | (32.0%, 38.1%)     |
|**NDP**      | 17.6%           | (15.7%, 19.6%)     |
|**BQ**       | 7.8%            | (6.0%, 8.8%)       |
|**GPC**      | 3.4%            | (2.5%, 4.6%)       |
|**PPC**      | 3.3%            | (1.3%, 5.0%)       |
|**Other**    | 1.4%            | (0.8%, 2.1%)       |


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_house_effects_pollsters_2019_2022.png "House effects of Canadian polling firms from 2019 to 2022.")




## Ontario vote intention

Last updated: __August 16, 2022__

A few months ago, Ontario held a provincial election. Altough no election will be held for 4 years, below is my estimate of Ontario vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/2022_Ontario_general_election#Opinion_polls). Because there are fewer polls here than at the federal level, the underlying vote intentional is much more impercise. Nonetheless, we can see the PCs are well in the lead. 

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**CPC**      | 41.6%           | (32.6%, 50.7%)     |
|**NDP**      | 24.9%           | (22.0%, 32.4%)     |
|**Liberal**  | 20.1%           | (24.8%, 31.7%)     |
|**Green**    | 6.7%            | (4.5%, 10.5)       |
|**Other**    | 5.8%            | (3.9%, 7.6%)       |

![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_vote_intention_2022.png "Density plot of estimated vote share per party in Ontario, 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_vote_intention_2014_2022.png "Vote share of Ontario parties from 2014 to 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Ontario/ON_house_effects_pollsters_2014_2022.png "House effects of polling firms surveying residents of Ontario, 2014 to 2022.")




## Credit where credit is due
Nothing in these models is original, and I owe a debt to others who have done this before me. In particular, the following models were helpful:

Bailey, J. (2021). britpol v0.1.0: User Guide and Data Codebook. Retrieved from [https://doi.org/10.17605/OSF.IO/2M9GB](https://doi.org/10.17605/OSF.IO/2M9GB).  

Economist (2020.) Forecasting the US elections. Retrieved from [https://projects.economist.com/us-2020-forecast/president](https://projects.economist.com/us-2020-forecast/president). 

Ellis, P. (2019). ozfedelect R package. Retrieved from [https://github.com/ellisp/ozfedelect](https://github.com/ellisp/ozfedelect).   

Savage, J.(2016). Trump for President? Aggregating National Polling Data. Retrieved from [https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html](https://khakieconomics.github.io/2016/09/06/aggregating-polls-with-gaussian-Processes.html).  

INWT Statistics GmbH (2021). Election forecast. Retrieved from [https://github.com/INWTlab/lsTerm-election-forecast](https://github.com/INWTlab/lsTerm-election-forecast).  

