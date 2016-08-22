##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This file contains utility functions to help prepare data for analysis
##
##--------------------------------------------

# Note: this lubridate package doesn't appear to install correctly when using
# R version 3.3.1
if('lubridate' %in% rownames(installed.packages()) == FALSE) {
  install.packages('lubridate')
}
library(lubridate)

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

# get hour of day from a timestamp string (e.g.)
# getHour = function(dtStamp){
# 
#   result = sapply(dtStamp, FUN = function(x){
#     hour(x)
#   })
#   return(result) 
# }

getDowCounts = function(data){
  dowTable = table(data.frame(list(device_id = data$device_id, dow = data$dow)))
  #head(timeWindowTable)
  #head(row.names(timeWindowTable))
  dowTableDf = as.data.frame.matrix(dowTable, row.names = row.names(dowTable))
  dowTableDf = cbind(device_id = row.names(dowTable), dowTableDf)
  #head(timeWindowDf)
  #names(timeWindowDf)
  names(dowTableDf) = c("device_id", 
                        "dowSunday",
                        "dowMonday",
                        "dowTuesday",
                        "dowWednesday",
                        "dowThursday",
                        "dowFriday",
                        "dowSaturday")
  return(dowTableDf)
}

getIsWeekendCounts = function(data = events_csv){
  isWeekendTable = table(data.frame(list(device_id = data$device_id, isWeekend = data$isWeekend)))
  #head(timeWindowTable)
  #head(row.names(timeWindowTable))
  isWeekendDf = as.data.frame.matrix(isWeekendTable, row.names = row.names(isWeekendTable))
  isWeekendDf = cbind(device_id = row.names(isWeekendTable), isWeekendDf)
  #head(timeWindowDf)
  #names(timeWindowDf)
  names(isWeekendDf) = c("device_id", "dayIsNotWeekend", "dayIsWeekend")
  return(isWeekendDf)
}

# get flag indicating if dtStamp is Saturday or Sunday
getIsWeekend = function(dtStamp)
{
  dow = getDow(dtStamp)
  
  result = sapply(dow, FUN = function(x){
    x == 1 || x == 7
  })
  return(result) 
}

getIsWeekend_Test = function()
{
  dtStamps = as.POSIXct(c('2016-08-09',
               '2016-08-10',
               '2016-08-11',
               '2016-08-12',
               '2016-08-13',
               '2016-08-14',
               '2016-08-15'))
  
  expected = c(FALSE,
               FALSE,
               FALSE,
               FALSE,
               TRUE,
               TRUE,
               FALSE)
  
  actual = getIsWeekend(dtStamps)
  
  stopifnot(all.equal(expected, actual))
}

loginfo('Running unit test getIsWeekend_Test')
getIsWeekend_Test()

# get time windows (e.g. "morning", "lunch", "evening", "late")
getTimeWindow = function(dtStamp){
  
  result = sapply(dtStamp, FUN = function(x)
  {
    hour = hour(x)
    
    if (hour >= 4 && hour < 11)   
    {
      return('morning')
    } else if (hour >= 11 && hour < 15)
    {
      return('lunch')
    } else if (hour >= 15 && hour < 18){
      return('afternoon')
    } else if (hour >= 18 && hour < 23) {
      return('evening')
    } else {
      return('late')
    }
  })
  
  return(as.factor(result))
}

getTimeWindow_Test = function()
{
  testItems = as.POSIXct(c('2016-01-01 23:00:00',
                           '2016-01-01 04:00:00',
                           '2016-01-01 11:00:00',
                           '2016-01-01 15:00:00',
                           '2016-01-01 18:00:00',
                           #
                           '2016-01-01 00:00:00',
                           '2016-01-01 05:00:00',
                           '2016-01-01 12:00:00',
                           '2016-01-01 16:00:00',
                           '2016-01-01 19:00:00'))
  
  expected = as.factor(c('late', 'morning', 'lunch', 'afternoon', 'evening',
                         'late', 'morning', 'lunch', 'afternoon', 'evening'))
  actual = getTimeWindow(testItems)
  
  stopifnot(all.equal(expected, actual))
}

loginfo('Running unit test getTimeWindow_Test')
getTimeWindow_Test()

