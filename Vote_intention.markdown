---
layout: page
title: Canadian vote intention
permalink: /canadian-vote-intention/
---


## Federal 
Last updated: __June 22, 2024__

This is my estimate of Canadian vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/Opinion_polling_for_the_45th_Canadian_federal_election). The predictions for voting intention assume that the polling errors are the same both pre- and post-2021 election. That may or may not be true, but I suspect that polling errors are correlated between these periods.

Using polls up to and including June 22, 2024, the CPC is ahead. Estimated vote intention for June 22nd was:

|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**LPC**      | 24.8%           | (22.8%, 26.8%)     |
|**CPC**      | 44.5%           | (42.5%, 46.9%)     |
|**NDP**      | 16.1%           | (14.8%, 17.5%)     |
|**BQ**       | 8.4%            | (7.8%, 9.2%)       |
|**GPC**      | 3.1%            | (2.1%, 4.0%)       |
|**PPC**      | 1.5%            | (0.4%, 2.5%)       |
|**Other**    | 0.7%            | (0.3%, 1.2%)       |


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_post_2021.png "Density plot of estimated vote share per party.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_vote_intention_2019_post_2021.png "Vote share of Canadian parties from 2019 to 2022.")


![alt text](https://raw.githubusercontent.com/sjwild/Canadian_Election_2021/main/Images/Federal/can_house_effects_pollsters_2019_2022.png "House effects of Canadian polling firms from 2019 to 2022.")




## Ontario vote intention

Last updated: __June 22, 2024__

Although no election will be held for a few more years, below is my estimate of Ontario vote intention based on polls listed on [Wikipedia](https://en.wikipedia.org/wiki/2022_Ontario_general_election#Opinion_polls). Because there are fewer polls here than at the federal level, the underlying vote intention is much more impercise. Nonetheless, we can see the PCs are well in the lead. 

PC: [0.4158513345, 0.346577225, 0.4858826]
NDP: [0.22009655975, 0.1708379, 0.27027982500000003]
Liberal: [0.23403230314999998, 0.15187200000000003, 0.3121968]
Green: [0.075574805975, 0.0425950075, 0.107463875]
Other: [0.056048404375000006, 0.039656032499999994, 0.0734506075]
|**Party**    | **Vote share**  | **95% bounds**     |
|-------------|:---------------:|:------------------:|
|**PC**       | 41.6%           | (34.6%, 48.6%)     |
|**NDP**      | 22.0%           | (17.1%, 27.0%)     |
|**Liberal**  | 23.4%           | (15.1%, 31.2%)     |
|**Green**    | 7.6%            | (4.3%, 10.7)       |
|**Other**    | 5.6%            | (4.0%, 7.3%)       |

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

