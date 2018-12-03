


## Code to munge the Divvy data (trips and stations) to make them more usable
## Including creating one large data.table from all of the individual datasets


## Load the used libraries

# Read Data
library("data.table")
library("readxl")

# Data Munging
library("tidyverse")
library("lubridate")


## Locate the working directory
wd <- getwd()
wd


## Get the list of the .csv and .xls(x) files
file_location <- paste0(wd,
                        "/Data/External/Divvy_Data/"
                        )

csv_names <-
  list.files(path = file_location,
             pattern = "\\.csv$",
             full.names = TRUE,
             recursive = TRUE
             )

xlsx_names <-
  list.files(path = file_location,
             pattern = "\\.xlsx{0,1}$",
             full.names = TRUE,
             recursive = TRUE
             )


#################
##             ##
##  Trip Data  ##
##             ##
#################

## Read the trip data into a single list file
## Note, trip data are only in .csv files
trips_names <-
  csv_names %>% 
  as.data.frame() %>% 
  rename(name = ".") %>% 
  mutate(trips = str_detect(string = name, pattern = "Trips_\\d{4}"),
         stations = str_detect(string = name, pattern = "Stations_\\d{4}")
         ) %>% 
  filter(trips == TRUE &
           stations == FALSE
         ) %>% 
  mutate_all(as.character) %>% 
  pull(name)

# user  system elapsed 
# 65.457   9.483  34.758
system.time(
  all_trips_list <-
    trips_names %>% 
    map(~ fread(.x,
                na.strings = c(""),
                stringsAsFactors = FALSE,
                showProgress = TRUE
                )
        )
  )


## Check if the column names are the same in all datasets
names <-
  all_trips_list %>% 
  map(~ colnames(.x) %>%
        as.data.frame()
      ) %>% 
  bind_cols()

summary(t(names))


## As the names are indeed different, standardize them here
names_uniform <-
  all_trips_list[[21]] %>% 
  colnames()

update_names <-
  pmap(.l = list(a = all_trips_list),
       .f = function(a) {
         data = a
         
         colnames(data) <- names_uniform
         
         return(data)
         }
       )

rm(all_trips_list)


## Confirm that the names are now standardized
names_check <-
  update_names %>% 
  map(~ colnames(.x) %>% 
        as.data.frame()
      ) %>% 
  bind_cols()

summary(t(names_check))


## Confirm the data types for start_time and end_time in each dataset
update_names %>% 
  map(~ select(.x,
               start_time,
               end_time
               )
      ) %>% 
  map(~ str(.x)
      )


##  As the formats are different, we need to do some munging on the date and time fields

# user  system elapsed 
# 68.799   5.454  77.745
system.time(
prepare_dates_for_formatting <-
  update_names %>% 
  map(~ separate(.x,
                 col = start_time,
                 into = c("start_date", "start_time"),
                 sep = " ",
                 remove = TRUE
                 )
      ) %>% 
  map(~ separate(.x,
                 col = end_time,
                 into = c("end_date", "end_time"),
                 sep = " ",
                 remove = TRUE
                 )
      ) %>% 
  map(~ mutate_at(.x,
                  vars(matches("time")
                  ),
                  str_pad,
                  width = 5,
                  side = "left",
                  pad = "0"
                  )
      ) %>% 
  map(~ mutate(.x,
               start_time = case_when(str_length(start_time) == 5 ~ paste0(start_time, ":00"),
                                      TRUE ~ start_time
                                      ),
               end_time = case_when(str_length(end_time) == 5 ~ paste0(end_time, ":00"),
                                    TRUE ~ end_time
                                    )
               )
      )
)

rm(update_names)


## Change dates from character to POSIXct
## This is done separetely for the first dataframe as it uses different date formatting

## year-month-day format
update_date_formats_first <-
  prepare_dates_for_formatting[[1]] %>% 
  mutate(start_dt = paste0(start_date, " ", start_time) %>% 
           ymd_hms(),
         end_dt = paste0(end_date, " ", end_time) %>% 
           ymd_hms()
         ) %>% 
  select(-start_date,
         -start_time,
         -end_date,
         -end_time
         )

## month/day/year format
update_date_formats_rest <-
  prepare_dates_for_formatting[2:21] %>% 
  map(~ mutate(.x,
               start_dt = paste0(start_date, " ", start_time) %>% 
                 mdy_hms(),
               end_dt = paste0(end_date, " ", end_time) %>% 
                 mdy_hms()
               )
      ) %>% 
  map(~ select(.x,
               -start_date,
               -start_time,
               -end_date,
               -end_time
               )
      )


