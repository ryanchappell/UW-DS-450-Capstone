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
  readAppEvents = FALSE
  
  #loginfo(paste0('maxEventsToRead is ',maxEventsToRead, ', maxAppEventsToRead is ',maxAppEventsToRead))

  loginfo('Reading adjusted-data/phone_brand_device_model_unique.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phone_brand_device_model_csv_unique = read.csv('adjusted-data/phone_brand_device_model_unique.csv', 
                                                 encoding="UTF-8", 
                                                 numerals = 'warn.loss',
                                                 # use character class as we would otherwise lose precision
                                                 # (using 'numeric') with the size of device_id values
                                                 colClasses = c('character','factor','factor'))
  

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
  
  loginfo('Merging phone_brand_device_model_csv_unique')
  mergedData = merge(phone_brand_device_model_csv_unique, events_csv, by = "device_id")
  
  # remove these (they are now in mergedData)
  rm(events_csv)
  # remove these (they are now in mergedData)
  rm(phone_brand_device_model_csv_unique)

  if (readAppEvents){
    loginfo('Reading app_events.csv')
    app_events_csv = read.csv('data/app_events.csv', 
                              numerals = 'warn.loss',
                              nrows = maxAppEventsToRead,
                              # use character class as we would otherwise lose precision
                              # (using 'numeric') with the size of app_id values
                              colClasses = c(NA,'character', 'factor', 'factor'))
    
    loginfo('Merging app_events_csv')
    mergedData = merge(mergedData, app_events_csv, by = "event_id")#, all.x = TRUE)
    
    # remove these (they are now in mergedData)
    rm(app_events_csv)
    
    loginfo('Reading app_labels.csv')
    app_labels_csv = read.csv('data/app_labels.csv',
                              numerals = 'warn.loss',
                              # use character class as we would otherwise lose precision
                              # (using 'numeric') with the size of app_id values
                              colClasses = c('character'))
    
    loginfo('Merging app_labels_csv')
    mergedData = merge(mergedData, app_labels_csv, by = "app_id")#, all.x = TRUE)
    
    # remove these (they are now in mergedData)
    rm(app_labels_csv)
    
    # TODO: the consolidateCategories function is not done, 
    # come back if you have time (low priority)
    #loginfo('Consolidating categories')
    #conCategories = consolidateCategories(label_categories_csv$category)
    
  
    loginfo('Reading label_categories.csv')
    label_categories_csv = read.csv('data/label_categories.csv',
                                    numerals = 'warn.loss')
    
    
    loginfo('Merging app_labels_csv and label_categories_csv')
    mergedData = merge(mergedData, label_categories_csv, by = "label_id")#, all.x = TRUE)
    
    # remove these (they are now in mergedData)
    rm(label_categories_csv)
  }
  
  ############## set up TRAINING data
  loginfo('Reading gender_age_train.csv')
  gender_age_train_csv = read.csv('data/gender_age_train.csv', 
                       numerals = 'warn.loss',
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of device_id values
                       colClasses = c('character','factor', NA, 'factor'))
  
  loginfo('Getting intersection between gender_age_train_csv and mergedData on device_id')
  trainIntersection = intersect(gender_age_train_csv$device_id, mergedData$device_id)
  
  loginfo('Omitting mergedData where device_id does not exist in gender_age_train_csv')
  trainIntersectionData = mergedData[mergedData$device_id %in% trainIntersection,]

  # remove this (now using trainIntersectionData)
#  rm(mergedData)
  
  loginfo('Merging gender_age_train_csv')
  trainData = merge(gender_age_train_csv, trainIntersectionData, by = "device_id")
  
  # remove these (they are now in mergedData)
  rm(gender_age_train_csv)
  rm(trainIntersectionData)
  
  loginfo('Writing trainData.csv')
  write.csv(trainData, 'output/trainData.csv')
  
  loginfo('Removing some columns from trainData for trainDataNarrow')
  trainDataNarrow = data.frame(trainData)
  trainDataNarrow$event_id = NULL
  trainDataNarrow$app_id = NULL
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
  
  ############## set up TEST data
  loginfo('Reading gender_age_test.csv')
  gender_age_test_csv = read.csv('data/gender_age_test.csv', 
                                  numerals = 'warn.loss',
                                  # use character class as we would otherwise lose precision
                                  # (using 'numeric') with the size of device_id values
                                  colClasses = c('character'))
  
  loginfo('Getting intersection between gender_age_test_csv and mergedData on device_id')
  testIntersection = intersect(gender_age_test_csv$device_id, mergedData$device_id)
  
  loginfo('Omitting mergedData where device_id does not exist in gender_age_test_csv')
  testIntersectionData = mergedData[mergedData$device_id %in% testIntersection,]
  
  # remove this (now using trainIntersectionData)
  #  rm(mergedData)
  
  loginfo('Merging gender_age_test_csv')
  testData = merge(gender_age_test_csv, testIntersectionData, by = "device_id")
  
  # remove these (they are now in mergedData)
  rm(gender_age_test_csv)
  rm(testIntersectionData)
  
  loginfo('Writing testData.csv')
  write.csv(testData, 'output/testData.csv')
  
  loginfo('Removing some columns from testData for testDataNarrow')
  testDataNarrow = data.frame(testData)
  testDataNarrow$event_id = NULL
  testDataNarrow$app_id = NULL
  testDataNarrow$label_id = NULL
  #testDataNarrow$is_active = NULL
  testDataNarrow$longitude = NULL
  testDataNarrow$latitude = NULL
  testDataNarrow$timestamp = NULL
  testDataNarrow$is_installed = NULL
  #testDataNarrow$gender = NULL
  #testDataNarrow$age = NULL
  testDataNarrow$category = NULL
  
  # de-duplicate
  testDataNarrow = unique(testDataNarrow)
  
  loginfo('Writing testDataNarrow.csv')
  write.csv(testDataNarrow, 'output/testDataNarrow.csv')

  #plotAgeGroupPopularPhoneBrands(trainDataNarrow)
  #plotAgeGroupPopularDeviceModels(trainDataNarrow)
}