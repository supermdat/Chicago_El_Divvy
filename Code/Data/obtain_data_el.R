


## Code to programatically obtain Chicago subway ("El") data
## The data can be found here:  https://data.cityofchicago.org/Transportation/CTA-Ridership-L-Station-Entries-Daily-Totals/5neh-572f

## Install the required package
## install.packages("RSocrata")


## Load the used libraries

# Obtain the data
library("RSocrata")


## Locate the working directory
wd <- getwd()
wd


##  pull in the data
data_el_original <-
  read.socrata("https://data.cityofchicago.org/resource/mh5w-x5kh.json",,
               app_token = "j6U3Yraf4Yt8x0akYRXnJYgki",
               email     = "turse.mda@gmail.com",
               password  = "0Mfm&irGc@TPkn6"
               )

str(data_el_original)
summary(data_el_original)


## Save the original data to the proper folder
saveRDS(data_el_original,
        paste0(wd,
               "/Data/Raw/",
               "data_el_original.Rds"
               )
        )


## Remove data to free up memory
rm(wd, data_el_original)


