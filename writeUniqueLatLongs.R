##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This script will read the event data csv file and write unique lat/long values to files
##
##--------------------------------------------

##-----Load Libraries-----
install.packages('logging')
library(logging)


########## CHANGE THIS for your local machine
setwd('C:/projects/UW-DS-450-Capstone')

if (interactive()) {
  # log settings
  basicConfig('INFO')
  addHandler(writeToFile, file = 'UW-DS-450-Capstone.log')
  loginfo('Starting up!')
  
  loginfo('Reading events.csv')
  
  deviceEvents = read.csv('data/events.csv', header = TRUE, 
                          #nrows = maxEventsToRead, 
                          numerals = 'warn.loss', 
                          # use character class as we would otherwise lose precision
                          # (using 'numeric') with the size of device_id values
                          colClasses = c('character', 'character', 'POSIXct',NA,NA))
  
  uniqueLatLongs = unique(data.frame(list(lat = deviceEvents$latitude, long = deviceEvents$longitude)))
  
  loginfo('Writing uniqueLatLongs.csv')
  write.csv(uniqueLatLongs, 'sup-data/uniqueLatLongs.csv')
  
  # round to nearest 10th, to reduce number of unique lat/long values
  roundedOneDigitUniqueLatLongs = unique(round(uniqueLatLongs, digits = 1))
  roundedZeroDigitUniqueLatLongs = unique(round(uniqueLatLongs, digits = 0))
  
  write.csv(roundedOneDigitUniqueLatLongs, 'sup-data/roundedOneDigitUniqueLatLongs.csv')
  write.csv(roundedZeroDigitUniqueLatLongs, 'sup-data/roundedZeroDigitUniqueLatLongs.csv')
}