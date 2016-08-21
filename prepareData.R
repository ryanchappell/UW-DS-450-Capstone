##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This script will read the data csv files and flatten the data heirarchy.
##
##--------------------------------------------

##-----Load Libraries-----

if('logging' %in% rownames(installed.packages()) == FALSE) {
  install.packages('logging')
}

library(logging)

source('prepareDataUtils.R')
source('prepareAdjustedData.R')
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
  
  # set this to TRUE if adjusted-data/phone_brand_device_model_unique.csv 
  # should be recreated
  recreateAdjustedPhoneBrandFile = FALSE
  
  
  # this call creates the adjusted-data/phone_brand_device_model_unique.csv 
  # file referenced below
  if (!file.exists('adjusted-data/phone_brand_device_model_unique.csv') || recreateAdjustedPhoneBrandFile){
    createAdjustedPhoneBrandDataFile()
  }
  
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
  
  loginfo('Get weekend counts')
  isWeekendCounts = getIsWeekendCounts(events_csv)
  
  # we are done with isWeekend
  events_csv$isWeekend = NULL
  
  loginfo('Add weekend counts to events_csv')
  events_csv = merge(events_csv, isWeekendCounts, by = "device_id")
  
  # add day of week feature
  events_csv$dow = getDow(events_csv$timestamp)
  
  
  # add time window feature (e.g. "morning", "afternoon")
  events_csv$timeWindow = getTimeWindow(events_csv$timestamp)
  # add hour of day
  #events_csv$hour = getHour(events_csv$timestamp) 
  
  loginfo('Get day of week counts')
  dowCounts = getDowCounts(events_csv)
  
  loginfo('Add day of week counts to events_csv')
  events_csv = merge(events_csv, dowCounts, by = "device_id")

  # remove down since we are done with it
  events_csv$dow = NULL
    
  loginfo('Get time window counts')
  timeWindowCounts = getTimeWindowCounts(events_csv)
  
  # remove timeWindow since we are done with it
  events_csv$timeWindow = NULL
  
  loginfo('Add time window counts to events_csv')
  events_csv = merge(events_csv, timeWindowCounts, by = "device_id")
  
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
  trainDataNarrow = getNarrowDataFrame(trainData)

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
  testDataNarrow = getNarrowDataFrame(testData)

  loginfo('Writing testDataNarrow.csv')
  write.csv(testDataNarrow, 'output/testDataNarrow.csv')

  #plotAgeGroupPopularPhoneBrands(trainDataNarrow)
  #plotAgeGroupPopularDeviceModels(trainDataNarrow)
}