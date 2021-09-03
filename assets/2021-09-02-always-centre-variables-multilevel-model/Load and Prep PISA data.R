library(tidyverse)
library(rvest)
library(data.table)
library(WDI)
library(brms)
library(lme4)
library(EdSurvey)
library(survey)
library(lmtest)
library(sandwich)

setwd("/Users/stephenwild/Desktop/Stats stuff/Twenge and Haidt")


#### Helper functions ####
reverse_var <- function(x){
  
  x <- tolower(x)
  x <- factor(x, levels = c("strongly disagree",
                            "disagree",
                            "agree",
                            "strongly agree"))
  return(x)
  
}

recode_internet_2012 <- function(x){
  
  x_tmp <- rep(NA, length(x))
  x <- tolower(x)
  x_tmp <- ifelse(x == "no time", 0, x_tmp)
  x_tmp <- ifelse(x == "1-30 minutes", 0.25, x_tmp)
  x_tmp <- ifelse(x == "31-60 minutes", 0.75, x_tmp)
  x_tmp <- ifelse(x == "between 1 and 2 hours", 1.5, x_tmp)
  x_tmp <- ifelse(x == "between 2 and 4 hours", 3, x_tmp)
  x_tmp <- ifelse(x == "between 4 hours and 6 hours", 5, x_tmp)
  x_tmp <- ifelse(x == "more than 6 hours", 7, x_tmp)
  
  return(x_tmp)

}

recode_internet_2015_2018 <- function(x){
  
  x_tmp <- rep(NA, length(x))
  x <- tolower(x)
  x_tmp <- ifelse(x == "no time", 0, x_tmp)
  x_tmp <- ifelse(x == "1-30 minutes per day", 0.25, x_tmp)
  x_tmp <- ifelse(x == "31-60 minutes per day", 0.75, x_tmp)
  x_tmp <- ifelse(x == "between 1 hour and 2 hours per day", 1.5, x_tmp)
  x_tmp <- ifelse(x == "between 2 hours and 4 hours per day", 3, x_tmp)
  x_tmp <- ifelse(x == "between 4 hours and 6 hours per day", 5, x_tmp)
  x_tmp <- ifelse(x == "more than 6 hours per day", 7, x_tmp)
  
  return(x_tmp)
  
}


theme_blog <- theme_minimal() +
  theme(plot.caption = element_text(colour = "grey50"),
        text = element_text(family = "Courier"),
        strip.text = element_text(size = rel(.9), face = "bold"),
        axis.text = element_text(size = rel(1.0)),
        plot.title  = element_text(face = "bold"),
        plot.subtitle  = element_text(face = "bold"),
        axis.line.x.bottom = element_line(colour = "grey50"),
        axis.line.y.left = element_line(colour = "grey50"))

Okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#000000")

#### list of countries and country codes for loading PISA data ####
countries <- c("Denmark", "Finland", "Germany", "Iceland", "Netherlands", "Norway",
               "Sweden", "Switzerland", "Austria", "Belgium", "Czechia",
               "France", "Greece", "Hungary", "Italy", "Luxembourg", "Poland", "Portugal",
               "Spain", "Bulgaria", "Russian Federation", "Latvia", "Australia", "Canada",
               "Ireland", "New Zealand", "United Kingdom of Great Britain and Northern Ireland", 
               "United States of America", "Brazil",
               "Chile", "Mexico", "Peru",
               "Hong Kong", "Japan", "Korea, Republic of", "Thailand", "Indonesia")


wiki <- read_html("https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes")
wiki_tables <- html_table(wiki, 
                          fill = TRUE, 
                          header = TRUE)
country_codes <- wiki_tables[[2]]
country_codes$Country <- country_codes$`English short name (using title case)`
country_codes$Code <- country_codes$`Alpha-3 code`
country_codes$Code_WDI <- country_codes$`Alpha-2 code`
country_codes <- country_codes[country_codes$Country %in% countries,]
country_codes$Country <- toupper(country_codes$Country)




#### Download PISA files ####
#
#
# This will take a while. You've been warned.
#
#
#############################
downloadPISA(
  root = "/Users/stephenwild/Desktop/Stats stuff/Twenge and Haidt",
  years = c(2000, 2003, 2009, 2012, 2015, 2018),
  database = "INT",
  cache = FALSE,
  verbose = TRUE
)



#### build weights for loading data ####
psus <- c("schoolid", "country")
weights <- rep(NA, 80)
weights_2015 <- rep(NA, 80)
for(i in 1:80) {
  weights[i] <- paste0("w_fstr", i)
  weights_2015[i] <- paste0("w_fsturwt", i)
}
weights[81] <- "w_fstuwt"
weights_2015[81] <- "w_fstuwt"



#### Load PISA data per year for loneliness ####
# this will take a while
# It take about 15 - 20 minutes per year
# For some reason I do not understand, pulling the data along with
# smartphone and internet variables leads to wonky numbers
# but doing them separately works
#
#################################

