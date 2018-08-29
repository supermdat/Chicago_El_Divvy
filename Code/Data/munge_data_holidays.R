


## Code to take the Chicago holiday data in its raw state and quickly update the
## variable formats for ease in processing/inspection/modeling.

## The original data can be found here (with the year changing):
## https://www.officeholidays.com/countries/usa/regional.php?list_year=2017&list_region=Illinois


## Load the used libraries

# Data Munging
library("tidyverse")
library("magrittr")
library("lubridate")
library("data.table")


## Locate the working directory
wd <- getwd()
wd


## Get the raw data saved as an .Rds dataset
data_holidays_original <-
  readRDS(paste0(wd,
                 "/Data/Raw/",
                 "data_holidays_original.Rds"
                 )
          )


## update the data to more usable formats
str(data_holidays_original)

data_holidays_format_vars <-
  data_holidays_original %>% 
  mutate(date = ymd(date)
         ) %>% 
  mutate_at(vars(holiday_name), factor) %>% 
  arrange(date) %>% 
  as.data.table() %>% 
  setkey(date)

str(data_holidays_format_vars)
summary(data_holidays_format_vars)


## Save the formatted data to the proper folder
saveRDS(data_holidays_format_vars,
        paste0(wd,
               "/Data/Processed/",
               "data_holidays_format_vars.Rds"
               )
        )


## Remove data to free up memory
rm(list = ls())


