##--------------------------------------------
##
## UW 450 Capstone project
##
## This scratch file is currently used for initial data exploration.
##
##--------------------------------------------

##-----Load Libraries-----
install.packages("logging")
library(logging)

source('flatten.R')

setwd("c:/project/UW-450-DS-Capstone/")

if (interactive()) {
  loginfo("Starting up!")
  
  # log settings
  basicConfig("INFO")
  addHandler(writeToFile, file = "Homework04.log")
  
  # limit reading of large files
  maxRecordsToRead = 1000
  
  loginfo("Reading label_categories.csv")
  labelCategories = read.csv('data/label_categories.csv', nrows = maxRecordsToRead)
  
  # Summary shows there are duplicate ids for categories,
  # e.g. "Financial Information" has ids 162,790, and 922.
  # These will likely need to be deduplicated. Also, look for 
  # case-insensitive duplicates
  summary(labelCategories)
  
  # Just grab a slice of the original data for exploration
  loginfo("Reading app_labels.csv")
  appLabels = read.csv('data/app_labels.csv', nrows = maxRecordsToRead)
  
  # flatten relationship (app category)
  appCategories = mergeAppLabelCategories(appLabels, labelCategories)

  loginfo("Reading app_events.csv")
  appEvents = read.csv('data/app_events.csv', nrows = maxRecordsToRead)
  
  # flatten relationship (app event category)
  # TODO: review if we should binarize these categories (rather than
  # having a row in the flattened data for each category)
  appEventCategories = mergeAppEventCategories(appEvents, appCategories)
  
  # TODO: investigate why some category column values are '<NA>';a
  # is it because they don't have values or is it a logic error
  # head(appEventCategories)
  
  loginfo("Reading events.csv")
  deviceEvents = read.csv('data/events.csv', nrows = maxRecordsToRead)
  
  # flatten relationship (device events and app events)
  eventData = mergeDeviceEventsAppEvents(deviceEvents, appEventCategories)
  
  loginfo("Reading gender_age_train.csv")
  genderAge = read.csv('data/gender_age_train.csv', nrows = maxRecordsToRead)
  
  # TODO: look into why all categories are NA here (not enough data read?
  # logic error?)
  genderAgeDevice = mergeAgeGenderDevice(genderAge, eventData)
  
  loginfo("Reading phone_brand_device_model.csv")
  # TODO: some of the columns are returning, what appear to be, characters in a different
  # encoding (e.g. 'å°ç±³'). Sort this.
  phoneSpecs = read.csv('data/phone_brand_device_model.csv', nrows = maxRecordsToRead)
  
  # TODO: look into why all categories are NA here (not enough data read?
  # logic error?)
  flatData = mergeGenderAgePhoneSpecs(genderAgeDevice, phoneSpecs)

}