# PISA 2012
varnames_2012 <- c("st87q01", "st87q02", "st87q03", 
                   "st87q04", "st87q05", "st87q06")

# prepare PISA data.
PISA_2012 <- readPISA("PISA/2012",
                      database = "INT",
                      countries = country_codes$Code,
                      cognitive = "none")

# Pull PISA data into R
df_2012 <- getData(PISA_2012,
                   varnames = c("cnt", "schoolid", "stratum", varnames_2012, weights),
                   returnJKreplicates = TRUE)


# recode data to align with Twenge et al.
df_2012 <- data.frame(rbindlist(df_2012))
df_2012$st87q01 <- reverse_var(df_2012$st87q01)
df_2012$st87q04 <- reverse_var(df_2012$st87q04)
df_2012$st87q06 <- reverse_var(df_2012$st87q06)
df_2012[,varnames_2012] <- sapply(df_2012[varnames_2012], as.numeric, simplify = TRUE)
df_2012$loneliness <- apply(df_2012[,varnames_2012], 1, mean)

# Put into survey design object and pull country aggregates for loneliness
svydesign_2012 <- svrepdesign(weights = ~w_fstuwt, 
                              repweights = "w_fstr[0-9]+",
                              type = "Fay", 
                              rho = .5, 
                              data = df_2012)

agg_2012 <- svyby(~loneliness, ~ cnt, design = svydesign_2012,
                  svymean, na.rm = TRUE, return.replicates = TRUE)
var_2012 <- svyby(~loneliness, ~ cnt, design = svydesign_2012,
                   svyvar, na.rm = TRUE, return.replicates = TRUE)
agg_2012$sd <- sqrt(var_2012$V1)
agg_2012$Year <- 2012



# PISA 2015
varnames_2015 <- c("st034q01ta", "st034q02ta", "st034q03ta", 
                   "st034q04ta", "st034q05ta", "st034q06ta")
smartphone_internet_2015 <- c("ic001q07ta", "ic006q01ta", "ic001q04ta") 


# Prepare PISA data
PISA_2015 <- readPISA("PISA/2015",
                      database = "INT",
                      countries = country_codes$Code,
                      cognitive = "none")

# Pull PISA data into R
df_2015 <- getData(PISA_2015,
                   varnames = c("cnt", "cntschid", "stratum", varnames_2015, weights_2015),
                   returnJKreplicates = TRUE)

# recode to align with Twenge et al.
df_2015 <- data.frame(rbindlist(df_2015))
df_2015$st034q01ta <- reverse_var(df_2015$st034q01ta)
df_2015$st034q04ta <- reverse_var(df_2015$st034q04ta)
df_2015$st034q06ta <- reverse_var(df_2015$st034q06ta)
df_2015[,varnames_2015] <- sapply(df_2015[varnames_2015], as.numeric, simplify = TRUE)
df_2015$loneliness <- apply(df_2015[,varnames_2015], 1, mean)

# put into survey design object and pull country aggregates for loneliness
svydesign_2015 <- svrepdesign(weights = ~w_fstuwt, 
                              repweights = "w_fsturwt[0-9]+",
                              type = "Fay", 
                              rho = .5, 
                              data = df_2015)

agg_2015 <- svyby(~loneliness, ~ cnt, design = svydesign_2015,
                  svymean, na.rm = TRUE, return.replicates = TRUE)
var_2015 <- svyby(~loneliness, ~ cnt, design = svydesign_2015,
                  svyvar, na.rm = TRUE, return.replicates = TRUE)
agg_2015$sd <- sqrt(var_2015$V1)
agg_2015$Year <- 2015




# PISA 2018
varnames_2018 <- c("st034q01ta", "st034q02ta", "st034q03ta", 
                   "st034q04ta", "st034q05ta", "st034q06ta")
smartphone_internet_2018 <- c("ic001q07ta", "ic006q01ta", "ic001q04ta") 

# Prep PISA data
PISA_2018 <- readPISA("PISA/2018",
                      database = "INT",
                      countries = country_codes$Code,
                      cognitive = "none")

# Pull PISA data into R
df_2018 <- getData(PISA_2018,
                   varnames = c("cnt", "cntschid", "stratum", varnames_2018, weights_2015),
                   returnJKreplicates = TRUE)

# recode data to align with Twenge et al.
df_2018 <- data.frame(rbindlist(df_2018))
df_2018$st034q01ta <- reverse_var(df_2018$st034q01ta)
df_2018$st034q04ta <- reverse_var(df_2018$st034q04ta)
df_2018$st034q06ta <- reverse_var(df_2018$st034q06ta)
df_2018[,varnames_2018] <- sapply(df_2018[varnames_2018], as.numeric, simplify = TRUE)
df_2018$loneliness <- apply(df_2018[,varnames_2018], 1, mean)

# Convert to svydesign object and pull country aggregates
svydesign_2018 <- svrepdesign(weights = ~w_fstuwt, 
                              repweights = "w_fsturwt[0-9]+",
                              type = "Fay", 
                              rho = .5, 
                              data = df_2018)