getTimeWindowCounts = function(data){
  timeWindowTable = table(data.frame(list(device_id = data$device_id, timeWindow = data$timeWindow)))
  #head(timeWindowTable)
  #head(row.names(timeWindowTable))
  timeWindowDf = as.data.frame.matrix(timeWindowTable, row.names = row.names(timeWindowTable))
  timeWindowDf = cbind(device_id = row.names(timeWindowTable), timeWindowDf)
  #head(timeWindowDf)
  #names(timeWindowDf)
  
  return(timeWindowDf)
}

getNarrowDataFrame = function(data){
  dataNarrow = data.frame(data)
  dataNarrow$event_id = NULL
  dataNarrow$app_id = NULL
  dataNarrow$label_id = NULL
  #dataNarrow$is_active = NULL
  dataNarrow$longitude = NULL
  dataNarrow$latitude = NULL
  dataNarrow$timestamp = NULL
  dataNarrow$is_installed = NULL
  #dataNarrow$gender = NULL
  #dataNarrow$age = NULL
  dataNarrow$category = NULL
  
  dataNarrow$isWeekend = NULL
  dataNarrow$dow = NULL
  dataNarrow$timeWindow = NULL
  dataNarrow$hour = NULL
  
  # de-duplicate
  dataNarrow = unique(dataNarrow)
  
  return(dataNarrow)
}

getAppInstalledCounts = function(data) {
  result = aggregate(x = as.integer(data$is_installed), by = list(event_id = data$event_id),
                  FUN = function(x) {
                    return(sum(x))
                  })
  
  names(result) = c("event_id", "appCount")  
  return(result)
}

# transVector = c("三星","samsung",
#                 "天语","Ktouch",
#                 "海信","hisense",
#                 "联想","lenovo",
#                 "欧比","obi",
#                 "爱派尔","ipair",
#                 "努比亚","nubia",
#                 "优米","youmi",
#                 "朵唯","dowe",
#                 "黑米","heymi",
#                 "锤子","hammer",
#                 "酷比魔方","koobee",
#                 "美图","meitu",
#                 "尼比鲁","nibilu",
#                 "一加","oneplus",
#                 "优购","yougo",
#                 "诺基亚","nokia",
#                 "糖葫芦","candy",
#                 "中国移动","ccmc",
#                 "语信","yuxin",
#                 "基伍","kiwu",
#                 "青橙","greeno",
#                 "华硕","asus",
#                 "夏新","panosonic",
#                 "维图","weitu",
#                 "艾优尼","aiyouni",
#                 "摩托罗拉","moto",
#                 "乡米","xiangmi",
#                 "米奇","micky",
#                 "大可乐","bigcola",
#                 "沃普丰","wpf",
#                 "神舟","hasse",
#                 "摩乐","mole",
#                 "飞秒","fs",
#                 "米歌","mige",
#                 "富可视","fks",
#                 "德赛","desci",
#                 "梦米","mengmi",
#                 "乐视","lshi",
#                 "小杨树","smallt",
#                 "纽曼","newman",
#                 "邦华","banghua",
#                 "E派","epai",
#                 "易派","epai",
#                 "普耐尔","pner",
#                 "欧新","ouxin",
#                 "西米","ximi",
#                 "海尔","haier",
#                 "波导","bodao",
#                 "糯米","nuomi",
#                 "唯米","weimi",
#                 "酷珀","kupo",
#                 "谷歌","google",
#                 "昂达","ada",
#                 "聆韵","lingyun")
# 
# translations = data.frame(matrix(transVector, byrow = TRUE,  ncol = 2))
# 
# # TODO: come back to this if you have time (low priority)
# # When called with some of the test data (phoneSpecs in prepareData.R),
# # this is not returning English. Fix it
# translate = function(phoneBrand){
#     print(phoneBrand)
#     sapply(phoneBrand, FUN = function(x){
#       translationIndex = which(translations$X1 == x)
#       as.character(translations[translationIndex,2])
#     })
# }
# 
# translate_Test = function()
# {
#   brands = c("酷珀", "大可乐", "夏新")
#   expected = as.character(c("kupo", "bigcola", "panosonic"))
#   actual = as.character(translate(brands))
# 
#   stopifnot(all.equal(expected, actual))
# }

#translate_Test()