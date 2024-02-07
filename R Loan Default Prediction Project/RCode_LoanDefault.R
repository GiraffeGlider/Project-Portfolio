# Load necessary libraries
library(nloptr)
library(dplyr)
library(gplots)
library(car)
library(forcats)
library(effects)
library(corrplot)

# Load custom functions for binning variables and other analyses from a source file
source("BCA_functions_source_file.R")

# Read loan default data from a CSV
loan <- read.csv("LoanDefault.csv", stringsAsFactors = TRUE)
# Set row names of loan data frame to customer ID and remove CustID
rownames(loan) <- loan$CustID
loan$CustID <- NULL

# Calculate correlation matrix for numeric variables, plot correlation matrix
cor_loan <- cor(select_if(loan, is.numeric))
corrplot(cor_loan, method = 'number', 
         type = 'lower', 
         diag = FALSE, 
         number.cex = 0.7)

#################

# Convert cat variable to numeric binary ('Yes' is 1 and 'No' is 0)
loan$DEFAULT.Num <- if_else(loan$DEFAULT == "Yes", 1, 0)

# Bin 'yrsaddrs' variable into 4 categories and plot mean of 'DEFAULT.Num' for each.
loan$yrsaddrs.Cat <- binVariable(loan$yrsaddrs, 
                                 bins = 4, 
                                 method = "proportions", 
                                 labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$yrsaddrs.Cat, data = loan)

# Bin for 'age', 'crcdebt', 'yremploy', 'income', 'mrtgebal', 'ncustbrch', 'ATMpcent', 'onlinefreq', 'othdebt', and 'carvalue'.
#age
loan$age.Cat <- binVariable(loan$age, bins = 4, 
                            method = "proportions", 
                            labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$age.Cat, data = loan)
#crcdebt
loan$crcdebt.Cat <- binVariable(loan$crcdebt, bins = 4, 
                                method = "proportions", 
                                labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$crcdebt.Cat, data = loan)
#yremply
loan$yremploy.Cat <- binVariable(loan$yremploy, bins = 4, 
                                 method = "proportions", 
                                 labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$yremploy.Cat, data = loan)
#income
loan$income.Cat <- binVariable(loan$income, bins = 4, 
                               method = "proportions", 
                               labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$income.Cat, data = loan)
#mrtgebal
loan$mrtgebal.Cat <- binVariable(loan$mrtgebal, bins = 4, 
                                 method = "proportions", 
                                 labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$mrtgebal.Cat, data = loan)
#ncustbrch
loan$ncustbrch.Cat <- binVariable(loan$ncustbrch, bins = 4,
                                  method = "proportions", 
                                  labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$ncustbrch.Cat, data = loan)
#ATMpcent
loan$ATMpcent.Cat <- binVariable(loan$ATMpcent, bins = 4, 
                                 method = "proportions", 
                                 labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$ATMpcent.Cat, data = loan)
#onlinefreq
loan$onlinefreq.Cat <- binVariable(loan$onlinefreq, bins = 4, 
                                   method = "proportions", 
                                   labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$onlinefreq.Cat, data = loan)
#othdebt
loan$othdebt.Cat <- binVariable(loan$othdebt, bins = 4, 
                                method = "proportions", 
                                labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$othdebt.Cat, data = loan)
# carvalue
loan$carvalue.Cat <- binVariable(loan$carvalue, bins = 4, 
                                 method = "proportions", 
                                 labels = NULL)
plotmeans(loan$DEFAULT.Num ~ loan$carvalue.Cat, data = loan)

# Convert 'BranchID' to factor & plot mean of 'DEFAULT.Num' by 'BranchID'.
loan$BranchID <- factor(loan$BranchID)
plotmeans(loan$DEFAULT.Num ~ loan$BranchID, data = loan)

# Plot the mean of 'DEFAULT.Num' by 'Education'.
plotmeans(loan$DEFAULT.Num ~ loan$Education, data = loan)