agg_2018 <- svyby(~loneliness, ~ cnt, design = svydesign_2018,
                  svymean, na.rm = TRUE, return.replicates = TRUE)
var_2018 <- svyby(~loneliness, ~ cnt, design = svydesign_2018,
                  svyvar, na.rm = TRUE, return.replicates = TRUE)
agg_2018$sd <- sqrt(var_2018$V1)
agg_2018$Year <- 2018





#### Combine aggregate results for 2012, 2015, and 2018 ####
agg_all <- rbind(agg_2012, agg_2015, agg_2018)
agg_all$cnt <- toupper(agg_all$cnt)
agg_all$cnt[agg_all$cnt == "HONG KONG-CHINA"] <- "HONG KONG"
agg_all$cnt[agg_all$cnt == "CZECH REPUBLIC"] <- "CZECHIA"
agg_all$cnt[agg_all$cnt == "UNITED STATES"] <- "UNITED STATES OF AMERICA"
agg_all$cnt[agg_all$cnt == "UNITED KINGDOM"] <- "UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND"
agg_all$cnt[agg_all$cnt == "KOREA"] <- "KOREA, REPUBLIC OF"



agg_all <- left_join(agg_all, country_codes[,c("Country", "Code")], by = c("cnt" = "Country"))

agg_all$Code_Year <- paste(agg_all$Code, agg_all$Year, sep = "-") # needed for join later





#### Load smartphone and internet data for 2012, 2015, 2018 ####
# See above for reason
#
#
#
################################################################


# 2012
smartphone_internet_2012 <- c("ic01q07", "ic06q01", "ic01q04")

sm_2012 <- getData(PISA_2012,
                   varnames = c("cnt", "schoolid", "stratum", 
                                smartphone_internet_2012, weights),
                   returnJKreplicates = TRUE)

# Recode to align with Twenge et al.
sm_2012 <- data.frame(rbindlist(sm_2012))
sm_2012$Smartphone <- ifelse(sm_2012$ic01q07 == "Yes, and I use it", 1, 0)
sm_2012$InternetConnection <- ifelse(sm_2012$ic01q07 == "Yes, and I use it", 1, 0)
sm_2012$Internet <- recode_internet_2012(sm_2012$ic06q01)


# convert to svydesign object and pull country aggregates
svydesign_sm_2012 <- svrepdesign(weights = ~w_fstuwt, 
                                 repweights = "w_fstr[0-9]+",
                                 type = "Fay", 
                                 rho = .5, 
                                 data = sm_2012)

agg_sm_2012 <- svyby(~Smartphone + Internet, ~ cnt, 
                     design = svydesign_sm_2012,
                     svymean, na.rm = TRUE, return.replicates = TRUE)
agg_sm_2012$year <- 2012




# 2015
smartphone_internet_2015 <- c("ic001q07ta", "ic006q01ta", "ic001q04ta") 

# Pull PISA data into R
sm_2015 <- getData(PISA_2015,
                   varnames = c("cnt", "cntschid", "stratum", 
                                smartphone_internet_2015, weights_2015),
                   returnJKreplicates = TRUE)

# recode to align with Twenge et al.
sm_2015 <- data.frame(rbindlist(sm_2015))
sm_2015$Smartphone <- ifelse(sm_2015$ic001q07ta == "YES, AND I USE IT", 1, 0)
sm_2015$Internet <- recode_internet_2015_2018(sm_2015$ic006q01ta)

# Convert to svydesign object and pull country aggregates
svydesign_sm_2015 <- svrepdesign(weights = ~w_fstuwt, 
                                 repweights = "w_fsturwt[0-9]+",
                                 type = "Fay", 
                                 rho = .5, 
                                 data = sm_2015)

agg_sm_2015 <- svyby(~Smartphone + Internet, ~ cnt, 
                     design = svydesign_sm_2015,
                     svymean, na.rm = TRUE, return.replicates = TRUE)
agg_sm_2015$year <- 2015



# 2018
smartphone_internet_2018 <- c("ic001q07ta", "ic006q01ta", "ic001q04ta") 

# Read data into R
sm_2018 <- getData(PISA_2018,
                   varnames = c("cnt", "cntschid", "stratum", 
                                smartphone_internet_2018, weights_2015),
                   returnJKreplicates = TRUE)

# recode to align with Twenge et al.
sm_2018 <- data.frame(rbindlist(sm_2018))
sm_2018$Smartphone <- ifelse(sm_2018$ic001q07ta == "YES, AND I USE IT", 1, 0)
sm_2018$Internet <- recode_internet_2015_2018(sm_2018$ic006q01ta)

# Convert to svy design object and pull country aggregates
svydesign_sm_2018 <- svrepdesign(weights = ~w_fstuwt, 
                                 repweights = "w_fsturwt[0-9]+",
                                 type = "Fay", 
                                 rho = .5, 
                                 data = sm_2018)

agg_sm_2018 <- svyby(~Smartphone + Internet, ~ cnt, 
                     design = svydesign_sm_2018,
                     svymean, na.rm = TRUE, 
                     return.replicates = TRUE)
