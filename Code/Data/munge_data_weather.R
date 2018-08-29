


## Code to take the Chicago weather data, inspect the data, drop unneeded variables,
## and update variable formats for ease in processing/inspection/modeling.

## As I could not find a free API of historical data, the original data were manually
## downloaded from:  https://www.ncdc.noaa.gov/cdo-web/ as .csv files

## Load the used libraries

# Data Munging
library("tidyverse")
library("magrittr")
library("lubridate")
library("data.table")
library("naniar")       # exploring missing data


## Locate the working directory
wd <- getwd()
wd


## Get the raw data saved as an .Rds dataset
data_weather <-
  readRDS(paste0(wd,
                 "/Data/Processed/",
                 "data_weather.Rds"
                 )
          )


## inspect data to determine what data are needed
class(data_weather)
glimpse(data_weather)

data_weather <-
  data_weather %>% 
  rename_all(tolower)

class(data_weather)
glimpse(data_weather)


data_weather %>% 
  count(station, name) %>% 
  arrange(desc(n)
          ) %>% 
  View()


## Limit to just data at Midway airport
## This won't be accurate for every location in Chicago, but should be sufficient for this
## purpose
midway <-
  data_weather %>% 
  filter(name == "CHICAGO MIDWAY AIRPORT 3 SW, IL US")

glimpse(midway)


## Exploring missing data & filter for data that has < 5pct of observations missing
midway_missing <-
  miss_var_summary(midway)

View(midway_missing)


rarely_missing_var_names <-
  midway_missing %>% 
  filter(pct_miss < 5) %>% 
  pull(variable)


midway_mostly_nonNA_vars <-
  midway %>% 
  select(rarely_missing_var_names)

str(midway_mostly_nonNA_vars)


## Remove variables that are descriptions/attributes
data_weather_format_vars <-
  midway_mostly_nonNA_vars %>% 
  select(-matches("attributes")
         ) %>% 
  mutate(date = ymd(date)
         ) %>% 
  as.data.table() %>% 
  setkey(date)


## Confirmat data are as desired
str(data_weather_format_vars)

data_weather_format_vars %>% 
  select(-station, -name) %>% 
  summary()


## Save the formatted data to the proper folder
saveRDS(data_weather_format_vars,
        paste0(wd,
               "/Data/Processed/",
               "data_weather_format_vars.Rds"
               )
        )


## Remove data to free up memory
rm(list = ls())


