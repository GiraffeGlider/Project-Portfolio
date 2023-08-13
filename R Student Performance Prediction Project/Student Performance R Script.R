# Investigating Factors Influencing Higher Grades and Better Education
# Authors: Jaiden Angeles, Jordan Harjono, Russel Kwok, Ravleen Rattan, Arham Raza
# Date: April 14, 2023


#initializing RStudio
cat("\014")  # Clear Console
rm(list = ls(all.names = TRUE))# clear all
gc()
set.seed(12345678)
library(readr)
library(stargazer)
library(data.table)
library(PerformanceAnalytics)
library(curl)
library(pastecs)
library(glmnet)
library(pscl)
library(corrplot)
library(ggplot2)
library(logistf)
library(rms)
library(dplyr)
library(rpart)
library(rpart.plot)

###Kitchen Sink Model###
test <- student_performance_significiant <- CleanedMathDataFinal[,c("gender", "age", "address", "pstatus", "medu", "fedu", "mjob", "fjob", "reason", 
                                                                   "traveltime", "studytime", "schoolsup", "famsup", "activities", "higher", "romantic", 
                                                                   "famrel", "freetime", "goout", "dalc", "walc", "health", "absences", "G3", "G1", "G2")]
Mod2 <- lm(G3~ gender + age + address +pstatus + medu + fedu + mjob + fjob + reason +
             traveltime +studytime + schoolsup + famsup + activities + higher + romantic + 
             famrel +freetime + goout + dalc + walc + health + absences + G1 + G2, data=CleanedMathDataFinal)
summary(Mod2)

#################################################################################################
# H1: Relationship between Relationship Status and Final Grades
# DV: G3, IV: romantic
#################################################################################################

#making regression models
model3 <- lm(G3 ~ romantic + age + G2 + G1, data=CleanedMathDataFinal)
summary(model3)
AIC(model3)
#p-value: 2.2e-16
#AIC: 874.4817
#F-stat:  1226
#Adjusted R: 0.9332

model4 <-lm(G3 ~ romantic + age + gender + G2 + G1, data=CleanedMathDataFinal)
summary(model4)
AIC(model4)
#p-value: 2.2e-16
#AIC: 876.4816
#F-stat:978.2
#Adjusted R: 0.933
plot(lm(G3 ~ romantic + age + gender + G2 + G1, data=CleanedMathDataFinal))

model5 <-lm(G3 ~ romantic + age + gender + G2 + G1 + romantic*goout, data=CleanedMathDataFinal)
summary(model5)
AIC(model5)
#p-value: 2.2e-16
#AIC: 874.3292
#F-stat: 703.5
#Adjusted R: 0.9334 

library(stargazer)
stargazer(model3, model4, model5, type="text")
plot(model5)

#The best model is Model 3 due to its highest F-stat, lower AIC, and high adjusted R square

#################################################################################################
# H2: Impact of Sociability on Grades
# Models exploring impact of various sociability variables on final grade
# Model comparison based on AIC
#################################################################################################

model_KS <- lm(G3 ~ walc + dalc + goout + freetime + activities, data = CleanedMathDataFinal)
model_1 <- lm(G3 ~ goout + freetime + activities, data = CleanedMathDataFinal)
model_2 <- lm(G3 ~ G2 + walc + dalc + freetime + activities, data = CleanedMathDataFinal)
model_3 <- lm(G3 ~ walc + dalc + goout + activities, data = CleanedMathDataFinal)
par(mfrow = c(2,2))
plot(model_3)
model_4 <- lm(G3 ~ walc + dalc + goout + freetime, data = CleanedMathDataFinal)

