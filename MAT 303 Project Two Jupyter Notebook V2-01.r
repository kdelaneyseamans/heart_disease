
print("This step will first install three R packages. Please wait until the packages are fully installed.")
print("Once the installation is complete, this step will print 'Installation complete!'")

install.packages("ResourceSelection")
install.packages("pROC")
install.packages("rpart.plot")

print("Installation complete!")

heart_data <- read.csv(file="heart_disease.csv", header=TRUE, sep=",")

# Converting appropriate variables to factors  
heart_data <- within(heart_data, {
   target <- factor(target)
   sex <- factor(sex)
   cp <- factor(cp)
   fbs <- factor(fbs)
   restecg <- factor(restecg)
   exang <- factor(exang)
   slope <- factor(slope)
   ca <- factor(ca)
   thal <- factor(thal)
})

head(heart_data, 10)

print("Number of variables")
ncol(heart_data)

print("Number of rows")
nrow(heart_data)

# Create the complete model
logit <- glm (target ~ age + trestbps + exang + thalach, data = heart_data, family = "binomial")

summary(logit)

library(ResourceSelection)


print("Hosmer-Lemeshow Goodness of Fit Test")
hl = hoslem.test(logit$y, fitted(logit), g=50)
hl

conf_int <- confint.default(logit, level=0.95)
round(conf_int,4)

# Predict heart disease or no heart disease for the data set using the model
target_data <- heart_data[c('age', 'trestbps', 'exang', 'thalach')]
pred <- predict(logit, newdata=target_data, type='response')

# If the predicted probability of heart disease is >=0.50 then predict heart disease (target='1'), otherwise predict no heart 
# disease (target='0') 
depvar_pred = as.factor(ifelse(pred >= 0.5, '1', '0'))

# This creates the confusion matrix
conf.matrix <- table(heart_data$target, depvar_pred)[c('0','1'),c('0','1')]
rownames(conf.matrix) <- paste("Actual", rownames(conf.matrix), sep = ": default=")
colnames(conf.matrix) <- paste("Prediction", colnames(conf.matrix), sep = ": default=")

# Print nicely formatted confusion matrix
print("Confusion Matrix")
format(conf.matrix,justify="centre",digit=2)

library(pROC)

labels <- heart_data$target
predictions <- logit$fitted.values

roc <- roc(labels ~ predictions)

print("Area Under the Curve (AUC)")
round(auc(roc),4)

print("ROC Curve")
# True Positive Rate (Sensitivity) and False Positive Rate (1 - Specificity)
plot(roc, legacy.axes = TRUE)

print("Prediction: age is 50(age=50), resting blood pressure of 122 (trestbps=122), has exercise induced angina (exang='1'), and a maximum heart rate of 140 (thalach=140)")
newdata1 <- data.frame(age=50, trestbps=122, exang="1", thalach=140)
pred1 <- predict(logit, newdata1, type='response')
round(pred1, 4)

print("Prediction: age is 50(age=50), resting blood pressure of 130 (trestbps=130), does not have exercise induced angina (exang='0'), and a maximum heart rate of 165 (thalach=165)")
newdata2 <- data.frame(age=50, trestbps=130, exang="0", thalach=165)
pred2 <- predict(logit, newdata2, type='response')
round(pred2, 4)

# Create the complete model
logit <- glm (target ~ age + trestbps + cp + thalach + I(age^2) + age:thalach, data = heart_data, family = "binomial")

summary(logit)

library(ResourceSelection)


print("Hosmer-Lemeshow Goodness of Fit Test")
hl = hoslem.test(logit$y, fitted(logit), g=50)
hl

conf_int <- confint.default(logit, level=0.95)
round(conf_int,4)

# Predict heart disease or no heart disease for the data set using the model
target_data <- heart_data[c('age', 'trestbps', 'cp', 'thalach')]
pred <- predict(logit, newdata=target_data, type='response')

# If the predicted probability of heart disease is >=0.50 then predict heart disease (target='1'), otherwise predict no heart 
# disease (target='0') 
depvar_pred = as.factor(ifelse(pred >= 0.5, '1', '0'))

# This creates the confusion matrix
conf.matrix <- table(heart_data$target, depvar_pred)[c('0','1'),c('0','1')]
rownames(conf.matrix) <- paste("Actual", rownames(conf.matrix), sep = ": default=")
colnames(conf.matrix) <- paste("Prediction", colnames(conf.matrix), sep = ": default=")

# Print nicely formatted confusion matrix
print("Confusion Matrix")
format(conf.matrix,justify="centre",digit=2)

library(pROC)

labels <- heart_data$target
predictions <- logit$fitted.values

roc <- roc(labels ~ predictions)

print("Area Under the Curve (AUC)")
round(auc(roc),4)

print("ROC Curve")
# True Positive Rate (Sensitivity) and False Positive Rate (1 - Specificity)
plot(roc, legacy.axes = TRUE)

print("Prediction: age is 50(age=50), resting blood pressure of 115 (trestbps=115), does not experience chest pain (cp='0'), and a maximum heart rate of 133 (thalach=133)")
newdata1 <- data.frame(age=50, trestbps=115, cp="0", thalach=133)
pred1 <- predict(logit, newdata1, type='response')
round(pred1, 4)

print("Prediction: age is 50(age=50), resting blood pressure of 125 (trestbps=125), experiences typical angina (cp='1'), and a maximum heart rate of 155 (thalach=155)")
newdata2 <- data.frame(age=50, trestbps=125, cp="1", thalach=155)
pred2 <- predict(logit, newdata2, type='response')
round(pred2, 4)

set.seed(6522048)

