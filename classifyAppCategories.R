
# category map data
categoryGreps = c("game","is_game",
               "^car$|car ","is_car",
               "travel","is_travel",
               "property","is_property",
               "industry","is_industry",
               "financ","is_finance")

# create category map
categoryGrepMap = matrix(categoryGreps, ncol = 2, byrow = TRUE)

# results in a summed categories like:
# app_id                      is_game is_car  is_travel is_property is_industry is_finance
# -1565639201954102762        7       1       0         0           0           0
# 7597109471855939753         7       3       0         0           0           0
# -8247985508175962904        6       0       0         0           0           0
# 5649685917389229484         6       1       0         0           0           0
getAppCategoryCounts = function(){
  app_labels_csv = read.csv('data/app_labels.csv',
                            numerals = 'warn.loss',
                            # use character class as we would otherwise lose precision
                            # (using 'numeric') with the size of app_id values
                            colClasses = c('character', NA))
  
  label_categories_csv = read.csv('data/label_categories.csv',
                                  numerals = 'warn.loss')
  
    
  newColumns = sapply(label_categories_csv$category, FUN = function(category){
    
    # initialize new column
    col = sapply(1:nrow(categoryGrepMap), FUN = function(row){
      found = length(grep(categoryGrepMap[row,1], category, ignore.case = TRUE)) > 0
      return(ifelse(found,1,0))
    })
    
    return(col)
  })
  
  tPosedColumns = t(newColumns)
  
  newColumns = as.data.frame.matrix(tPosedColumns)
  
  names(newColumns) = categoryGrepMap[,2]
  
  newColumns = cbind(label_id = label_categories_csv$label_id, newColumns)

  binLabelCategories = newColumns
  
  appCategories = merge(app_labels_csv, binLabelCategories, by = "label_id")
  
  # get the column indexes for summing,
  # "+ 2" is to skip the label_id and app_id columns
  catColumnIndexes = (1:nrow(categoryGrepMap)) + 2 
  
  appCategoryTotals = aggregate(appCategories[,catColumnIndexes], by = list(app_id = appCategories$app_id), FUN = function(x){
    sum(x)
  })
  
  return(appCategoryTotals)
}