agg_sm_2018$year <- 2018


# Combine smartphone and internet data together
agg_sm <- rbind(agg_sm_2012, 
                agg_sm_2015,
                agg_sm_2018)
agg_sm$cnt <- toupper(agg_sm$cnt)
agg_sm$cnt[agg_sm$cnt == "HONG KONG-CHINA"] <- "HONG KONG"
agg_sm$cnt[agg_sm$cnt == "CZECH REPUBLIC"] <- "CZECHIA"
agg_sm$cnt[agg_sm$cnt == "UNITED STATES"] <- "UNITED STATES OF AMERICA"
agg_sm$cnt[agg_sm$cnt == "UNITED KINGDOM"] <- "UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND"
agg_sm$cnt[agg_sm$cnt == "KOREA"] <- "KOREA, REPUBLIC OF"

agg_sm <- left_join(agg_sm, country_codes[,c("Country", "Code")], by = c("cnt" = "Country"))

agg_sm$Code_Year <- paste(agg_sm$Code, agg_sm$year, sep = "-") # needed for join






#### Load World Bank data ####
# With WDI package, it's easy to pull data into a dataframe
# Note, I think Twenge et al. use gross GDP, rather than GDP per capita
# This does affect the results
#
############################3
indicators <- c("SL.UEM.TOTL.ZS", 
                "NY.GDP.MKTP.CD", # Gross GDP
                "NY.GDP.PCAP.CD", # Per capita GDP
                "SI.POV.GINI")

inds <- WDI(country = country_codes$Code_WDI,
            indicator = indicators,
            start = 2012,
            end = 2018)

fertility_rate <- WDI(country = country_codes$Code_WDI,
                      indicator = "SP.DYN.TFRT.IN",
                      start = 2012 - 15,
                      end = 2018 - 15)

# Subset data and join with country codes
inds <- inds[inds$year %in% c(2012, 2015, 2018),]
inds <- left_join(inds, country_codes[, c("Code", "Code_WDI")], by = c("iso2c" = "Code_WDI"))


fertility_rate <- fertility_rate[fertility_rate$year %in% c(1997, 2000, 2003),]
fertility_rate$year <- fertility_rate$year + 15
fertility_rate <- left_join(fertility_rate, 
                            country_codes[, c("Code", "Code_WDI")], by = c("iso2c" = "Code_WDI"))


inds$Code_Year <- paste(inds$Code, inds$year, sep = "-")
fertility_rate$Code_Year <- paste(fertility_rate$Code, fertility_rate$year, sep = "-")




#### join datasets ####
df <- left_join(agg_sm, inds[, c(indicators, "Code_Year")], by = "Code_Year")
df <- left_join(df, fertility_rate[, c("SP.DYN.TFRT.IN", "Code_Year")], by = "Code_Year")
df <- left_join(df, agg_all[, c("loneliness", "se", "Code_Year")], by = "Code_Year")

# drop NAs
df <- df[complete.cases(df),]

# remove single observations
all_years <- df %>% 
  group_by(cnt) %>% 
  summarize(n = n())
df <- df[df$cnt %in% all_years$cnt[all_years$n > 1],]

# recode year with 2012 as 0
df$year <- df$year - 2012




# Turn smartphone values into %
df$Smartphone <- df$Smartphone * 100
df$se <- df$se * 100


# recode to apply group-mean centering
df <- df %>%
  group_by(cnt) %>%
  mutate(Smartphone_mean = mean(Smartphone),
         Internet_mean = mean(Internet),
         SL.UEM.TOTL.ZS_mean = mean(SL.UEM.TOTL.ZS),
         NY.GDP.MKTP.CD_mean = mean(log(NY.GDP.MKTP.CD)),
         NY.GDP.PCAP.CD_mean = mean(log(NY.GDP.PCAP.CD)),
         SI.POV.GINI_mean = mean(SI.POV.GINI),
         SP.DYN.TFRT.IN_mean = mean(SP.DYN.TFRT.IN),
         Smartphone_cwc = Smartphone - Smartphone_mean,
         Internet_cwc = Internet - Internet_mean,
         SL.UEM.TOTL.ZS_cwc = SL.UEM.TOTL.ZS - SL.UEM.TOTL.ZS_mean,
         NY.GDP.MKTP.CD_cwc = log(NY.GDP.MKTP.CD) - NY.GDP.MKTP.CD_mean,
         NY.GDP.PCAP.CD_cwc = log(NY.GDP.PCAP.CD) - NY.GDP.PCAP.CD_mean,
         SI.POV.GINI_cwc = SI.POV.GINI - SI.POV.GINI_mean,
         SP.DYN.TFRT.IN_cwc = SP.DYN.TFRT.IN - SP.DYN.TFRT.IN_mean) %>%
  ungroup() %>% 
  mutate(Smartphone_mean = Smartphone_mean - mean(Smartphone_mean),
         Internet_mean = Internet_mean - mean(Internet_mean),
         SL.UEM.TOTL.ZS_mean = SL.UEM.TOTL.ZS_mean - mean(SL.UEM.TOTL.ZS_mean),
         NY.GDP.MKTP.CD_mean = NY.GDP.MKTP.CD_mean - mean(NY.GDP.MKTP.CD_mean),
         NY.GDP.PCAP.CD_mean = NY.GDP.PCAP.CD_mean - mean(NY.GDP.PCAP.CD_mean),
         SI.POV.GINI_mean = SI.POV.GINI_mean - mean(SI.POV.GINI_mean),
         SP.DYN.TFRT.IN_mean = SP.DYN.TFRT.IN_mean - mean(SP.DYN.TFRT.IN_mean))




