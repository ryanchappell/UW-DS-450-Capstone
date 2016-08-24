# Log Loss Evaluation Script.
# This needs to be run from within Azure R Script module and takes predicted probabilities and labeled group as input.
# Assumed input has phone_brand, device_model, Group and 12 probability columns

# Map input port 1 of R module to data frame variable. input port 2 is not utilized.
dat <- maml.mapInputPort(1) # class: data.frame
#dataset2 <- maml.mapInputPort(2) # class: data.frame


#Actual probability, 1 for labeled group, 0 for other groups
actual <- dat[,c('phone_brand','device_model','group')];
y <- actual;
y$Actual_F23. <- lapply(y$group,function(x) if(x=="F23-")  1 else 0);
y$Actual_F24.26 <- lapply(y$group,function(x) if(x=="F24-26")  1 else 0);
y$Actual_F27.28 <- lapply(y$group,function(x) if(x=="F27-F28")  1 else 0);
y$Actual_F29.32 <- lapply(y$group,function(x) if(x=="F29-32")  1 else 0);
y$Actual_F33.42 <- lapply(y$group,function(x) if(x=="F33-42")  1 else 0);
y$Actual_F43. <- lapply(y$group,function(x) if(x=="F43+")  1 else 0);
y$Actual_M22. <- lapply(y$group,function(x) if(x=="M22-")  1 else 0);
y$Actual_M23.26 <- lapply(y$group,function(x) if(x=="M23-26")  1 else 0);
y$Actual_M27.28 <- lapply(y$group,function(x) if(x=="M27-28")  1 else 0);
y$Actual_M29.31 <- lapply(y$group,function(x) if(x=="M29-31")  1 else 0);
y$Actual_M32.38 <- lapply(y$group,function(x) if(x=="M32-38")  1 else 0);
y$Actual_M39. <- lapply(y$group,function(x) if(x=="M39+")  1 else 0);

actual_1 <- y[,4:15];
actual_1 <-  apply(actual_1, c(1,2), function(x) as.numeric(x));
head(actual_1);


#Predicted probability, gettign only probability columns
predicted_1 <- dat[,4:15]
head(predicted_1);


#Log Loss function for multi-classification
multiloss <- function(predicted, actual){
   predicted_m <- as.matrix(predicted)
   # bound predicted by max value
   predicted_m <- apply(predicted_m, c(1,2), function(x) max(min((x), 1-10^(-15)), 10^(-15)))

   actual_m <- as.matrix(actual)
   score <- -sum(actual_m*log(predicted_m))/nrow(predicted_m)
   return(score)
 };

mlloss <- multiloss(predicted_1,actual_1);

#Returning the log loss value
output <- as.data.frame(c(mlloss));
output;
maml.mapOutputPort("output");