## Put dataframes together into one large dataframe, convert characters to factors,
## and convert to a data.table for faster processing
data_divvy_trips <-
  bind_rows(update_date_formats_rest) %>% 
  bind_rows(update_date_formats_first) %>% 
  mutate_if(is.character, factor) %>% 
  as.data.table %>% 
  setkey(trip_id,
         start_dt
         )

str(data_divvy_trips)
summary(data_divvy_trips)


rm(prepare_dates_for_formatting,
   update_date_formats_first,
   update_date_formats_rest
   )


## Save the original data to the proper folder
saveRDS(data_divvy_trips,
        paste0(wd,
               "/Data/Processed/",
               "data_divvy_trips.Rds"
               )
        )

rm(data_divvy_trips)




####################
##                ##
##  Station Data  ##
##                ##
####################

## Read the station data into a single list file
## Note that station data are in both .csv files and .xlsx files

# get the csv names
station_csv <-
  csv_names %>% 
  as.data.frame() %>% 
  rename(name = ".") %>% 
  mutate(trips = str_detect(string = name, pattern = "Trips_\\d{4}"),
         stations = str_detect(string = name, pattern = "Stations_\\d{4}"),
         file_name = str_replace(string = name, pattern = ".*/", replacement = "")
         ) %>% 
  filter(stations == TRUE) %>% 
  mutate_all(as.character)

station_csv_names <-
  station_csv %>% 
  pull(file_name)

station_csv_full_path <-
  station_csv %>% 
  pull(name)


# get the xlsx names
station_xlsx_full_path <- xlsx_names


## Read in the data

# csv

# user  system elapsed 
# 0.044   0.049   0.115
system.time(
  all_stations_csv <-
    pmap(.l = list(a = station_csv_full_path),
         .f = function(a) {
           dat = fread(a,
                       na.strings = c(""),
                       stringsAsFactors = FALSE,
                       showProgress = TRUE
                       )
           
           return(dat)
           }
         )
  )

all_stations_csv %>% map(~ dim(.x))


## Update the names of the dataframes in the list to allow bind_rows to add this name to
## the full binded dataframe
names(all_stations_csv) <- station_csv_names
names(all_stations_csv)


# xlsx

# user  system elapsed 
# 0.021   0.017   0.047
system.time(
  all_stations_xlsx <-
    read_xlsx(path = station_xlsx_full_path)
  )

dim(all_stations_xlsx)


## Check if the column names are the same in all the .csv datasets
all_stations_csv %>% 
  map(~ colnames(.x)
      )


## Update column names and formats for proper binding into a single list of .csv files
all_stations_csv[[1]] <-
  all_stations_csv[[1]] %>% 
  rename(online_date = `online date`)

all_stations_csv[[2]] <-
  all_stations_csv[[2]] %>% 
  rename(online_date = dateCreated)

all_stations_csv[[3]]$online_date <- NA

all_stations_csv %>% 
  map(~ colnames(.x)
      )


## Format xlsx data data for binding with csv data
all_stations_xlsx <-
  all_stations_xlsx %>% 
  rename(online_date = `online date`) %>% 
  mutate(#online_date = as.character(online_date)
         online_date = ymd(online_date)
         )


## Update csv data for binding with xlsx data
all_stations_csv_formated <-
  all_stations_csv %>% 
  map(~ rename(.x,
               online_dt = online_date
               )
      ) %>% 
  map(~ separate(.x,
                 col = online_dt,
                 into = c("online_date", "online_time"),
                 sep = " ",
                 remove = FALSE
                 )
      ) %>% 
  map(~ mutate(.x,
               online_date = mdy(online_date)
               )
      ) %>% 
  map(~ select(.x,
               -online_dt,
               -online_time
               )
      ) %>% 
  bind_rows(.id = "file_og")

str(all_stations_csv_formated)

rm(all_stations_csv)