# apply grand mean centering
df <- df %>%
  mutate(Smartphone_grandmean = mean(Smartphone),
         Internet_grandmean = mean(Internet),
         SL.UEM.TOTL.ZS_grandmean = mean(SL.UEM.TOTL.ZS),
         NY.GDP.MKTP.CD_grandmean = mean(log(NY.GDP.MKTP.CD)),
         NY.GDP.PCAP.CD_grandmean = mean(log(NY.GDP.PCAP.CD)),
         SI.POV.GINI_grandmean = mean(SI.POV.GINI),
         SP.DYN.TFRT.IN_grandmean = mean(SP.DYN.TFRT.IN),
         Smartphone_gmc = Smartphone - Smartphone_grandmean,
         Internet_gmc = Internet - Internet_grandmean,
         SL.UEM.TOTL.ZS_gmc = SL.UEM.TOTL.ZS - SL.UEM.TOTL.ZS_grandmean,
         NY.GDP.MKTP.CD_gmc = log(NY.GDP.MKTP.CD) - NY.GDP.MKTP.CD_grandmean,
         NY.GDP.PCAP.CD_gmc = log(NY.GDP.PCAP.CD) - NY.GDP.PCAP.CD_grandmean,
         SI.POV.GINI_gmc = SI.POV.GINI - SI.POV.GINI_grandmean,
         SP.DYN.TFRT.IN_gmc = SP.DYN.TFRT.IN - SP.DYN.TFRT.IN_grandmean) %>%
  ungroup() %>%
  mutate(Smartphone_grandmean = Smartphone_grandmean - mean(Smartphone_grandmean),
         Internet_grandmean = Internet_grandmean - mean(Internet_grandmean),
         SL.UEM.TOTL.ZS_grandmean = SL.UEM.TOTL.ZS_grandmean - mean(SL.UEM.TOTL.ZS_grandmean),
         NY.GDP.MKTP.CD_grandmean = NY.GDP.MKTP.CD_grandmean - mean(NY.GDP.MKTP.CD_grandmean),
         NY.GDP.PCAP.CD_grandmean = NY.GDP.PCAP.CD_grandmean - mean(NY.GDP.PCAP.CD_grandmean),
         SI.POV.GINI_grandmean = SI.POV.GINI_grandmean - mean(SI.POV.GINI_grandmean),
         SP.DYN.TFRT.IN_grandmean = SP.DYN.TFRT.IN_grandmean - mean(SP.DYN.TFRT.IN_grandmean))

# apply baseline centering
df <- df %>%
  group_by(cnt) %>%
  mutate(Smartphone_2012 = dplyr::first(Smartphone, order_by = year),
         Internet_2012 = dplyr::first(Internet, order_by = year),
         SL.UEM.TOTL.ZS_2012 = dplyr::first(SL.UEM.TOTL.ZS, order_by = year),
         NY.GDP.MKTP.CD_2012 = dplyr::first(log(NY.GDP.MKTP.CD), order_by = year),
         NY.GDP.MKTP.CD_2012_unlogged = dplyr::first(NY.GDP.MKTP.CD, order_by = year) / 1e10,
         NY.GDP.PCAP.CD_2012 = dplyr::first(log(NY.GDP.PCAP.CD), order_by = year),
         SI.POV.GINI_2012 = dplyr::first(SI.POV.GINI, order_by = year),
         SP.DYN.TFRT.IN_2012 = dplyr::first(SP.DYN.TFRT.IN, order_by = year),
         Smartphone_tc = Smartphone - Smartphone_2012,
         Internet_tc = Internet - Internet_2012,
         SL.UEM.TOTL.ZS_tc = SL.UEM.TOTL.ZS - SL.UEM.TOTL.ZS_2012,
         NY.GDP.MKTP.CD_tc = log(NY.GDP.MKTP.CD) - NY.GDP.MKTP.CD_2012,
         NY.GDP.MKTP.CD_tc_unlogged = (NY.GDP.MKTP.CD / 1e10) - NY.GDP.MKTP.CD_2012_unlogged,
         NY.GDP.PCAP.CD_tc = log(NY.GDP.PCAP.CD) - NY.GDP.PCAP.CD_2012,
         SI.POV.GINI_tc = SI.POV.GINI - SI.POV.GINI_2012,
         SP.DYN.TFRT.IN_tc = SP.DYN.TFRT.IN - SP.DYN.TFRT.IN_2012) %>%
  ungroup() %>%
  mutate(Smartphone_2012 = Smartphone_2012 - mean(Smartphone_2012),
         Internet_2012 = Internet_2012 - mean(Internet_2012),
         SL.UEM.TOTL.ZS_2012 = SL.UEM.TOTL.ZS_2012 - mean(SL.UEM.TOTL.ZS_2012),
         NY.GDP.MKTP.CD_2012 = NY.GDP.MKTP.CD_2012 - mean(NY.GDP.MKTP.CD_2012),
         NY.GDP.MKTP.CD_2012_unlogged = NY.GDP.MKTP.CD_2012_unlogged - mean(NY.GDP.MKTP.CD_2012_unlogged),
         NY.GDP.PCAP.CD_2012 = NY.GDP.PCAP.CD_2012 - mean(NY.GDP.PCAP.CD_2012),
         SI.POV.GINI_2012 = SI.POV.GINI_2012 - mean(SI.POV.GINI_2012),
         SP.DYN.TFRT.IN_2012 = SP.DYN.TFRT.IN_2012 - mean(SP.DYN.TFRT.IN_2012))



