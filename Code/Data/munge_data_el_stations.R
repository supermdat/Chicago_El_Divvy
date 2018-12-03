


## Code to take the Chicago subway ("El") stations data in its raw state and quickly update
## the variable formats for ease in processing/inspection/modeling.

## The original data can be found here:  https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops/8pix-ypme


## Load the used libraries

# Data Munging
library("tidyverse")
library("magrittr")
library("data.table")


## Locate the working directory
wd <- getwd()
wd


## Get the raw data saved as an .Rds dataset
data_el_stations_original <-
  readRDS(paste0(wd,
                 "/Data/Raw/",
                 "data_el_stations_original.Rds"
                 )
          )

str(data_el_stations_original %>% select(-location.coordinates))
str(data_el_stations_original %>% select(location.coordinates))


## Move lat and long from a list into their own separate columns
lat_lon_cols <-
  unnest(data_el_stations_original,
         .drop = FALSE,
         .id = "unnest_id"
         ) %>% 
  mutate(lon_lat = rep(c("lon", "lat"),
                       300
                       )
         ) %>% 
  spread(key = lon_lat,
         value = location.coordinates
         )
  
str(lat_lon_cols)
dim(lat_lon_cols)
dim(data_el_stations_original)

View(lat_lon_cols)


## Update variable formats
data_el_stations_format_vars <-
  lat_lon_cols %>% 
  mutate_at(vars(map_id,
                 stop_id
                 ),
            as.integer
            ) %>% 
  mutate_at(vars(direction_id,
                 location.type,
                 station_descriptive_name,
                 station_name
                 ),
            factor
            ) %>% 
  mutate_if(is.character, as.logical) %>% 
  as.data.table() %>% 
  setkey(stop_id)

str(data_el_stations_format_vars)
summary(data_el_stations_format_vars)


## Save the formatted data to the proper folder
saveRDS(data_el_stations_format_vars,
        paste0(wd,
               "/Data/Processed/",
               "data_el_stations_format_vars.Rds"
               )
        )


## Remove files to free up memory
rm(list = ls())