# Compare the models using the summary() function
summary(model_1) #AIC: 1816.59, R2: 0.025, F-stat: 4.050, P-value:0.007
summary(model_2) #AIC: 1816.81, R2: 0.021, F-stat: 2.887, P-value:0.021
summary(model_3) #AIC: 1814.83, R2: 0.033, F-stat: 4.049, P-value:0.003
summary(model_4) #AIC: 1815.52, R2: 0.031, F-stat: 3.873, P-value:0.004
summary(model_KS) #AIC: 1816.59, R2: 0.025, F-stat: 3.281, P-value:0.007

# Compare the models using the AIC() function
aics <- AIC(model_1, model_2, model_3, model_4, model_KS)
aics

stargazer(model_1, model_2, model_3, model_4, model_KS, type = "text")

#model 3 has highest adjusted R2 value and lowest AIC value. Model 3 is a better fit for data. Goout is a significan variable
#P value of Model 3 <0 0.05, we can reject the null. However, 
#There is a negative relationship between goout and G3, we cannot reject the null hypothesis
#Students who spend more time on social activities like going out and drinking does not lead to higher grade

#################################################################################################
# H3: Does Longer Study Time Lead to Higher Grades?
# Investigating the influence of study time on final grades
###Key Variables Analyzed: DV(G3) and IV ()
#################################################################################################

mod1 <- lm(G3 ~ studytime + schoolsup, data=CleanedMathDataFinal)
summary(mod1)
AIC(mod1)
#p value: 1.268e-06
#AIC: 1799.502
#F stat: 14.12
#adjusted R square: 0.06956 

mod2 <- lm(G3 ~ studytime + schoolsup + G2, data=CleanedMathDataFinal)
summary(mod2)
AIC(mod2)
#p value: 2.2e-16
#AIC: 884.1434
#F stat:  1583
#adjusted R square: 0.9311 

mod3 <- lm(G3 ~ studytime + schoolsup + studytime*traveltime, data=CleanedMathDataFinal)
summary(mod3)
AIC(mod3)
#p value: 2.694e-06
#AIC: 1799.259
#F stat:  8.157
#adjusted R square: 0.07541 

stargazer(mod1, mod2, mod3, type="text")

#The best model is model 2 due to its lowest AIC, highest F-stat, and smallest P-value
plot(mod2)

#################################################################################################
# H4: Effect of Family-related Variables on Grades
# Initial exploratory data analysis: histograms and correlations
# Several regression models are built to identify the best predictors
### Key Variables Analyzed: DV(G3) and IV ()
#################################################################################################

#Checking Summary Statistics for Initial Analysis

#Creating histograms for all variables, so the variables can all be looked at
#for normality
histograms <- function(df) {
  # Create histogram plot
  par(mfrow = c(ceiling(sqrt(ncol(df))), ceiling(sqrt(ncol(df)))),
      mar = c(2, 2, 1, 1))
  for (i in 1:ncol(df)) {
    hist(df[[i]], main = colnames(df)[i], xlab = "")
  }
}
histograms(CleanedMathDataFinal)

#Creating a data table for the variables being investigated
table_summary = data.table(CleanedMathDataFinal$fedu, CleanedMathDataFinal$medu,
                           CleanedMathDataFinal$mjob, CleanedMathDataFinal$fjob, 
                           CleanedMathDataFinal$famsup, CleanedMathDataFinal$pstatus,
                           CleanedMathDataFinal$famrel, CleanedMathDataFinal$G3, 
                           CleanedMathDataFinal$G2, CleanedMathDataFinal$G1)

#Renaming the variables within the table
setnames(table_summary, c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"),
         c("FatherEducation", "MotherEducation", "MotherJob", "FatherJob",
           "FamSupport", "PStatus", "FamRel", "G3", "G2", "G1"))

#Creating a correlation table for the variables being investigated
cor(table_summary)
cor_table = cor(table_summary, use = "complete.obs")
corrplot(cor_table, method = "color")

#Checking for possible variables that could be interaction terms
cor(table_summary$FatherEducation, table_summary$MotherEducation)
cor(table_summary$MotherJob, table_summary$FatherEducation)
cor(table_summary$MotherEducation, table_summary$MotherJob)
cor(table_summary$FatherEducation, table_summary$FatherJob)