#### Run models #####
# This section starts with the models run by Twenge et al
# While my results aren't exactly the same, they are close enough
# I suspect the difference is because I have a few more 
# observations than they do and more countries. Nonetheless, it is qualitatively similar
#
####################


# Let's start with TWFE 
mod_sp_lm <- lm(loneliness ~ 1 + Smartphone + 
               as.factor(year) +
               SL.UEM.TOTL.ZS +
               I(NY.GDP.MKTP.CD / 1e9) +
               SI.POV.GINI + 
               SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_sp_lm, vcov = vcovHC(mod_sp_lm, "HC1")) # p = 0.06. Coef negative

mod_sp_lm2 <- lm(loneliness ~ 1 + Smartphone + 
                   as.factor(year) +
                   SL.UEM.TOTL.ZS +
                   log(NY.GDP.PCAP.CD) +
                   SI.POV.GINI + 
                   SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_sp_lm2, vcov = vcovHC(mod_sp_lm2, "HC1")) # p = 0.048. Coef negative

mod_sp_lm3 <- lm(loneliness ~ 1 + Smartphone + 
                  year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.MKTP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_sp_lm3, vcov = vcovHC(mod_sp_lm, "HC1")) # p = 0.045. Coef negative

mod_sp_lm4 <- lm(loneliness ~ 1 + Smartphone + 
                   year +
                   SL.UEM.TOTL.ZS +
                   I(NY.GDP.MKTP.CD / 1e9) +
                   SI.POV.GINI + 
                   SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_sp_lm4, vcov = vcovHC(mod_sp_lm, "HC1")) # p = 0.1. Coef negative


mod_int_lm <- lm(loneliness ~ 1 + Smartphone + 
               as.factor(year) +
               SL.UEM.TOTL.ZS +
                I(NY.GDP.MKTP.CD / 1e9) +
               SI.POV.GINI + 
               SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_int_lm, vcov = vcovHC(mod_lm, "HC1"))

mod_int_lm2 <- lm(loneliness ~ 1 + Internet + 
                   as.factor(year) +
                   SL.UEM.TOTL.ZS +
                   log(NY.GDP.PCAP.CD) +
                   SI.POV.GINI + 
                   SP.DYN.TFRT.IN + cnt, data = df)
coeftest(mod_int_lm2, vcov = vcovHC(mod_lm, "HC1"))



# Versions of Twenge et al. models
mod_sp <- lmer(loneliness ~ 1 + Smartphone + 
                 year +
                 SL.UEM.TOTL.ZS +
                 I(NY.GDP.MKTP.CD / 1e9) +
                 SI.POV.GINI + 
                 SP.DYN.TFRT.IN + 
                 (1 + year | cnt),
               data = df)
summary(mod_sp)
plot(mod_sp)

mod_sp2 <- lmer(loneliness ~ 1 + Smartphone +
                  year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.MKTP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                 (1 + year | cnt),
               data = df)
summary(mod_sp2)
plot(mod_sp2)

mod_sp3 <- lmer(loneliness ~ 1 + Smartphone + 
                 year +
                 SL.UEM.TOTL.ZS +
                 log(NY.GDP.PCAP.CD) +
                 SI.POV.GINI + 
                 SP.DYN.TFRT.IN + 
                 (1 + year | cnt),
               data = df)
summary(mod_sp3)
plot(mod_sp3)

mod_sp4 <- lmer(loneliness ~ 1 + Smartphone*year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.PCAP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                  (1 + year | cnt),
                data = df)
summary(mod_sp4)
plot(mod_sp4)



mod_int <- lmer(loneliness ~ 1 + Internet + 
                 year +
                 SL.UEM.TOTL.ZS +
                 I(NY.GDP.MKTP.CD / 1e9) +
                 SI.POV.GINI + 
                 SP.DYN.TFRT.IN + 
                 (1 + year | cnt),
               data = df)
summary(mod_int)
plot(mod_int)

