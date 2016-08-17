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
  maxEventsToRead = Inf
  maxAppEventsToRead = 100000
  
  loginfo(paste0('maxEventsToRead is ',maxEventsToRead, ', maxAppEventsToRead is ',maxAppEventsToRead))
  #loginfo(paste0('maxAppEventsToRead is ',maxAppEventsToRead))

  loginfo('Reading events.csv')
  
  deviceEvents = read.csv('data/events.csv', header = TRUE, 
                          nrows = maxEventsToRead, 
                          numerals = 'warn.loss',
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of device_id values
                          colClasses = c('character', 'character', 'POSIXct',NA,NA))
  
  loginfo('Reading gender_age_train.csv')
  genderAgeTrain = read.csv('data/gender_age_train.csv', 
                       numerals = 'warn.loss',
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of device_id values
                       colClasses = c('character','factor', NA, 'factor'))
  
  loginfo('Getting intersection between genderAgeTrain and deviceEvents on device_id')
  intersectDeviceId = intersect(genderAgeTrain$device_id, deviceEvents$device_id)
  
  loginfo('Omitting deviceEvents where device_id does not exist in genderAgeTrain')
  deviceEvents = deviceEvents[deviceEvents$device_id %in% intersectDeviceId,]
  
  # add is_weekend flag
  deviceEvents$isWeekend = getIsWeekend(deviceEvents$timestamp)
  # add day of week feature
  deviceEvents$dow = getDow(deviceEvents$timestamp)
  # add time window feature (e.g. "morning", "afternoon")
  deviceEvents$timeWindow = getTimeWindow(deviceEvents$timestamp)
  # add hour of day
  deviceEvents$hour = getHour(deviceEvents$timestamp)
  
  loginfo('Reading label_categories.csv')
  labelCategories = read.csv('data/label_categories.csv',
                             numerals = 'warn.loss')
  
  # TODO: the consolidateCategories function is not done, 
  # come back if you have time (low priority)
  #loginfo('Consolidating categories')
  #conCategories = consolidateCategories(labelCategories$category)
  
  loginfo('Reading app_labels.csv')
  appLabels = read.csv('data/app_labels.csv',
                       numerals = 'warn.loss',
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of app_id values
                       colClasses = c('character'))

  
  loginfo('Flatten relationship  (app category)')
  appCategories = mergeAppLabelCategories(appLabels, labelCategories)

  loginfo('Reading app_events.csv')
  appEvents = read.csv('data/app_events.csv', 
                       numerals = 'warn.loss',
                       nrows = maxAppEventsToRead,
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of app_id values
                       colClasses = c(NA,'character', 'factor', 'factor'))
  
  loginfo('Flatten relationship (app events and app categories)')
  appEventCategories = mergeAppEventCategories(appEvents, appCategories)
  
  loginfo('Flatten relationship (device events and app events)');
  eventData = mergeDeviceEventsAppEvents(deviceEvents, appEventCategories)


  loginfo('Flatten relationship (gender/age and phone event data)')
  genderAgeDevice = mergeAgeGenderDevice(genderAgeTrain, eventData)

  
  loginfo('Reading phone_brand_device_model.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phoneSpecs = read.csv('data/phone_brand_device_model.csv', 
                        encoding="UTF-8", 
                        numerals = 'warn.loss',
                        # use character class as we would otherwise lose precision
                        # (using 'numeric') with the size of device_id values
                        colClasses = c('character','factor','factor'))
  
  loginfo('Flatten relationship (gender/age and phone specs)')
  flatData = mergeGenderAgePhoneSpecs(genderAgeDevice, phoneSpecs)
  
  loginfo('Writing flattened data')
  write.csv(flatData, 'output/flatData.csv')
  
  loginfo('Removing some columns from flattened data')
  flatNarrowData = data.frame(flatData)
  flatNarrowData$event_id = NULL
  #flatNarrowData$app_id = NULL
  flatNarrowData$label_id = NULL
  #flatNarrowData$is_active = NULL
  flatNarrowData$longitude = NULL
  flatNarrowData$latitude = NULL
  flatNarrowData$timestamp = NULL
  flatNarrowData$is_installed = NULL
  flatNarrowData$gender = NULL
  flatNarrowData$age = NULL
  flatNarrowData$category = NULL
  
  # de-duplicate
  flatNarrowData = unique(flatNarrowData)
  
  loginfo('Writing flattened, narrowed data (omitting some columns)')
  write.csv(flatNarrowData, 'output/flatNarrowData.csv')

  plotAgeGroupPopularPhoneBrands(flatNarrowData)
  plotAgeGroupPopularDeviceModels(flatNarrowData)
}