
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

eventDeviceMap = getEventDeviceMap(FALSE)

gender_age_train_csv = read.csv('data/gender_age_train.csv', 
                                numerals = 'warn.loss',
                                # use character class as we would otherwise lose precision
                                # (using 'numeric') with the size of device_id values
                                colClasses = c('character','factor', NA, 'factor'))


# get distinct device_ids from events
uniqueDeviceIdsFromEvents = data.frame(list(device_id = unique(eventDeviceMap$device_id)))
uniqueDeviceIdsFromTrainingData = data.frame(list(device_id = unique(gender_age_train_csv$device_id)))

#mergedPhoneEvent = merge(phone_brand_device_model_csv_unique, uniqueDeviceIdsFromEvents, by = "device_id")
uniqueTrainingDevicesWithEvents = merge(uniqueDeviceIdsFromEvents, uniqueDeviceIdsFromTrainingData, by = "device_id")
nrow(uniqueTrainingDevicesWithEvents)