mod_int2 <- lmer(loneliness ~ 1 + Internet*year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.MKTP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                  (1 + year | cnt),
                data = df)
summary(mod_int2)
plot(mod_int2)

mod_int3 <- lmer(loneliness ~ 1 + Internet + 
                  year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.PCAP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                  (1 + year | cnt),
                data = df)
summary(mod_int3)
plot(mod_int3)

mod_int4 <- lmer(loneliness ~ 1 + Internet*year +
                  SL.UEM.TOTL.ZS +
                  log(NY.GDP.PCAP.CD) +
                  SI.POV.GINI + 
                  SP.DYN.TFRT.IN + 
                  (1 + year | cnt),
                data = df)
summary(mod_int4)
plot(mod_int4)


mod_sp_int <- lmer(loneliness ~ 1 + Smartphone +
                     Internet +
                     year +
                     SL.UEM.TOTL.ZS +
                     I(NY.GDP.MKTP.CD / 1e9) +
                     SI.POV.GINI + 
                     SP.DYN.TFRT.IN + 
                     (1 + year | cnt),
                   data = df)
summary(mod_sp_int)


# Group-mean centered
mod_sp_cwc <- lmer(loneliness ~ 1 + Smartphone_cwc  + 
                     year +
                     SL.UEM.TOTL.ZS_cwc +
                     NY.GDP.MKTP.CD_cwc +
                     SI.POV.GINI_cwc + 
                     SP.DYN.TFRT.IN_cwc + 
                     Smartphone_mean  +
                     SL.UEM.TOTL.ZS_mean +
                     NY.GDP.MKTP.CD_mean +
                     SI.POV.GINI_mean + 
                     SP.DYN.TFRT.IN_mean + 
                     (1 + year | cnt),
            data = df)
summary(mod_sp_cwc)

mod_int_cwc <- lmer(loneliness ~ 1 + Internet_cwc + 
                      year +
                      SL.UEM.TOTL.ZS_cwc +
                      NY.GDP.MKTP.CD_cwc +
                      SI.POV.GINI_cwc + 
                      SP.DYN.TFRT.IN_cwc + 
                      Internet_mean  +
                      SL.UEM.TOTL.ZS_mean +
                      NY.GDP.MKTP.CD_mean +
                      SI.POV.GINI_mean + 
                      SP.DYN.TFRT.IN_mean + 
                      (1 + year | cnt),
            data = df)
summary(mod_int_cwc)

mod_sp_cwc2 <- lmer(loneliness ~ 1 + Smartphone_cwc  + 
                     year +
                     SL.UEM.TOTL.ZS_cwc +
                     NY.GDP.PCAP.CD_cwc +
                     SI.POV.GINI_cwc + 
                     SP.DYN.TFRT.IN_cwc + 
                     Smartphone_mean  +
                     SL.UEM.TOTL.ZS_mean +
                     NY.GDP.PCAP.CD_mean +
                     SI.POV.GINI_mean + 
                     SP.DYN.TFRT.IN_mean + 
                     (1 + year | cnt),
                   data = df)
summary(mod_sp_cwc2)



mod_int_tc <- lme4::lmer(loneliness ~ 1 + Internet_tc + 
                      year +
                      SL.UEM.TOTL.ZS_tc +
                      NY.GDP.MKTP.CD_tc +
                      SI.POV.GINI_tc + 
                      SP.DYN.TFRT.IN_tc + 
                      Internet_2012  +
                      SL.UEM.TOTL.ZS_2012 +
                      NY.GDP.MKTP.CD_2012 +
                      SI.POV.GINI_2012 + 
                      SP.DYN.TFRT.IN_2012 + 
                      (1 + year | cnt),
                    data = df)
summary(mod_int_tc)

mod_int_tc2 <- lmer(loneliness ~ 1 + Internet_tc + 
                     year +
                     SL.UEM.TOTL.ZS_tc +
                     NY.GDP.PCAP.CD_tc +
                     SI.POV.GINI_tc + 
                     SP.DYN.TFRT.IN_tc + 
                     Internet_2012  +
                     SL.UEM.TOTL.ZS_2012 +
                     NY.GDP.PCAP.CD_2012 +
                     SI.POV.GINI_2012 + 
                     SP.DYN.TFRT.IN_2012 + 
                     (1 + year | cnt),
                   data = df)
summary(mod_int_tc2)


# baseline centered (2012 or 2015, as some countries are missing observations)
mod_sp_tc <- lmer(loneliness ~ 1 + Smartphone_tc + 
                     year +
                     SL.UEM.TOTL.ZS_tc +
                     NY.GDP.MKTP.CD_tc +
                     SI.POV.GINI_tc + 
                     SP.DYN.TFRT.IN_tc + 
                     Smartphone_2012  +
                     SL.UEM.TOTL.ZS_2012 +
                     NY.GDP.MKTP.CD_2012 +
                     SI.POV.GINI_2012 + 
                     SP.DYN.TFRT.IN_2012 + 
                     (1 + year | cnt),
                   data = df)
