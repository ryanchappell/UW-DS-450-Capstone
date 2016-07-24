##--------------------------------------------
##
## UW 450 Capstone project
##
## This file contains utility functions to flatten the data.
##
##--------------------------------------------

## TODO: review which of these should be in INNER JOIN


# function to LEFT JOIN on label_id
mergeAppLabelCategories = function(appLabels, labelCategories)
{
  result = merge(appLabels, labelCategories, by = "label_id", all.x = TRUE)
  return(result)
}

# function to LEFT JOIN on app_id
mergeAppEventCategories = function(appEvents, appCategories)
{
  result = merge(appEvents, appCategories, by = "app_id", all.x = TRUE)
  return(result)
}

# function to LEFT JOIN on event_id
mergeDeviceEventsAppEvents = function(appEvents, appEventCategories)
{
  result = merge(appEvents, appEventCategories, by = "event_id", all.x = TRUE)
  return(result)
}

# function to LEFT JOIN on device_id
mergeAgeGenderDevice = function(ageGender, device)
{
  result = merge(ageGender, device, by = "device_id", all.x = TRUE)
  return(result)
}

# function to LEFT JOIN on device_id
mergeGenderAgePhoneSpecs = function(genderAgeDevice, phoneSpecs)
{
  result = merge(genderAgeDevice, phoneSpecs, by = "device_id", all.x = TRUE)
  return(result)
}