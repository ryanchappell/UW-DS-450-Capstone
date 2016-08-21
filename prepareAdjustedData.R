##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This script reads phone_brand_device_model.csv and writes
## the first row of each unique device_id to the adjusted-data directory
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