#Building the Model
FamilySupportModel1 = lm(G3 ~ FatherEducation + MotherEducation + MotherJob + FatherJob +
                           FamSupport + PStatus + FamRel + G2 + G1, 
                         data = table_summary)
#Viewing the Model
summary(FamilySupportModel1)

#Now starting with significant variables and doing forward stepwise

FamilySupportModel2 = lm((G3) ~
                           G2 + FamRel, data = table_summary)

summary(FamilySupportModel2)

#After stepwise, came to this final version of the model with significant variables

FamilySupportModel3 = lm(G3 ~ MotherEducation*FatherEducation + 
                           FatherEducation + MotherEducation + 
                           G2 + FamRel, data = table_summary)
summary(FamilySupportModel3)

#Plotting to function to check the check if any assumptions of regression model
#are violated
par(mfrow = c(2,2))
plot(FamilySupportModel3)
#looks pretty good, only problem could be the Scale-location plot
#but an apparent funnel/fan shape is not visible

#Checking the AIC for each model
AIC(FamilySupportModel1)
AIC(FamilySupportModel2)
AIC(FamilySupportModel3)

#Viewing all three models in stargazer for ease of comparison
stargazer(FamilySupportModel1, FamilySupportModel2, FamilySupportModel3, type = "text", font.size = "huge")
#Used Hypothesis testing to check which variables are significant
#Used F-stat to test overall significance to check whether at least more than one
#variable within the model is significant

#Creating Overall Model to check to see how a student can get the best grades
#Again here, starting with the kitchen sink model and then doing stepwise
HighestGrade1 = lm(G3 ~ G2 + G1+ absences + health + goout + freetime+
                     famrel + romantic + higher + activities + famsup + schoolsup +
                     studytime + traveltime + reason + fjob + mjob + fedu + medu +
                     pstatus + address + age + gender + walc + dalc, data = CleanedMathDataFinal)
summary(HighestGrade1)

#Stepwise and testing for interaction term
HighestGrade2 = lm(G3 ~ G2 + G1 + absences + health + goout + famrel + walc*dalc, 
                   data = CleanedMathDataFinal)
summary(HighestGrade2)

#Final Model
HighestGrade3 = lm(G3 ~ G2 + G1 + absences + health + goout + famrel, 
                   data = CleanedMathDataFinal)

summary(HighestGrade3)
plot(HighestGrade3)
stargazer(HighestGrade1, HighestGrade2, HighestGrade3, type = "text")
#Note: This is the best model created throughout all models

#Checking AIC for all variables
AIC(HighestGrade1)
AIC(HighestGrade2)
AIC(HighestGrade3)
#Model Three also has the best AIC

#Now What if students just want to pass the course
#Similarly we did an initial model that had all the variables from the previous 
#hypothesis we then tested other variables that may or may not contribute to the
#final model and came up with this final model
passfail = glm(pass ~  G2 + absences + health + goout + famrel +
                 studytime + traveltime, data = CleanedMathDataFinal, family = binomial)
stargazer(passfail, type = "text")
plot(passfail)

#previous models that did not contribute:

passfail2 = glm(pass ~  G2 + G1 + absences + health + goout +
                  famrel +
                  studytime + traveltime + studytime*traveltime + fjob, data = CleanedMathDataFinal, family = binomial)
summary(passfail2)

passfail3 = glm(pass ~  G2 + absences + health + goout +
                  famrel +
                  studytime + traveltime + goout*studytime + fjob, data = CleanedMathDataFinal, family = binomial)
summary(passfail3)
stargazer(passfail, passfail2, passfail3, type = "text")

#CART Model
#Used the best Logit model as the CART prediction model
dt = CleanedMathDataFinal[,c("pass", "G2", "absences", "health", "goout",
                             "famrel", "studytime", "traveltime")]
