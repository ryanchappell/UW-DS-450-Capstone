# age device exploration

head(trainDataNarrow)


deviceGenderSums = table(trainDataNarrow$gender)
deviceAgeSums = table(trainDataNarrow$age)

plot(deviceAgeSums)
