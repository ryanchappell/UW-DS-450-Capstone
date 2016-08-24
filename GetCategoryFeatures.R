library(dplyr)

##Clear Workspace and Console
#rm(list=ls())
#cat("\014")

setwd('~/Data Science/Course 3/CapStone Project/Code/UW-DS-450-Capstone-master')
maxAppEventsToRead = 100000

events_csv = read.csv('data/events.csv', 
                      numerals = 'warn.loss',
                      nrows = maxAppEventsToRead,
                      # use character class as we would otherwise lose precision
                      # (using 'numeric') with the size of app_id values
                      colClasses = c(NA,'character', 'factor', 'factor'));

app_events_csv = read.csv('data/app_events.csv', 
                          numerals = 'warn.loss',
                          nrows = maxAppEventsToRead,
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of app_id values
                          colClasses = c(NA,'character', 'factor', 'factor'))


app_labels_csv = read.csv('data/app_labels.csv',
                          numerals = 'warn.loss',
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of app_id values
                          colClasses = c('character'))


label_categories_csv = read.csv('data/label_categories.csv',
                                numerals = 'warn.loss')


#classifying categories into few high level categories
for (x in 1:nrow(label_categories_csv)) {
  value <-  tolower(label_categories_csv[x,c('category')])
  label_categories_csv[x,c('new_cat_name')] = tolower(label_categories_csv[x,c('category')])
  label_categories_csv[x,c('new_cat_name')] = tolower(label_categories_csv[x,c('category')])
  
  if (length(grep('game',value))>0) label_categories_csv[x,c('is_game')] = 1 else label_categories_csv[x,c('is_game')] = 0
  if (length(grep('car ',value))>0) label_categories_csv[x,c('is_car')] = 1 else label_categories_csv[x,c('is_car')] = 0
  if (value == 'car')                label_categories_csv[x,c('is_car')] = 1
  if (length(grep('travel',value))>0) label_categories_csv[x,c('is_travel')] = 1 else label_categories_csv[x,c('is_travel')] = 0
  if (length(grep('property',value))>0) label_categories_csv[x,c('is_property')] = 1 else label_categories_csv[x,c('is_property')] = 0
  if (length(grep('industry',value))>0) label_categories_csv[x,c('is_industry')] = 1 else label_categories_csv[x,c('is_industry')] = 0
  if (length(grep('financ',value))>0) label_categories_csv[x,c('is_finance')] = 1 else label_categories_csv[x,c('is_finance')] = 0 #grep financ without e to account for categories with "financial ..." text
}


mergedData <- app_labels_csv
mergedData = merge(mergedData, label_categories_csv, by = "label_id")#, all.x = TRUE);
mergedData = merge(mergedData, app_events_csv, by = "app_id")#, all.x = TRUE)
mergedData = merge(mergedData, events_csv, by = "event_id")#, all.x = TRUE)

head(mergedData)



getPrimaryCategoriesCounts = function(data) {
  result_is_game = aggregate(x = as.integer(data$is_game), by = list(device_id = data$device_id),
                     FUN = function(x) {
                       return(sum(x))
                     })
  names(result_is_game) = c("device_id", "is_game_count") 
  
  result_is_travel = aggregate(x = as.integer(data$is_travel), by = list(device_id = data$device_id),
                     FUN = function(x) {
                       return(sum(x))
                     })
  names(result_is_travel) = c("device_id", "is_travel_count" )
  result_is_property = aggregate(x = as.integer(data$is_property), by = list(device_id = data$device_id),
                     FUN = function(x) {
                       return(sum(x))
                     })
  names(result_is_property) = c("device_id", "is_property_count" )
  
  result_is_industry = aggregate(x = as.integer(data$is_industry), by = list(device_id = data$device_id),
                     FUN = function(x) {
                       return(sum(x))
                     })
  names(result_is_industry) = c("device_id", "is_industry_count" )
  
  result_is_finance = aggregate(x = as.integer(data$is_finance), by = list(device_id = data$device_id),
                     FUN = function(x) {
                       return(sum(x))
                     })
  names(result_is_finance) = c("device_id", "is_finance_count" )
  
  mergedCategoryData <- result_is_game
  mergedCategoryData = merge(mergedCategoryData, result_is_travel, by = "device_id")#, all.x = TRUE);
  mergedCategoryData = merge(mergedCategoryData, result_is_property, by = "device_id")#, all.x = TRUE);
  mergedCategoryData = merge(mergedCategoryData, result_is_industry, by = "device_id")#, all.x = TRUE);
  mergedCategoryData = merge(mergedCategoryData, result_is_finance, by = "device_id")#, all.x = TRUE);
  return(mergedCategoryData)
}


device_data_Cat <- getPrimaryCategoriesCounts(mergedData)
head(device_data_Cat)

getTopActiveCategory = function(data) {
  d = aggregate(x = as.integer(data$is_active), by = list(device_id = data$device_id, TopActiveCategory = data$new_cat_name ),
                FUN = function(x) {
                  return(sum(x))
                })
  result <- d %>%
              arrange_(~ desc(x, category)) %>%
              group_by(device_id) %>%
              top_n(n = 1, wt = x)
            
  
  return(result)
}

top_cat <- data.frame(getTopActiveCategory(mergedData))
device_data_Cat <- merge(device_data_Cat, top_cat, by = "device_id")#, all.x = TRUE);
device_data_Cat <- subset( device_data_Cat, select = -c(x))
head(device_data_Cat)


