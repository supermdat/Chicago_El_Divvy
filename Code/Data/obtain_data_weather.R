


## Code to programatically obtain Chicago weather
## As I could not find a free API of historical data, the data were manually downloaded from:
## https://www.ncdc.noaa.gov/cdo-web/ as .csv files


## Load the used libraries

# Obtain the data
library("data.table")

# Munge the data
library("tidyverse")
library("magrittr")

## Locate the working directory
wd <- getwd()
wd


## Get file names
csv_names <-
  list.files(path = paste0(wd,
                           "/Data/Raw/"
                           ),
             pattern = "1445\\d{3}\\.csv$", # this is the pattern for the weather .csv files
             full.names = TRUE
             )


## Read in the data
weather_csv <-
  csv_names %>% 
  map(~ fread(.x,
              na.strings = c(""),
              stringsAsFactors = FALSE,
              showProgress = TRUE
              )
      )


data_weather <-
  bind_rows(weather_csv)

str(data_weather)
glimpse(data_weather)


## Save the original data to the proper folder
saveRDS(data_weather,
        paste0(wd,
               "/Data/Processed/",
               "data_weather.Rds"
               )
        )


## Remove data to free up memory
rm(list = ls())


