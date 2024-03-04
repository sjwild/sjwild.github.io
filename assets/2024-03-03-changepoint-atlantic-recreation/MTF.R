library(tidyverse)
library(haven)
library(survey)
library(here)
library(cmdstanr)
library(posterior)
library(bayesplot)
library(ThemePark)
library(tidybayes)

# Get a list of files
files_to_open <- list.files(paste0(here(), "/Data"))

# Read files into a list. 
# Variables are not consistently named across years
d_list <- list()
for(i in 1:length(files_to_open)){
  d_list[[i]] <- read_dta(paste0(here(), "/Data/", files_to_open[i]))
}

# We need to extract variables of interest
# Because variables are inconsistently named, we'll need to recode them
# I'd like this part to be clearer, but sadly it isn't
# It will work fine so long as you didn't rename the files
recode_indicator <- c(rep(1, 10), 2, rep(1, 9), rep(3, 11))
data_to_combine <- list()
for(i in 1:length(files_to_open)){
  if(recode_indicator[i] == 1){
    data_to_combine[[i]] <- d_list[[i]][,c("V1", "V5", "V150", "V194")]
  } else if(recode_indicator[i] == 2){
    data_to_combine[[i]] <- d_list[[i]][, c("V5", "V8", "V13", "V58")]
  } else if(recode_indicator[i] == 3){
    data_to_combine[[i]] <- d_list[[i]][,c("V1", "ARCHIVE_WT", "V2150", "V2194")]
  }
  
  names(data_to_combine[[i]]) <- c("year", "WT", "Sex", "Wk_out")
}


# Combine data into one master file
d <- data_to_combine[[1]]

# Just turn the variables to numeric for now.
d$year <- as.numeric(d$year)
d$WT <- as.numeric(d$WT)
d$Wk_out <- as.numeric(d$Wk_out)
d$Sex <- as.numeric(d$Sex)

for(i in 2:length(data_to_combine)){
  d_tmp <- data_to_combine[[i]]
  
  d_tmp$year <- as.numeric(d_tmp$year)
  d_tmp$WT <- as.numeric(d_tmp$WT)
  d_tmp$Wk_out <- as.numeric(d_tmp$Wk_out)
  d_tmp$Sex <- as.numeric(d_tmp$Sex)
  
  d <- rbind(d, d_tmp)
}

# recode variables to produce the chart
d$Wk_out_cat <- ifelse(d$Wk_out %in% c(3, 4, 5, 6), "2 or more times a week", "< 2 times a week")
d$Wk_out_cat <- as.factor(ifelse(d$Wk_out %in% c(0, 9, -9), NA, d$Wk_out_cat))
d$Sex_cat <- ifelse(d$Sex == 1, "Male", "Female")
d$Sex_cat <- as.factor(ifelse(d$Sex %in% c(3, 4), "Other", d$Sex_cat))
d$Sex_cat[d$Sex == -9] <- NA
d$year <- ifelse(d$year < 100, d$year + 1900, d$year)


# Make survey design object to use weights
d_svy <- svydesign(ids = ~0, data = d, weights = d$WT)
d_agg <- svyby(~Wk_out_cat, ~year + Sex_cat, design = d_svy, FUN = svymean, na.rm = TRUE)
d_agg$twice_or_more <- d_agg$`Wk_out_cat2 or more times a week` 
d_agg$se_twice_or_more <- d_agg$`se.Wk_out_cat2 or more times a week` 


# Create plot
modified_theme_oppenheimer <- theme_oppenheimer() +
  theme(legend.direction = "horizontal",
        legend.position = "top",
        legend.background = element_rect(fill = "white"),
        plot.title = element_text(size = 48),
        axis.text = element_text(size = 30),
        legend.text = element_text(size = 30))

