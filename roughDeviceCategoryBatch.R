# this is currently a rough draft for aggreating two device category batches; this will be incorporated
# in the main code soon (hopefully!)...

source('prepareAdjustedData.R')
source('classifyAppCategories.R')


batchSize = 100000
eventDeviceMap = getEventDeviceMap(FALSE)
appCategoryCounts = getAppCategoryCounts()

# need this when using 'skip' param on read.csv
colNames = c("event_id", "app_id", "is_installed","is_active")

app_events_csv_batch_1 = read.csv('data/app_events.csv', 
                          numerals = 'warn.loss',
                          nrows = batchSize,
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of app_id values
                          colClasses = c(NA,'character', 'integer', 'integer'), 
                          col.names = colNames)

app_events_csv_batch_2 = read.csv('data/app_events.csv', 
                          numerals = 'warn.loss',
                          nrows = batchSize, 
                          skip = batchSize, # skip the first batch
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of app_id values
                          colClasses = c(NA,'character', 'integer', 'integer'), 
                          col.names = colNames)

# merge and aggregation for batch 1
mergedEventDeviceCats_batch_1 = merge(eventDeviceMap, app_events_csv_batch_1, by = "event_id")
mergedEventDeviceCats_batch_1 = merge(mergedEventDeviceCats_batch_1, appCategoryCounts, by = "app_id")

# which columns we are aggregating
aggColumns = 4:10
summedDeviceCategories_batch_1 = aggregate(x = mergedEventDeviceCats_batch_1[,aggColumns], 
                                   by = list(device_id = mergedEventDeviceCats_batch_1$device_id), 
                                   FUN = function(x){
                                      sum(x)
                                   })

# merge and aggregation for batch 2
mergedEventDeviceCats_batch_2 = merge(eventDeviceMap, app_events_csv_batch_2, by = "event_id")
mergedEventDeviceCats_batch_2 = merge(mergedEventDeviceCats_batch_2, appCategoryCounts, by = "app_id")

summedDeviceCategories_batch_2 = aggregate(x = mergedEventDeviceCats_batch_2[,aggColumns], 
                                   by = list(device_id = mergedEventDeviceCats_batch_2$device_id), 
                                   FUN = function(x){
                                     sum(x)
                                   })

# okay! combine and sum the categories!
combinedRows = rbind(mergedEventDeviceCats_batch_1, mergedEventDeviceCats_batch_2)

combinedAggColumns = 4:(ncol(combinedRows) - 1)
finalSummed = aggregate(x = combinedRows[,combinedAggColumns], 
                                   by = list(device_id = combinedRows$device_id), 
                                   FUN = function(x){
                                     sum(x)
                                   })

#sanity check here w/ one of the devices
# category counts in this one...
summedDeviceCategories_batch_2[summedDeviceCategories_batch_2$device_id == '-1030095627418420917',]
#... plus the counts in this one...
summedDeviceCategories_batch_1[summedDeviceCategories_batch_1$device_id == '-1030095627418420917',]
# should equal the totals in this one...
finalSummed[finalSummed$device_id == '-1030095627418420917',]


