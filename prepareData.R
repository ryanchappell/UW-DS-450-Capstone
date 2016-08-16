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
  
  #loginfo('Running unit tests')
  #consolidateCategories_Test
  
  # these two data files (events, app_events) are large, 
  # providing these limits
  maxEventsToRead = 100000
  maxAppEventsToRead = 100000
  
  loginfo(paste0('maxEventsToRead is ',maxEventsToRead, ', maxAppEventsToRead is ',maxAppEventsToRead))

  loginfo('Reading events.csv')
  
  deviceEvents = read.csv('data/events.csv', header = TRUE, 
                          nrows = maxEventsToRead, 
                          numerals = 'warn.loss',
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of device_id values
                          colClasses = c('character', 'character', 'POSIXct',NA,NA))
  
  # add is_weekend flag
  deviceEvents$isWeekend = getIsWeekend(deviceEvents$timestamp)
  # add day of week feature
  deviceEvents$dow = getDow(deviceEvents$timestamp)
  # add time window feature (e.g. "morning", "afternoon")
  deviceEvents$timeWindow = getTimeWindow(deviceEvents$timestamp)
  
  loginfo('Reading label_categories.csv')
  labelCategories = read.csv('data/label_categories.csv',
                             numerals = 'warn.loss')#, nrows = maxRecordsToRead)
  
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
  
  loginfo('Reading gender_age_train.csv')
  genderAge = read.csv('data/gender_age_train.csv', 
                       numerals = 'warn.loss',
                       # use character class as we would otherwise lose precision
                       # (using 'numeric') with the size of device_id values
                       colClasses = c('character','factor', NA, 'factor'))

  loginfo('Flatten relationship (gender/age and phone event data)')
  genderAgeDevice = mergeAgeGenderDevice(genderAge, eventData)

  
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
  
  loginfo('Removing id columns from flattened data')
  flatDataNoIds = data.frame(flatData)
  flatDataNoIds$device_id = NULL
  flatDataNoIds$event_id = NULL
  flatDataNoIds$app_id = NULL
  flatDataNoIds$label_id = NULL
  
  loginfo('Writing flattened data, omitting ids')
  write.csv(flatDataNoIds, 'output/flatDataNoIds.csv')

  plotAgeGroupPopularPhoneBrands(flatDataNoIds)
  plotAgeGroupPopularDeviceModels(flatDataNoIds)
  
  # This looks to be obsolete after using 'character'
  # for id features (device_id, etc).
  # drop records with no useful attributes
  #keepRows = (!is.na(flatData$longitude) &
  #           !is.na(flatData$longitude)) |
  #           !is.na(flatData$is_active) |
  #           !is.na(flatData$category) |
  #           !is.na(flatData$app_id) |
  #           !is.na(flatData$phone_brand) |
  #           !is.na(flatData$phone_brand)
  
  #keepColumns = !(names(flatData) %in% c("device_id"))
  
  #flatDataFiltered = flatData[keepRows,]
  
  #loginfo('Writing flattened data, filtered (records with key feature values missing were removed)')
  #write.csv(flatDataFiltered, 'output/flatDataFiltered.csv')
  
  #flatDataFilteredNoIds = flatDataNoIds[keepRows,]
  
  #loginfo('Writing flattened data, filtered, omitting ids')
  #write.csv(flatDataFilteredNoIds, 'output/flatDataFilteredNoIds.csv')
}