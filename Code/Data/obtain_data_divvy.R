


## Code to programatically obtain Chicago bikeshare ("divvy") data
## The data can be found here:  https://www.divvybikes.com/system-data


## Load the used libraries

# Obtain the data
library("data.table")

# Data munging
library("tidyverse")
library("stringr")


## Set the working directory
wd <- getwd()
wd


## These are the urls themselves

# url example https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2014_Q1Q2.zip
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2013.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2014_Q1Q2.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2014_Q3Q4.zip"

######  !  notice the dash instead of the underscore after 2015  !  #####
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2015-Q1Q2.zip"

# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2015_Q3Q4.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2016_Q1Q2.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2016_Q3Q4.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2017_Q1Q2.zip"
# "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2017_Q3Q4.zip"


## Loop through to get the complete urls
years <- 2014:2017
quarters <- c("Q1Q2", "Q3Q4")

base_url_prefix2014 <- "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_"
base_url_prefix2015 <- "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_"
base_url_suffix <- ".zip"

url_list <- list()
for(year in years) {
  for(quarter in quarters) {
      name <- paste0("divvy_",
                     year,
                     quarter
                     )
      
      if(year == 2014) {
        url_list[[name]] <-
          paste0(base_url_prefix2014,
                 year,
                 "_",
                 quarter,
                 base_url_suffix
                 )
        } else {
          url_list[[name]] <-
            paste0(base_url_prefix2015,
                   year,
                   "_",
                   quarter,
                   base_url_suffix
            )
          }
      }
  }


# str(url_list) # to check the urls


## Manually add 2013 and 2015Q1Q2 url's as they are different than the general pattern
## https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2013.zip
url_list["divvy_2013Q3Q4"] <- "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Stations_Trips_2013.zip"
url_list["divvy_2015Q1Q2"] <- "https://s3.amazonaws.com/divvy-data/tripdata/Divvy_Trips_2015-Q1Q2.zip"

# str(url_list) # to check the urls


## Create folders to write the .csv and .xls(x) files to
new_folder_name <- "Divvy_Data"
external_divvy_data <- paste0(wd,
                              "/Data/External/",
                              new_folder_name
                              )

dir.create(external_divvy_data)


## Create a function to download the data to the proper folders
get_data_csv_xlsx <- function(url, folder_name) {
  f_url = url
  
  fldr_name = folder_name
  
  zip_file_raw =
    paste0(wd,
           "/Data/Raw/",
           fldr_name,
           ".zip"
           )
  
  # download the .zip file to the Raw folder
  download.file(url = f_url,
                destfile = zip_file_raw
                )
  
  # unzip the file to the Divvy_Data folder
  unzip(zipfile = zip_file_raw,
        overwrite = TRUE,
        exdir = paste0(external_divvy_data,
                       "/",
                       fldr_name
                       )
        )
  }


## Run the function for each url_list
pmap(.l = list(a = url_list,
               b = names(url_list)
               ),
     .f = function(a, b) {
       get_data_csv_xlsx(url = a, folder_name = b)
       }
     )


## Remove data to free up memory
rm(list = ls())


