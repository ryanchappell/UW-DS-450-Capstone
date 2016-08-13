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

########## CHANGE THIS for your local machine
setwd('C:/projects/UW-DS-450-Capstone')

if (interactive()) {
  # log settings
  basicConfig('INFO')
  addHandler(writeToFile, file = 'UW-DS-450-Capstone.log')
  loginfo('Starting up!')
  
  #loginfo('Running unit tests')
  #consolidateCategories_Test
  
  # process settings
  maxRecordsToRead = 5000
  loginfo(paste0('Max records to read from each data file is ', 
                 formatC(maxRecordsToRead, format="d", big.mark=',')))

  loginfo('Reading events.csv')
  
  # Note: this warning pops up for device_id and event_id, need to use 64 bit int/numeric
  # or something--
  # 'NAs introduced by coercion to integer range'
  deviceEvents = read.csv('data/events.csv', header = TRUE, nrows = maxRecordsToRead, 
                          numerals = 'warn.loss')
  
  # add day of week feature
  deviceEvents$dow = getDow(deviceEvents$timestamp)
  # add time window feature (e.g. "morning", "afternoon")
  deviceEvents$timeWindow = getTimeWindow(deviceEvents$timestamp)
  
  loginfo('Reading label_categories.csv')
  labelCategories = read.csv('data/label_categories.csv', nrows = maxRecordsToRead)
  
  # TODO: the consolidateCategories function is not done, 
  # come back if you have time (low priority)
  #loginfo('Consolidating categories')
  #conCategories = consolidateCategories(labelCategories$category)
  
  loginfo('Reading app_labels.csv')
  appLabels = read.csv('data/app_labels.csv', nrows = maxRecordsToRead)

  loginfo('Flatten relationship  (app category)')
  appCategories = mergeAppLabelCategories(appLabels, labelCategories)

  loginfo('Reading app_events.csv')
  appEvents = read.csv('data/app_events.csv', nrows = maxRecordsToRead)
  
  loginfo('Flatten relationship (app events and app categories)')
  appEventCategories = mergeAppEventCategories(appEvents, appCategories)
  
  loginfo('Flatten relationship (device events and app events)');
  eventData = mergeDeviceEventsAppEvents(deviceEvents, appEventCategories)
  
  loginfo('Reading gender_age_train.csv')
  genderAge = read.csv('data/gender_age_train.csv', nrows = maxRecordsToRead)

  loginfo('Flatten relationship (gender/age and phone event data)')
  genderAgeDevice = mergeAgeGenderDevice(genderAge, eventData)

  
  loginfo('Reading phone_brand_device_model.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phoneSpecs = read.csv('data/phone_brand_device_model.csv', nrows = maxRecordsToRead, 
                        encoding="UTF-8", stringsAsFactors = FALSE)
  
  loginfo('Flatten relationship (gender/age and phone specs)')
  flatData = mergeGenderAgePhoneSpecs(genderAgeDevice, phoneSpecs)

  # drop records with no useful attributes
  keepRows = (!is.na(flatData$longitude) &
             !is.na(flatData$longitude)) |
             !is.na(flatData$is_active) |
             !is.na(flatData$category) |
             !is.na(flatData$app_id) |
             !is.na(flatData$phone_brand) |
             !is.na(flatData$phone_brand)
  
  keepColumns = !(names(flatData) %in% c("device_id"))
  
  flatDataFiltered = flatData[keepRows,]
  
  write.csv(flatDataFiltered, 'output/generated_flatDataFiltered.csv')
}