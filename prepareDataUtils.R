##--------------------------------------------
## Ryan Chappell
## UW 450 Capstone project
##
## This file contains utility functions to help prepare data for analysis
##
##--------------------------------------------

##
## TODO: review which of these should be in INNER JOIN
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

# function to consolidate categories,
# - multiple category instances, e.g. 'unknown' and 'unknown'	
# - cased categories, e.g. 'teahouse' and 'Teahouse'
# - pluralized categories, e.g. 'show' and 'shows'		
# - possibly similiar categories, e.g. 'Smart Shopping' and 'Smart Shopping 1'
# - empty categories, e.g. ''
consolidateCategories = function(categories)
{
  # TODO: finish this up
  
  # conslidate casing
  categories = tolower(categories)
  
  loginfo(paste0('category count: ', length(categories)))
  categories = unique(categories)
  
  loginfo(paste0('unique category count: ', length(categories)))
  
  sapply(categories, FUN = function(x){
    #print(x)
    if (!endsWith(x = as.character(x), suffix = 's')){
      print(as.character(x))
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