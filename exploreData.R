# explore a bit

plotAgeGroupPopularPhoneBrands = function(flatDataNoIds)
{
  
  # get phone brand counts
  pbTable = table(flatDataNoIds$phone_brand)
  # get top 5 most popular
  popularPhoneBrands = row.names(head(sort(pbTable, decreasing = TRUE), n = 5))
  # get age groups for most popular brands
  groupsForPopularBrands = flatDataNoIds[flatDataNoIds$phone_brand %in% popularPhoneBrands,]
  
  loginfo('Plot groups for 5 most popular phone brands')
  plot(data.frame(list(group = groupsForPopularBrands$group, 
                       device_model = factor(groupsForPopularBrands$phone_brand))
  ))  

}

plotAgeGroupPopularDeviceModels = function(flatDataNoIds)
{
  dmTable = table(flatDataNoIds$device_model)
  # get top 5 most popular
  popularDeviceModels = row.names(head(sort(dmTable, decreasing = TRUE), n = 5))
  # get age groups for most popular brands
  groupsForDeviceModels = flatDataNoIds[flatDataNoIds$device_model %in% popularDeviceModels,]
  
  loginfo('Plot groups for 5 most popular phone brands')
  plot(data.frame(list(group = groupsForDeviceModels$group, 
                       device_model = factor(groupsForDeviceModels$device_model))
  ))
}