ggplot(subset(d_agg, Sex_cat != "Other"),
       mapping = aes(x = year,
                     y = twice_or_more,
                     group = Sex_cat,
                     colour = Sex_cat,
                     ymin = twice_or_more - 2 * se_twice_or_more,
                     ymax = twice_or_more + 2 * se_twice_or_more)) +
  geom_line() +
  geom_pointrange() +
  geom_smooth() + 
  ylim(.4, .9) +
  labs(y = NULL,
       title = "Proportion 12th graders who report going out for recreation\nat least twice per week") +
  scale_colour_manual(values = c("white",
                                 "grey65"),
                      name = NULL) +
  labs(caption = "Source: Monitoring the Future\nResponses to the question: During a typical week, on how many evenings do you go out for fun and recreation?
       Analysis by sjwild.github.io") +
  modified_theme_oppenheimer

ggsave("atlantic_recreation_reproduced.png", width = 2000, height = 1150, units = "px")


#### Simulate data to test model ####
alpha1 <- 10
alpha2 <- 60
beta1 <- .4
beta2 <- -.3
sigma <- 3
changepoint <- 75
set.seed(12345)
x <- seq(0, 100, by = 1)
y<- rep(0, N)

for(n in 1:length(x)){
  if(x[n] < changepoint){
    y[n] <- alpha1 + x[n] * beta1 + rnorm(1, 0, sigma)
  } else {
    y[n] <- alpha2 + x[n] * beta2 + rnorm(1, 0, sigma)
  }
}

# Plot data
ggplot(data.frame(x = x, y = y)) +
  geom_point(mapping = aes(x = x,
                           y = y),
             colour = "white") +
  labs(title = "Simulated data for changepoint model",
       caption = "Analysis by sjwild.github.io") +
  modified_theme_oppenheimer
ggsave("simulated_data_changepoint.png", width = 2000, height = 1150, units = "px")



# Load changepoint model
changepoint_model <- cmdstan_model(paste0(here(), "/changepoint_model.stan"))

# Load data and fit model
stan_data_sim <- list(
  y = y,
  x = x,
  T = length(y),
  prior_alpha_sigma = 50,
  prior_beta_sigma = 10,
  prior_sigma = 2
)

fit_test <-  changepoint_model$sample(data = stan_data_sim,
                                      chains = 8,
                                      parallel_chains = 8,
                                      iter_warmup = 1000,
                                      iter_sampling = 2500)


# Plot draws
s_test <- as_draws_rvars(fit_test$draws("s"))
s_test %>%
  spread_draws(s) %>%
  ggplot(aes(x = s)) +
  stat_histinterval(colour = "grey65",
                    fill = "white") +
  labs(x = NULL,
       y = NULL,
       title = "Estimated changepoint",
       caption = "Analysis by sjwild.github.io") +
  modified_theme_oppenheimer +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank())
ggsave("recovered_changepoint_simulated_data.png", width = 2000, height = 1150, units = "px")




# Fit actual data
d_agg_combined <- svyby(~Wk_out_cat, ~year, design = d_svy, FUN = svymean, na.rm = TRUE)
d_agg_combined$twice_or_more <- d_agg_combined$`Wk_out_cat2 or more times a week` * 100
d_agg_combined$se_twice_or_more <- d_agg_combined$`se.Wk_out_cat2 or more times a week` * 100

stan_data <- list(
  y = d_agg_combined$twice_or_more,
  x = d_agg_combined$year - min(d_agg_combined$year),
  T = nrow(d_agg_combined),
  prior_alpha_sigma = 50,
  prior_beta_sigma = 5,
  prior_sigma = 2
)



fit <- changepoint_model$sample(data = stan_data,
                                chains = 4,
                                parallel_chains = 4,
                                iter_warmup = 1000,
                                iter_sampling = 2000)


s <- as_draws_rvars(fit$draws("s"))
s %>%
  spread_draws(s) %>%
  mutate(s = s + min(d_agg_combined$year)) %>%
  ggplot(aes(x = s)) +
  stat_histinterval(colour = "grey65",
                    fill = "white", 
                    position = position_dodge(.5)) +
  labs(x = NULL,
       y = NULL,
       title = "Estimated changepoint in MTF data",
       caption = "Source: Monitoring the Future\nResponses to the question: During a typical week, on how many evenings do you go out for fun and recreation?
       Analysis by sjwild.github.io") +
  modified_theme_oppenheimer +
  theme(axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(hjust = .75))
ggsave("recovered_changepoint_MTF.png", width = 2000, height = 1150, units = "px")


