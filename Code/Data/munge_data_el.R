


## Code to take the Chicago subway ("El") data in its raw state and quickly update the
## variable formats for ease in processing/inspection/modeling.

## The original data can be found here:  https://data.cityofchicago.org/Transportation/CTA-Ridership-L-Station-Entries-Daily-Totals/5neh-572f


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
data_el_original <-
  readRDS(paste0(wd,
                 "/Data/Raw/",
                 "data_el_original.Rds"
                 )
          )


## update the data to more usable formats
str(data_el_original)

data_el_format_vars <-
  data_el_original %>% 
  mutate(date = ymd(date)
         ) %>% 
  mutate_at(vars(daytype, stationname), factor) %>% 
  mutate_at(vars(station_id, rides), as.numeric) %>% 
  as.data.table() %>% 
  setkey(date,
         station_id
         )

str(data_el_format_vars)
summary(data_el_format_vars)


## Save the formatted data to the proper folder
saveRDS(data_el_format_vars,
        paste0(wd,
               "/Data/Processed/",
               "data_el_format_vars.Rds"
               )
        )