#shuffle the data
shuffle_index = sample(1:nrow(dt))
dt = dt[shuffle_index, ]
head(dt)

#80/20 split
#splitting the data at 80% to train and 20% to test
n_cut <- round(nrow(dt)*.8,0) # cutting at 80%
data_train <- dt[1:n_cut,1:8] # create the 80% to train
data_test <- dt[(n_cut+1):nrow(dt),1:8] # create the 20% to test

dim(data_train)
dim(data_test)

prop.table(table(data_train$pass))
prop.table(table(data_test$pass))

#building the actual model
fit = rpart(pass ~  G2 + absences + goout + famrel +
              studytime + traveltime, data = data_train, method = "class")

# plotting the model
rpart.plot(fit, extra = 106) # tree plotting

#prediction test data
predict_unseen <-predict(fit, data_test, type = 'class')

# Testing the people who passed vs didn't by creating the confusion matrix
ConfMatrix <- table(data_test$pass, predict_unseen)
ConfMatrix

#doing the 70/30 split model
n_cut2 <- round(nrow(dt)*.7,0) 
data_train2 <- dt[1:n_cut2,1:8] 
data_test2 <- dt[(n_cut2+1):nrow(dt),1:8]

dim(data_train2)
dim(data_test2)

prop.table(table(data_train2$pass))
prop.table(table(data_test2$pass))

fit2 = rpart(pass ~  G2 + absences + goout + famrel +
               studytime + traveltime, data = data_train, method = "class")

predict_unseen2 <-predict(fit2, data_test2, type = 'class')

ConfMatrix2 <- table(data_test2$pass, predict_unseen2)
ConfMatrix2

#################################################################################################
# H5: Do student surroundings affect their higher education decision?
# Investigating the influence of student environment variables on the decision for higher education
### Key Variables Analyzed: DV (Student Environment variables) and IV (Higher)
#################################################################################################

#Hypothesis Model
#A. Hypothesis Model - Creating a model with factors that indicate strong support which influence higher education (higher parental educational level, better family support, school support, gender, and urban residence).
logistic_model <- glm(higher ~ Medu + Fedu + famsup + schoolsup + address + Gender, 
                      data = Jaiden_sTextFile, family = binomial()) 

#Summarizing and plotting the model.
summary(logistic_model)
par(mfrow = c(2,2))
plot(logistic_model)
summary(Jaiden_sTextFile[c("higher", "Medu", "Fedu", "famsup", "schoolsup", "address", "Gender")]) #We chose these because we assumed, from reading papers and articles on higher education pursuance, that these are the reasonable factors leading to higher education.


#Stepwise Regression
#B. Kitchen Sink Model with all variables in dataset.
KitchenSM <- glm(higher ~  ., data = Jaiden_sTextFile, family = binomial())

#C. Stepwise Model 1
stepWised <- step(KitchenSM)


#Checking AICs
AIC(logistic_model) #AIC: 103.825
AIC(KitchenSM) #AIC: 115.951
AIC(stepWised) #AIC: 83.465


# Compare Kitchen Sink Model, Logistic Model, and Stepwise Models with stargazer.
stargazer(logistic_model, KitchenSM, stepWised, type = "text")
#Total observations: 352
#Log Likelihoods:
# Logistic model: -44.912   
# Kitchen Sink Model: -25.602   
# Stepwise Model: -30.515   


# LASSO Logistic Regression
x <- model.matrix(higher ~ ., data = Jaiden_sTextFile)
y <- Jaiden_sTextFile$higher

# Fit the LASSO model
set.seed(42)
lasso_model <- cv.glmnet(x, y, family = "binomial", alpha = 1, nfolds = 10)

# Get the coefficients for the best lambda
lasso_coef <- coef(lasso_model, s = lasso_model$lambda.min)

# Print the coefficients
print(lasso_coef)

