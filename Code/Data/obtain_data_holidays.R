


## Code to programatically obtain Chicago holiday day. Data will be scraped from:
## https://www.officeholidays.com/countries/usa/regional.php?list_year=2017&list_region=Illinois


## Load the used libraries

# Web Scraping
library("rvest")


# Data Munging
library("tidyverse")
library("magrittr")


## Locate the working directory
wd <- getwd()
wd


## Prep to get URL's
url_prefix <- "https://www.officeholidays.com/countries/usa/regional.php?list_year="
url_suffix <- "&list_region=Illinois"
yr <- 2010:2018

url_list <-
  pmap(.l = list(a = yr),
       .f = function(a) {
         dat = paste0(url_prefix, a, url_suffix)
         
         return(dat)
         }
       )

names(url_list) <- yr


## Function to scrape holiday data
get_all_holiday_data <-
  function(url) {
    scrape_base =
      url %>%
      # url_list$`2015` %>% 
      read_html() %>% 
      html_nodes(css = "td")
    
    # holiday dates
    scrape_holiday_date =
      scrape_base %>% 
      html_text(trim = TRUE) %>% 
      str_extract(pattern = "\\d{4}-\\d{2}-\\d{2}") %>% 
      as.data.frame() %>% 
      rename(date = ".") %>% 
      filter(!is.na(date))
    
    # necessary to match the number of rows to the holiday dates
    match_date_index = 1:nrow(scrape_holiday_date)
    
    
    # holiday names
    scrape_holiday_name =
      scrape_base %>% 
      html_text(trim = TRUE)
    
    list_index_holiday <- seq(from = 3, to = length(scrape_holiday_name), by = 4)
    
    scrape_holiday_name =
      scrape_holiday_name[list_index_holiday]
    
    scrape_holiday_name =
      scrape_holiday_name[match_date_index] %>% 
      as.data.frame() %>% 
      rename(holiday_name = ".")
    
    
    # holiday comments
    scrape_holiday_comment =
      scrape_base %>% 
      html_text(trim = TRUE)
    
    list_index_comment <- seq(from = 4, to = length(scrape_holiday_comment), by = 4)
    
    scrape_holiday_comment =
      scrape_holiday_comment[list_index_comment]
    
    scrape_holiday_comment =
      scrape_holiday_comment[match_date_index] %>% 
      as.data.frame() %>% 
      rename(holiday_comment = ".")
    
    
    # put dataframes together
    data_holidays_df =
      bind_cols(scrape_holiday_date,
                scrape_holiday_name,
                scrape_holiday_comment
                ) %>% 
      mutate_all(as.character)
    }
  

## Run the function for each url
data_holidays <-
  url_list %>% 
  map(~ get_all_holiday_data(.x)
      )


## create a single
data_holidays_original <-
  bind_rows(data_holidays) %>% 
  arrange(date)

# str(data_holidays_original)
# View(data_holidays_original)


## Save the original data to the proper folder
saveRDS(data_holidays_original,
        paste0(wd,
               "/Data/Raw/",
               "data_holidays_original.Rds"
               )
        )


## Remove data to free up memory
rm(list = ls())


