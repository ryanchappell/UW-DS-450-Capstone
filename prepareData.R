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
  
  # set these to TRUE if the adjusted data files should be 
  # recreated (otherwise, they are created if they don't exist)
  forceRecreateAdjustedPhoneBrandFile = FALSE
  forceRecreateAdjustedEventsFile = FALSE
  forceRecreateEventDeviceMapFile = FALSE
  
  
  # this call creates the adjusted-data/phone_brand_device_model_unique.csv 
  # file referenced below
  # TODO: with time, refactor like getEventDeviceMap function
  if (!file.exists('adjusted-data/phone_brand_device_model_unique.csv') || forceRecreateAdjustedPhoneBrandFile){
    createAdjustedPhoneBrandDataFile()
  }
  
  
  # this call creates the adjusted-data/phone_brand_device_model_unique.csv 
  # file referenced below
  # TODO: with time, refactor like getEventDeviceMap function call below
  if (!file.exists('adjusted-data/events_aggregated_features.csv') || forceRecreateAdjustedEventsFile){
    createAdjustedEventsDataFile()
  }
  
  # get the event-device map
  eventDeviceMap = getEventDeviceMap(forceRecreateEventDeviceMapFile)
  
  loginfo('Reading adjusted-data/phone_brand_device_model_unique.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phone_brand_device_model_csv_unique = read.csv('adjusted-data/phone_brand_device_model_unique.csv', 
                                                 encoding="UTF-8", 
                                                 numerals = 'warn.loss',
                                                 # use character class as we would otherwise lose precision
                                                 # (using 'numeric') with the size of device_id values
                                                 colClasses = c('character','factor','factor')
                                                 #,
                                                #skip = deviceBatchStartIndex,
                                                #nrows = deviceBatchSize
                                                )
  
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
  
  # remove these (they are now in mergedData)
  #rm(events_aggregated_features_csv)
  # remove these (they are now in mergedData)
  rm(phone_brand_device_model_csv_unique)

  deviceCatsFilePath = 'adjusted-data/device_app_event_categories.csv'
  if(!file.exists(deviceCatsFilePath))
  {
    loginfo(paste0(deviceCatsFilePath, ' does not exist. ',
                   'roughDeviceCategoryBatch.R must be run to generate that file'))
    stop()
  }

  # NOTE: this must match the number of count columns to read from the device category file 
  deviceCatColumnCount = 8
  readColClasses = append(c('NULL','character'), rep('integer', deviceCatColumnCount))
  
  loginfo(paste0('Reading ', deviceCatsFilePath))
  deviceAppEventCategories = read.csv(deviceCatsFilePath,
                                      # skip row column and
                                      # use character class as we would otherwise lose precision
                                      # (using 'numeric') with the size of device_id values
                                      # 'NULL' to ignore first column
                                      colClasses = readColClasses)  

  mergedData = merge(mergedData, deviceAppEventCategories, by = "device_id", all.x = TRUE)
  
  # set NAs to zero for device app event categories (devices with no events)
  mergedData[is.na(mergedData)] = 0
  
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