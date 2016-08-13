##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This file contains utility functions to help prepare data for analysis
##
##--------------------------------------------

# Note: this lubridate package doesn't appear to install correctly when using
# R version 3.3.1
install.packages('lubridate')
library(lubridate)

##
## TODO: review which of these below merge functions 
## should be in INNER JOIN
##

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

# TODO: come back to this if you have time (low priority)
consolidateCategories = function(categories)
{
  # conslidate casing
  categories = tolower(categories)
  
  loginfo(paste0('category count: ', length(categories)))
  categories = unique(categories)
  
  loginfo(paste0('unique category count: ', length(categories)))
  
  sapply(categories, FUN = function(x){
    #print(x)
    if (!endsWith(x = as.character(x), suffix = 's')){
      #print(as.character(x))
    }
    return()
  })
}

consolidateCategories_Test = function()
{
  cats = c('unknown', 'Unknown', 'show', 'shows')
  expected = c('unknown', 'unknown', 'show', 'show')
  actual = consolidateCategories(cats)
  
  stopifnot(all.equal(expected, actual))
}

# get the day of week from a timestamp string (e.g.)
getDow = function(dtStamp){
  return(wday(dtStamp))  
}

# get time windows (e.g. "morning", "lunch", "evening", "late")
getTimeWindow = function(dtStamp){
  
  result = sapply(dtStamp, FUN = function(x)
  {
    hour = hour(x)
    
    if (hour >= 4 && hour < 11)   
    {
      return('morning')
    } else if (hour >= 11 && hour < 3)
    {
      return('lunch')
    } else if (hour >= 3 && hour < 6){
      return('afternoon')
    } else if (hour >= 6 && hour < 11) {
      return('evening')
    } else {
      return('late')
    }
  })
  
  return(as.factor(result))
}

# TODO: come back to this if you have time (low priority)
translate = function(phoneBrand){
  # TODO: finish this function, 
  # also, keep both Chinese and English
  # in resulting data (possibly improve connections with
  # external, extra-competition data)
  
  translations = c("三星","samsung",
    "天语","Ktouch",
    "海信","hisense",
    "联想","lenovo",
    "欧比","obi",
    "爱派尔","ipair",
    "努比亚","nubia",
    "优米","youmi",
    "朵唯","dowe",
    "黑米","heymi",
    "锤子","hammer",
    "酷比魔方","koobee",
    "美图","meitu",
    "尼比鲁","nibilu",
    "一加","oneplus",
    "优购","yougo",
    "诺基亚","nokia",
    "糖葫芦","candy",
    "中国移动","ccmc",
    "语信","yuxin",
    "基伍","kiwu",
    "青橙","greeno",
    "华硕","asus",
    "夏新","panosonic",
    "维图","weitu",
    "艾优尼","aiyouni",
    "摩托罗拉","moto",
    "乡米","xiangmi",
    "米奇","micky",
    "大可乐","bigcola",
    "沃普丰","wpf",
    "神舟","hasse",
    "摩乐","mole",
    "飞秒","fs",
    "米歌","mige",
    "富可视","fks",
    "德赛","desci",
    "梦米","mengmi",
    "乐视","lshi",
    "小杨树","smallt",
    "纽曼","newman",
    "邦华","banghua",
    "E派","epai",
    "易派","epai",
    "普耐尔","pner",
    "欧新","ouxin",
    "西米","ximi",
    "海尔","haier",
    "波导","bodao",
    "糯米","nuomi",
    "唯米","weimi",
    "酷珀","kupo",
    "谷歌","google",
    "昂达","ada",
    "聆韵","lingyun")
}