# Partition the data set into training and testing data
samp.size = floor(0.85*nrow(heart_data))

# Training set
print("Number of rows for the training set")
train_ind = sample(seq_len(nrow(heart_data)), size = samp.size)
train.data1 = heart_data[train_ind,]
nrow(train.data1)

# Testing set 
print("Number of rows for the validation set")
test.data1 = heart_data[-train_ind,]
nrow(test.data1)

set.seed(6522048)
library(randomForest)

# checking
#=====================================================================
train = c()
test = c()
trees = c()

for(i in seq(from=1, to=200, by=1)) {
    #print(i)
    
    trees <- c(trees, i)
    
    model_rf1 <- randomForest(target ~ age + sex + cp + trestbps + chol + restecg + exang + ca, data=train.data, ntree = i)
    
    train.data.predict <- predict(model_rf1, train.data, type = "class")
    conf.matrix1 <- table(train.data$target, train.data.predict)
    train_error = 1-(sum(diag(conf.matrix1)))/sum(conf.matrix1)
    train <- c(train, train_error)
    
    test.data.predict <- predict(model_rf1, test.data, type = "class")
    conf.matrix2 <- table(test.data$target, test.data.predict)
    test_error = 1-(sum(diag(conf.matrix2)))/sum(conf.matrix2)
    test <- c(test, test_error)
}
 
#matplot (trees, cbind (train, test), ylim=c(0,0.5) , type = c("l", "l"), lwd=2, col=c("magenta","skyblue"), ylab="Error", xlab="number of trees")
#legend('topright',legend = c('training set','testing set'), col = c("magenta","skyblue"), lwd = 2 )

plot(trees, train,type = "l",ylim=c(0,1.0),col = "magenta", xlab = "Number of Trees", ylab = "Classification Error")
lines(test, type = "l", col = "skyblue")
legend('topright',legend = c('training set','testing set'), col = c("magenta","skyblue"), lwd = 2 )

set.seed(6522048)
library(randomForest)
model_rf1 <- randomForest(target ~ age + sex + cp + trestbps + chol + restecg + exang + ca, data=train.data, ntree = 25)

# Confusion matrix
print("======================================================================================================================")
print('Confusion Matrix: TRAINING set based on random forest model built using 25 trees')
train.data.predict <- predict(model_rf1, train.data, type = "class")

# Construct the confusion matrix
conf.matrix <- table(train.data$target, train.data.predict)[,c('0','1')]
rownames(conf.matrix) <- paste("Actual", rownames(conf.matrix), sep = ": ")
colnames(conf.matrix) <- paste("Prediction", colnames(conf.matrix), sep = ": ")

# Print nicely formatted confusion matrix
format(conf.matrix,justify="centre",digit=2)


print("======================================================================================================================")
print('Confusion Matrix: TESTING set based on random forest model built using 25 trees')
test.data.predict <- predict(model_rf2, test.data, type = "class")

# Construct the confusion matrix
conf.matrix <- table(test.data$target, test.data.predict)[,c('0','1')]
rownames(conf.matrix) <- paste("Actual", rownames(conf.matrix), sep = ": ")
colnames(conf.matrix) <- paste("Prediction", colnames(conf.matrix), sep = ": ")

# Print nicely formatted confusion matrix
format(conf.matrix,justify="centre",digit=2)

set.seed(6522048)

# Partition the data set into training and testing data
samp.size = floor(0.80*nrow(heart_data))

# Training set
print("Number of rows for the training set")
train_ind = sample(seq_len(nrow(heart_data)), size = samp.size)
train.data1 = heart_data[train_ind,]
nrow(train.data1)

# Testing set 
print("Number of rows for the validation set")
test.data1 = heart_data[-train_ind,]
nrow(test.data1)

set.seed(6522048)
library(randomForest)

# Root mean squared error
RMSE = function(pred, obs) {
    return(sqrt( sum( (pred - obs)^2 )/length(pred) ) )
}


# checking
#=====================================================================
train = c()
test = c()
trees = c()

for(i in seq(from=1, to=80, by=1)) {
    trees <- c(trees, i)
    model_rf2 <- randomForest(thalach ~ age + sex + cp + trestbps + chol + restecg + exang + ca, data=train.data, ntree = i)
    
    pred <- predict(model_rf2, newdata=train.data, type='response')
    rmse_train <-  RMSE(pred, train.data$thalach)
    train <- c(train, rmse_train)
    
    pred <- predict(model_rf2, newdata=test.data, type='response')
     rmse_test <-  RMSE(pred, test.data$thalach)
    test <- c(test, rmse_test)
}
 
plot(trees, train,type = "l",ylim=c(0,50),col = "red", xlab = "Number of Trees", ylab = "Root Mean Squared Error")
lines(test, type = "l", col = "blue")
legend('topright',legend = c('training set','testing set'), col = c("red","blue"), lwd = 2 )

set.seed(6522048)
library(randomForest)
model_rf3 <- randomForest(thalach ~ age + sex + cp + trestbps + chol + restecg + exang + ca, data=train.data, ntree = 15)


# Root mean squared error
RMSE = function(pred, obs) {
    return(sqrt( sum( (pred - obs)^2 )/length(pred) ) )
}

print("======================================================================================================================")
print('Root Mean Squared Error: TRAINING set based on random forest model built using 15 trees')
pred <- predict(model_rf3, newdata=train.data, type='response')
RMSE(pred, train.data$thalach)


print("======================================================================================================================")
print('Root Mean Squared Error: TESTING set based on random forest model built using 15 trees')
pred <- predict(model_rf3, newdata=test.data, type='response')
RMSE(pred, test.data$thalach)
