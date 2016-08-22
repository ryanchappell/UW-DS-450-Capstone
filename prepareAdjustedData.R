
if('logging' %in% rownames(installed.packages()) == FALSE) {
  install.packages('logging')
}

library(logging)

source('prepareDataUtils.R')


# This script reads phone_brand_device_model.csv and writes
# the first row of each unique device_id to the adjusted-data directory
createAdjustedPhoneBrandDataFile = function(){
  
  loginfo('Reading phone_brand_device_model.csv')
  # TODO: review character encoding, e.g. values like 'å°ç±³' for phone_brand column
  phone_brand_device_model_csv = read.csv('data/phone_brand_device_model.csv', 
                                          encoding="UTF-8", 
                                          numerals = 'warn.loss',
                                          # use character class as we would otherwise lose precision
                                          # (using 'numeric') with the size of device_id values
                                          colClasses = c('character','factor','factor'))
  
  loginfo('Get unique device_id rows from phone_brand_device_model_csv (original data has duplicates)')
  phone_brand_device_model_csv = phone_brand_device_model_csv[!duplicated(phone_brand_device_model_csv$device_id),]
  
  loginfo('Writing adjusted-data/phone_brand_device_model_unique.csv')
  write.csv(phone_brand_device_model_csv, 'adjusted-data/phone_brand_device_model_unique.csv')
}

createAdjustedEventsDataFile = function(){
  loginfo('Reading events.csv (this might take a while...)')
  events_csv = read.csv('data/events.csv', header = TRUE, 
                        numerals = 'warn.loss',
                        # use character class as we would otherwise lose precision
                        # (using 'numeric') with the size of device_id values
                        colClasses = c('character', 'character', 'POSIXct',NA,NA))
  
  # add is_weekend flag
  events_csv$isWeekend = getIsWeekend(events_csv$timestamp)
  
  loginfo('Get weekend counts')
  result = data.frame(list(getIsWeekendCounts(events_csv)))
  
  # add day of week feature
  events_csv$dow = getDow(events_csv$timestamp)
  
  loginfo('Get day of week counts (this might take a while...)')
  dowCounts = getDowCounts(events_csv)
  
  result = merge(result, dowCounts, by = "device_id")

  # add time window feature (e.g. "morning", "afternoon")
  events_csv$timeWindow = getTimeWindow(events_csv$timestamp)
    
  loginfo('Get time window counts')
  timeWindowCounts = getTimeWindowCounts(events_csv)
  
  result = merge(result, timeWindowCounts,by = "device_id")
  
  loginfo('Writing adjusted-data/events_aggregated_features.csv')
  write.csv(result, 'adjusted-data/events_aggregated_features.csv')
}