## Bind csv data and xlsx data and format file_og
divvy_data_stations <-
  bind_rows(all_stations_csv_formated,
            all_stations_xlsx
            ) %>% 
  mutate(file_og_yr =
           str_extract(string = file_og, pattern = "\\d{4}") %>% 
           as.integer(),
         file_og_yr_part =
           if_else(str_extract(string = file_og, pattern = "(?<=\\d{4}).*\\.csv$") == ".csv",
                   "Q1Q2Q3Q4",
                   str_extract(string = file_og, pattern = "(?<=\\d{4}).*\\.csv$") %>% 
                     str_replace(pattern = ".csv", replacement = "") %>% 
                     str_replace(pattern = "-|_", replacement = "")
                   ) %>% 
           factor(),
         file_og_start_date = case_when(str_sub(file_og_yr_part,
                                                start = 1,
                                                end = 2
                                                ) == "Q1" ~ paste0(file_og_yr,
                                                                   "-",
                                                                   "01-01"
                                                                   ),
                                        str_sub(file_og_yr_part,
                                                start = 1,
                                                end = 2
                                                ) == "Q2" ~ paste0(file_og_yr,
                                                                   "-",
                                                                   "04-01"
                                                                   ),
                                        str_sub(file_og_yr_part,
                                                start = 1,
                                                end = 2
                                                ) == "Q3" ~ paste0(file_og_yr,
                                                                   "-",
                                                                   "07-01"
                                                                   ),
                                        str_sub(file_og_yr_part,
                                                start = 1,
                                                end = 2
                                                ) == "Q4" ~ paste0(file_og_yr,
                                                                   "-",
                                                                   "10-01"
                                                                   ),
                                        is.na(file_og_yr_part) ~ as.character(NA)
                                        ),
         file_og_end_date = case_when(str_sub(file_og_yr_part,
                                              start = str_length(file_og_yr_part) - 1,
                                              end = str_length(file_og_yr_part)
                                              ) == "Q1" ~ paste0(file_og_yr,
                                                                 "-",
                                                                 "03-31"
                                                                 ),
                                      str_sub(file_og_yr_part,
                                              start = str_length(file_og_yr_part) - 1,
                                              end = str_length(file_og_yr_part)
                                              ) == "Q2" ~ paste0(file_og_yr,
                                                                 "-",
                                                                 "06-30"
                                                                 ),
                                      str_sub(file_og_yr_part,
                                              start = str_length(file_og_yr_part) - 1,
                                              end = str_length(file_og_yr_part)
                                              ) == "Q3" ~ paste0(file_og_yr,
                                                                 "-",
                                                                 "09-30"
                                                                 ),
                                      str_sub(file_og_yr_part,
                                              start = str_length(file_og_yr_part) - 1,
                                              end = str_length(file_og_yr_part)
                                              ) == "Q4" ~ paste0(file_og_yr,
                                                                 "-",
                                                                 "12-31"
                                                                 ),
                                      is.na(file_og_yr_part) ~ as.character(NA)
                                      )
         ) %>% 
  mutate_at(vars(file_og, name), factor) %>% 
  mutate_at(vars(file_og_start_date, file_og_end_date), ymd)


## Quick check of counts
divvy_data_stations %>% count(file_og)
divvy_data_stations %>% count(file_og_yr)
divvy_data_stations %>% count(file_og_yr_part)
divvy_data_stations %>% count(file_og_yr, file_og_yr_part)
divvy_data_stations %>% count(file_og_start_date)
divvy_data_stations %>% count(file_og_end_date)


## Only select needed varialbes
divvy_data_stations <-
  divvy_data_stations %>% 
  select(file_og,
         file_og_start_date,
         file_og_end_date,
         id,
         name,
         latitude,
         longitude,
         dpcapacity,
         landmark,
         online_date,
         city,
         V8
         ) %>% 
  as.data.table() %>% 
  setkey(id,
         file_og_start_date
         )

## Data inspections
str(divvy_data_stations)
summary(divvy_data_stations)

View(divvy_data_stations %>%
       arrange(id,
               desc(file_og_end_date)
               )
     )

View(divvy_data_stations %>% 
       select(id,
              # name,
              # latitude,
              # longitude,
              dpcapacity,
              file_og_start_date
              ) %>% 
       group_by(id,
                # name,
                # latitude,
                # longitude,
                dpcapacity
                ) %>% 
       summarise(max_start_date = max(file_og_start_date)
                 ) %>% 
       ungroup() %>% 
       arrange(id,
               max_start_date
               )
     )


## Save the original data to the proper folder
saveRDS(divvy_data_stations,
          paste0(wd,
                 "/Data/Processed/",
                 "divvy_data_stations.Rds"
          )
  )



## Remove data to free up memory
rm(list = ls())


