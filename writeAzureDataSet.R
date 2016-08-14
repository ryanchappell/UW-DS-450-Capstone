aggDf = data.frame(list(device_id = flatData$device_id, 
                        phone_brand = flatData$phone_brand, 
                        device_model = flatData$device_model,
                        group = flatData$group))

uniqueAggDf = unique(aggDf)

write.csv(uniqueAggDf, 'output/aggDf.csv')