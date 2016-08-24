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
source('classifyAppCategories.R')

########## CHANGE THIS for your local machine
setwd('C:/projects/UW-DS-450-Capstone')

# log settings
basicConfig('INFO')
addHandler(writeToFile, file = 'UW-DS-450-Capstone.log')
loginfo('Starting up!')

# these two data files (events, app_events) are large, 
# providing these limits
maxEventsToRead = 100000
maxAppEventsToRead = 100000
readAppEvents = FALSE

# default batch stuff (defaults to no batch)
deviceBatchSize = 0
deviceBatchStartIndex = 0

args = commandArgs(trailingOnly = TRUE)

# test if there is at least one argument: if not, return an error
if(length(args) == 2){

  loginfo(paste0("Batching initiated by command line arguments-- deviceBatchSize: ",
               args[1],
               " deviceBatchStartIndex: ",
               args[2]))

  deviceBatchSize = as.numeric(args[1])
  # the index to start on
  deviceBatchStartIndex = as.numeric(args[2])
    
  # throw error and exit if arguments are not valid
  stopifnot(deviceBatchSize > 0 && deviceBatchStartIndex >= 0)  
}
  
outputFileAppend = NULL

if (deviceBatchSize > 0 && deviceBatchStartIndex >= 0){
  outputFileAppend = paste0("_deviceBatchSize-", deviceBatchSize,
                            "-deviceBatchStartIndex-", deviceBatchStartIndex)
}

#if (interactive()) {
  # for device batching
  
  # set this to TRUE if adjusted-data/phone_brand_device_model_unique.csv 
  # should be recreated
  recreateAdjustedPhoneBrandFile = FALSE
  recreateAdjustedEventsFile = FALSE
  
  
  # this call creates the adjusted-data/phone_brand_device_model_unique.csv 
  # file referenced below
  if (!file.exists('adjusted-data/phone_brand_device_model_unique.csv') || recreateAdjustedPhoneBrandFile){
    createAdjustedPhoneBrandDataFile()
  }
  
  # this call creates the adjusted-data/phone_brand_device_model_unique.csv 
  # file referenced below
  if (!file.exists('adjusted-data/events_aggregated_features.csv') || recreateAdjustedEventsFile){
    createAdjustedEventsDataFile()
  }
  
  loginfo('Reading adjusted-data/phone_brand_device_model_unique.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phone_brand_device_model_csv_unique = read.csv('adjusted-data/phone_brand_device_model_unique.csv', 
                                                 encoding="UTF-8", 
                                                 numerals = 'warn.loss',
                                                 # use character class as we would otherwise lose precision
                                                 # (using 'numeric') with the size of device_id values
                                                 colClasses = c('character','factor','factor'),
                                                skip = deviceBatchStartIndex,
                                                nrows = deviceBatchSize)
  
  loginfo('Reading adjusted-data/events_aggregated_features.csv')
  events_aggregated_features_csv = read.csv('adjusted-data/events_aggregated_features.csv',
                                            # skip row column and
                                            # use character class as we would otherwise lose precision
                                            # (using 'numeric') with the size of device_id values
                                            colClasses = c(NA,'character'))
  
  # remove the row number from files read
  events_aggregated_features_csv$X = NULL
  phone_brand_device_model_csv_unique$X = NULL
  
  loginfo('Merging phone_brand_device_model_csv_unique and events_aggregated_features_csv')
  mergedData = merge(phone_brand_device_model_csv_unique, events_aggregated_features_csv, by = "device_id", all.x = TRUE)
  
  # TODO: discuss this (there are plenty of devices without events and, by extension, event timestamps),
  # maybe we use median or mean for values? don't know...
  # Also, this can be refactored to a loop or sapply for simplicity
  loginfo('Replacing NA values in mergedData (devices with zero events)')
  mergedData[is.na(mergedData$dayIsNotWeekend),]$dayIsNotWeekend = 0
  mergedData[is.na(mergedData$dayIsWeekend),]$dayIsWeekend = 0
  mergedData[is.na(mergedData$dowSunday),]$dowSunday = 0
  mergedData[is.na(mergedData$dowMonday),]$dowMonday = 0
  mergedData[is.na(mergedData$dowTuesday),]$dowTuesday = 0
  mergedData[is.na(mergedData$dowWednesday),]$dowWednesday = 0
  mergedData[is.na(mergedData$dowThursday),]$dowThursday = 0
  mergedData[is.na(mergedData$dowFriday),]$dowFriday = 0
  mergedData[is.na(mergedData$dowSaturday),]$dowSaturday = 0
  mergedData[is.na(mergedData$afternoon),]$afternoon = 0
  mergedData[is.na(mergedData$evening),]$evening = 0
  mergedData[is.na(mergedData$late),]$late = 0
  mergedData[is.na(mergedData$lunch),]$lunch = 0
  mergedData[is.na(mergedData$morning),]$morning = 0
  
  # remove these (they are now in mergedData)
  rm(events_aggregated_features_csv)
  # remove these (they are now in mergedData)
  rm(phone_brand_device_model_csv_unique)

  loginfo('Getting app category counts')
  appCategoryCounts = getAppCategoryCounts()
  
  #head(appCategoryCounts[order(appCategoryCounts$is_game, decreasing = TRUE),])
  
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
                              colClasses = c('character', NA))
    
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
    
    
    loginfo('Adding binLabelCategories to label_categories_csv')
    label_categories_csv = cbind(label_categories_csv, binLabelCategories)
    
    loginfo('Merging label_categories_csv')
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
  write.csv(trainData, paste0('output/trainData', outputFileAppend,'.csv'))
  
  loginfo('Removing some columns from trainData for trainDataNarrow')
  trainDataNarrow = getNarrowDataFrame(trainData)

  loginfo('Writing flattened, narrowed data (omitting some columns)')
  write.csv(trainDataNarrow, paste0('output/trainDataNarrow', outputFileAppend,'.csv'))
  
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
  write.csv(testData, paste0('output/testData',outputFileAppend,'.csv'))
  
  loginfo('Removing some columns from testData for testDataNarrow')
  testDataNarrow = getNarrowDataFrame(testData)

  loginfo('Writing testDataNarrow.csv')
  write.csv(testDataNarrow, paste0('output/testDataNarrow',outputFileAppend,'.csv'))

  #plotAgeGroupPopularPhoneBrands(trainDataNarrow)
  #plotAgeGroupPopularDeviceModels(trainDataNarrow)
#}