summary(mod_sp_tc)

mod_sp_tc2 <- lmer(loneliness ~ 1 + Smartphone_tc + 
                    year +
                    SL.UEM.TOTL.ZS_tc +
                    NY.GDP.PCAP.CD_tc +
                    SI.POV.GINI_tc + 
                    SP.DYN.TFRT.IN_tc + 
                    Smartphone_2012  +
                    SL.UEM.TOTL.ZS_2012 +
                    NY.GDP.PCAP.CD_2012 +
                    SI.POV.GINI_2012 + 
                    SP.DYN.TFRT.IN_2012 + 
                    (1 + year | cnt),
                  data = df)
summary(mod_sp_tc2)

mod_sp_tc3 <- lmer(loneliness ~ 1 + Smartphone_tc + 
                     Internet_tc +
                     year +
                     SL.UEM.TOTL.ZS_tc +
                     NY.GDP.PCAP.CD_tc +
                     SI.POV.GINI_tc + 
                     SP.DYN.TFRT.IN_tc + 
                     Smartphone_2012  +
                     Internet_2012 +
                     SL.UEM.TOTL.ZS_2012 +
                     NY.GDP.PCAP.CD_2012 +
                     SI.POV.GINI_2012 + 
                     SP.DYN.TFRT.IN_2012 + 
                     (1 + year | cnt),
                   data = df)
summary(mod_sp_tc3)



mod_int_tc <- lmer(loneliness ~ 1 + Internet_tc + 
                       year +
                       SL.UEM.TOTL.ZS_tc +
                       NY.GDP.MKTP.CD_tc +
                       SI.POV.GINI_tc + 
                       SP.DYN.TFRT.IN_tc + 
                       Internet_2012  +
                       SL.UEM.TOTL.ZS_2012 +
                       NY.GDP.MKTP.CD_2012 +
                       SI.POV.GINI_2012 + 
                       SP.DYN.TFRT.IN_2012 + 
                       (1 + year | cnt),
                     data = df)
summary(mod_int_tc)



mod_sp_tc_PCAP <- lmer(loneliness ~ 1 + Smartphone_tc + 
                    year +
                    SL.UEM.TOTL.ZS_tc +
                    NY.GDP.PCAP.CD_tc +
                    SI.POV.GINI_tc + 
                    SP.DYN.TFRT.IN_tc + 
                    Smartphone_2012  +
                    SL.UEM.TOTL.ZS_2012 +
                    NY.GDP.PCAP.CD_2012 +
                    SI.POV.GINI_2012 + 
                    SP.DYN.TFRT.IN_2012 + 
                    (1 + year | cnt),
                  data = df)
summary(mod_sp_tc_PCAP)

mod_int_tc_PCAP <- lmer(loneliness ~ 1 + Internet_tc + 
                         year +
                         SL.UEM.TOTL.ZS_tc +
                         NY.GDP.PCAP.CD_tc +
                         SI.POV.GINI_tc + 
                         SP.DYN.TFRT.IN_tc + 
                         Internet_2012  +
                         SL.UEM.TOTL.ZS_2012 +
                         NY.GDP.PCAP.CD_2012 +
                         SI.POV.GINI_2012 + 
                         SP.DYN.TFRT.IN_2012 + 
                         (1 + year | cnt),
                       data = df)
summary(mod_int_tc_PCAP)





##### Make plots ####
plot_smartphone <- ggplot(df[df$cnt %in% c("POLAND", "CZECHIA", "SWEDEN"),]) +
  geom_line(mapping = aes(x = as.factor(year),
                          y = Smartphone,
                          group = cnt,
                          colour = cnt),
            size = 1.5) +
  labs(x = "Year",
       y = "Smartphone",
       title = "Illustrative example to illustrate smushed effects") +
  scale_colour_manual(values = Okabe_ito,
                      name = NULL) +
  scale_x_discrete(breaks = c("0", "3", "6"),
                   labels = c("2012", "2015", "2018")) +
  theme_blog

plot_smartphone
ggsave(filename = "example_smushed_effects.png", 
       plot = plot_smartphone,
       scale = 2.5,
       height = 500,
       width = 750,
       units = "px",
       bg = "white")



plot_smartphone_tc <- ggplot(df[df$cnt %in% c("POLAND", "CZECHIA", "SWEDEN"),]) +
  geom_line(mapping = aes(x = as.factor(year),
                          y = Smartphone_tc,
                          group = cnt,
                          colour = cnt),
            size = 1.5) +
  labs(x = "Year",
       y = "Smartphone",
       title = "Illustrative example to illustrate zero correlation") +
  scale_colour_manual(values = Okabe_ito,
                      name = NULL) +
  scale_x_discrete(breaks = c("0", "3", "6"),
                   labels = c("2012", "2015", "2018")) +
  theme_blog

plot_smartphone_tc
ggsave(filename = "example_smushed_effects_0_intercept.png", 
       plot = plot_smartphone_tc,
       scale = 2.5,
       height = 500,
       width = 750,
       units = "px",
       bg = "white")


