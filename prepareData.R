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

source('flatten.R')

########## CHANGE THIS for your local machine
setwd('C:/projects/UW-DS-450-Capstone')

if (interactive()) {
  # log settings
  basicConfig('INFO')
  addHandler(writeToFile, file = 'UW-DS-450-Capstone.log')
  loginfo('Starting up!')
  
  # process settings
  maxRecordsToRead = 5000
  loginfo(paste0('Max records to read from each data file is ', 
                 formatC(maxRecordsToRead, format="d", big.mark=',')))
  
  loginfo('Reading label_categories.csv')
  labelCategories = read.csv('data/label_categories.csv', nrows = maxRecordsToRead)
  
  # TODO: look at cleaning appLabels up, e.g. categories like:
  #  - multiple category instances, like 'unknown' and 'unknown' categories
  #  - cased categories, like 'teahouse' and 'Teahouse'
  #  - pluralized categories, like 'show' and 'shows'
  #  - possibly similiar categories, like 'Smart Shopping' and 'Smart Shopping 1'
  #  - empty categories, like ''
  loginfo('Reading app_labels.csv')
  appLabels = read.csv('data/app_labels.csv', nrows = maxRecordsToRead)
  

  loginfo('Flatten relationship  (app category)')
  appCategories = mergeAppLabelCategories(appLabels, labelCategories)

  loginfo('Reading app_events.csv')
  appEvents = read.csv('data/app_events.csv', nrows = maxRecordsToRead)
  
  # TODO: review if we should binarize these categories (rather than
  # having a row in the flattened data for each category)
  loginfo('Flatten relationship (app events and app categories)')
  appEventCategories = mergeAppEventCategories(appEvents, appCategories)
  
  loginfo('Reading events.csv')
  deviceEvents = read.csv('data/events.csv', nrows = maxRecordsToRead)
  
  loginfo('Flatten relationship (device events and app events)');
  eventData = mergeDeviceEventsAppEvents(deviceEvents, appEventCategories)
  
  loginfo('Reading gender_age_train.csv')
  genderAge = read.csv('data/gender_age_train.csv', nrows = maxRecordsToRead)

  loginfo('Flatten relationship (gender/age and phone event data)')
  genderAgeDevice = mergeAgeGenderDevice(genderAge, eventData)

  
  loginfo('Reading phone_brand_device_model.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phoneSpecs = read.csv('data/phone_brand_device_model.csv', nrows = maxRecordsToRead)
  
  loginfo('Flatten relationship (gender/age and phone specs)')
  flatData = mergeGenderAgePhoneSpecs(genderAgeDevice, phoneSpecs)

}