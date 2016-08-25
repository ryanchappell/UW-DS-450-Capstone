# this is currently a rough draft for aggregating two device category batches; this will be incorporated
# in the main code soon (hopefully!)...

source('prepareAdjustedData.R')
source('classifyAppCategories.R')

# rough amount of lines of app_events.csv
appEventLinesRemaining = 32000000
batchSize = 500000
eventDeviceMap = getEventDeviceMap(FALSE)
appCategoryCounts = getAppCategoryCounts()

# need this when using 'skip' param on read.csv
colNames = c("event_id", "app_id", "is_installed","is_active")
currentBatchNumber = 0

deviceAppEventCategories = NULL
combinedRows = NULL
keepReading = TRUE

while(keepReading){
  loginfo(paste0('Reading data/app_events.csv, appEventLinesRemaining: ',appEventLinesRemaining, 
                 ' batchSize: ', batchSize, 
                 ', currentBatchNumber:', currentBatchNumber))
  
  app_events_csv_batch_1 = read.csv('data/app_events.csv', 
                            numerals = 'warn.loss',
                            nrows = batchSize,
                            skip = currentBatchNumber * batchSize, # skip the first batch                            
                            # use character class as we would otherwise lose precision
                            # (using 'numeric') with the size of app_id values
                            colClasses = c(NA,'character', 'integer', 'integer'), 
                            col.names = colNames)
  
  if (nrow(app_events_csv_batch_1) < batchSize){ #|| currentBatchNumber == 0){
    keepReading = FALSE
  }

  mergedEventDeviceCats_batch_1 = merge(eventDeviceMap, app_events_csv_batch_1, by = "event_id")
  mergedEventDeviceCats_batch_1 = merge(mergedEventDeviceCats_batch_1, appCategoryCounts, by = "app_id")
  
  # which columns we are aggregating
  aggColumns = 4:ncol(mergedEventDeviceCats_batch_1)

  # aggregate the current rows
  deviceAppEventCategories = aggregate(x = mergedEventDeviceCats_batch_1[,aggColumns], 
                                       by = list(device_id = mergedEventDeviceCats_batch_1$device_id), 
                                       FUN = function(x){
                                         sum(x)
                                       })
    
  if (is.null(combinedRows)){
    combinedRows = deviceAppEventCategories
  } else {
    combinedAggColumns = 2:ncol(combinedRows)
    
    # combine with the existing aggregated rows
    combinedRows = rbind(deviceAppEventCategories, combinedRows)  
    
    # aggregate combined rows
    combinedRows = aggregate(x = combinedRows[,combinedAggColumns], 
                                         by = list(device_id = combinedRows$device_id), 
                                         FUN = function(x){
                                           sum(x)
                                         })
  }

  loginfo(paste0('deviceAppEventCategories row count: ', nrow(combinedRows)))
  loginfo(paste0('max is_installed: ', max(combinedRows$is_installed),' max is_game: ', max(combinedRows$is_game)))
  
  currentBatchNumber = currentBatchNumber + 1
  appEventLinesRemaining = appEventLinesRemaining - batchSize
}

write.csv(combinedRows, file = 'adjusted-data/device_app_event_categories.csv')

#sanity check here w/ one of the devices
# category counts in this one...
#summedDeviceCategories_batch_2[summedDeviceCategories_batch_2$device_id == '-1030095627418420917',]
#... plus the counts in this one...
#summedDeviceCategories_batch_1[summedDeviceCategories_batch_1$device_id == '-1030095627418420917',]
# should equal the totals in this one...
#finalSummed[finalSummed$device_id == '-1030095627418420917',]


