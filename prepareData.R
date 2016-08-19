##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This script will read the data csv files and flatten the data heirarchy.
##
##--------------------------------------------

##-----Load Libraries-----
install.packages('logging')
library(logging)

source('prepareDataUtils.R')
source('exploreData.R')

########## CHANGE THIS for your local machine
setwd('C:/projects/UW-DS-450-Capstone')

if (interactive()) {
  # log settings
  basicConfig('INFO')
  addHandler(writeToFile, file = 'UW-DS-450-Capstone.log')
  loginfo('Starting up!')
  
  # these two data files (events, app_events) are large, 
  # providing these limits
  maxEventsToRead = 100000
  maxAppEventsToRead = 100000
  
  loginfo(paste0('maxEventsToRead is ',maxEventsToRead, ', maxAppEventsToRead is ',maxAppEventsToRead))

  loginfo('Reading label_categories.csv')
  label_categories_csv = read.csv('data/label_categories.csv',
                                  numerals = 'warn.loss')
  
  # TODO: the consolidateCategories function is not done, 
  # come back if you have time (low priority)
  #loginfo('Consolidating categories')
  #conCategories = consolidateCategories(label_categories_csv$category)
  
  loginfo('Reading app_labels.csv')
  app_labels_csv = read.csv('data/app_labels.csv',
                            numerals = 'warn.loss',
                            # use character class as we would otherwise lose precision
                            # (using 'numeric') with the size of app_id values
                            colClasses = c('character'))
  
  
  loginfo('Flatten relationship  (app category)')
  mergedData = merge(app_labels_csv, label_categories_csv, by = "label_id", all.x = TRUE)
  
  loginfo('Reading app_events.csv')
  app_events_csv = read.csv('data/app_events.csv', 
                            numerals = 'warn.loss',
                            nrows = maxAppEventsToRead,
                            # use character class as we would otherwise lose precision
                            # (using 'numeric') with the size of app_id values
                            colClasses = c(NA,'character', 'factor', 'factor'))
  
  loginfo('Flatten relationship (app events and app categories)')
  mergedData = merge(app_events_csv, mergedData, by = "app_id", all.x = TRUE)
  
  loginfo('Reading events.csv')
  events_csv = read.csv('data/events.csv', header = TRUE, 
                          nrows = maxEventsToRead, 
                          numerals = 'warn.loss',
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of device_id values
                          colClasses = c('character', 'character', 'POSIXct',NA,NA))
  
  # add is_weekend flag
  events_csv$isWeekend = getIsWeekend(events_csv$timestamp)
  # add day of week feature
  events_csv$dow = getDow(events_csv$timestamp)
  # add time window feature (e.g. "morning", "afternoon")
  events_csv$timeWindow = getTimeWindow(events_csv$timestamp)
  # add hour of day
  events_csv$hour = getHour(events_csv$timestamp)  
  
  loginfo('Flatten relationship (device events and app events)');
  mergedData = merge(events_csv, mergedData, by = "event_id")
  
  loginfo('Reading phone_brand_device_model.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phone_brand_device_model_csv = read.csv('data/phone_brand_device_model.csv', 
                                          encoding="UTF-8", 
                                          numerals = 'warn.loss',
                                          # use character class as we would otherwise lose precision
                                          # (using 'numeric') with the size of device_id values
                                          colClasses = c('character','factor','factor'))
  
  loginfo('Flatten relationship (gender/age and phone specs)')
  mergedData = merge(mergedData, phone_brand_device_model_csv, by = "device_id")
  
  loginfo('Reading gender_age_train.csv')
  gender_age_train_csv = read.csv('data/gender_age_train.csv', 
                       numerals = 'warn.loss',
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of device_id values
                       colClasses = c('character','factor', NA, 'factor'))
  
  loginfo('Getting intersection between gender_age_train_csv and mergedData on device_id')
  intersectDeviceId = intersect(gender_age_train_csv$device_id, mergedData$device_id)
  
  loginfo('Omitting mergedData where device_id does not exist in gender_age_train_csv')
  trainIntersection = mergedData[mergedData$device_id %in% intersectDeviceId,]

  loginfo('Flatten relationship (gender/age and phone event data)')
  trainData = merge(gender_age_train_csv, trainIntersection, by = "device_id")
  
  loginfo('Writing flattened data')
  write.csv(trainData, 'output/trainData.csv')
  
  loginfo('Removing some columns from flattened data')
  trainDataNarrow = data.frame(trainData)
  trainDataNarrow$event_id = NULL
  #trainDataNarrow$app_id = NULL
  trainDataNarrow$label_id = NULL
  #trainDataNarrow$is_active = NULL
  trainDataNarrow$longitude = NULL
  trainDataNarrow$latitude = NULL
  trainDataNarrow$timestamp = NULL
  trainDataNarrow$is_installed = NULL
  #trainDataNarrow$gender = NULL
  #trainDataNarrow$age = NULL
  trainDataNarrow$category = NULL
  
  # de-duplicate
  trainDataNarrow = unique(trainDataNarrow)
  
  loginfo('Writing flattened, narrowed data (omitting some columns)')
  write.csv(trainDataNarrow, 'output/trainDataNarrow.csv')

  #plotAgeGroupPopularPhoneBrands(trainDataNarrow)
  #plotAgeGroupPopularDeviceModels(trainDataNarrow)
}