# Summary
variable.summary(loan)
glimpse(loan)


###################

# Create column for est and val samples, 50/50
loan$Sample <- create.samples(loan, est = 0.50, val = 0.50, rand.seed = 1)
table(loan$Sample)

# Fit log model using est sample to predict DEFAULT
Model1 <- glm(formula = DEFAULT ~ yrsaddrs + age + crcdebt 
              + yremploy + income + mrtgebal + ncustbrch + 
                Education + ATMpcent + onlinefreq + othdebt + carvalue, data = 
                filter(loan, Sample == "Estimation"), family = binomial(logit))

# Fit dif log model on entire dataset to compare
Model11 <- glm(formula = DEFAULT ~ yrsaddrs + age + crcdebt 
               + yremploy + income + mrtgebal + ncustbrch + 
                 Education + ATMpcent + onlinefreq + othdebt + carvalue, data = 
                 loan, family = binomial(logit))

summary(Model1)

# Fit a simple log model w/ est sample
model2 <- glm(formula = DEFAULT ~ yremploy + income + mrtgebal, data = 
                filter(loan, Sample == "Estimation"), family = binomial(logit))

summary(model2)

# ANOVA to compare log models
Anova(model2)
Anova(Model1)

# Plot effects of predictors Model1 & model2 on DEFAULT prob
plot(allEffects(Model1), type="response")
plot(allEffects(model2), type="response")

# Lift charts on validation set
lift.chart(modelList = c("Model1", "model2"), data = 
             filter(loan, Sample == "Validation"), targLevel = "Yes", trueResp 
           = 0.053, type = "cumulative", sub = "Validation Set")

lift.chart(modelList = c("Model1"), 
           data = filter(loan, Sample == "Validation"), targLevel = "Yes", trueResp 
           = 0.383, type = "cumulative", sub = "Validation Set")

lift.chart(modelList = c("Model1"), data = 
             filter(loan, Sample == "Validation"), targLevel = "Yes", trueResp 
           = 0.053, type = "incremental", sub = "Validation Set")

lift.chart(modelList = c("Model1"), data = 
             filter(loan, Sample == "Validation"), targLevel = "Yes", trueResp 
           = 0.383, type = "incremental", sub = "Validation Set")

# Rels b/w catvariables & DEFAULT
plot(loan$mrtgebal.Cat, loan$DEFAULT)
plot(loan$yremploy.Cat, loan$DEFAULT)
plot(loan$income.Cat, loan$DEFAULT)


######################################


# Predict prob of default w/ Model1 for the validation sample & calculate mean prediction
pred <- predict(Model1, filter(loan, Sample == "Validation"), type = "response")
mean(predict(Model1, filter(loan, Sample == "Validation"), type = "response"))

table(loan$DEFAULT)

# Predict default probabilities for the validation sample, get actual default status, and create combined data frame
pred <- predict(Model1, filter(loan, Sample == "Validation"), type = "response")
default <- filter(loan, Sample == "Validation")$DEFAULT
output <- data.frame(pred, default) %>% arrange(desc(pred))

table(output$default)

# Adjust  predictions by applying weights to balance proportion of actual defaults, calculate cumulative sums & normalize
output$weight <- ifelse(output$default == "Yes", 1, 10.34)  # Adjust weights based on proportion of 'Yes' in actual defaults
output$amount <- output$weight * 0.053                      # Calculate weighted amounts using actual default rate
output$newTot <- cumsum(output$amount)                      # Cumulative sum of weighted amounts
output$newTot <- output$newTot / 1.65                       # Normalize cumulative sums

# Bin sums into 10 intervals
output$newTot.Cat <- binVariable(output$newTot, 
                                 bins = 10, 
                                 method = "intervals", 
                                 labels = NULL)

# Write to  CSV file
write.csv(output, "output.csv", row.names=FALSE)



