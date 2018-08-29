


## Code to programatically obtain Chicago subway ("El") data on stations
## The data can be found here:  https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops/8pix-ypme

## Install the required package
## install.packages("RSocrata")


## Load the used libraries

# Obtain the data
library("RSocrata")


## Locate the working directory
wd <- getwd()
wd


##  pull in the data
data_el_stations_original <-
  read.socrata("https://data.cityofchicago.org/resource/8mj8-j3c4.json",,
               app_token = "j6U3Yraf4Yt8x0akYRXnJYgki",
               email     = "turse.mda@gmail.com",
               password  = "0Mfm&irGc@TPkn6"
               )

# str(data_el_stations_original)
# summary(data_el_stations_original)


## Save the original data to the proper folder
saveRDS(data_el_stations_original,
        paste0(wd,
               "/Data/Raw/",
               "data_el_stations_original.Rds"
               )
        )


## Remove data to free up memory
rm(wd, data_el_stations_original)


