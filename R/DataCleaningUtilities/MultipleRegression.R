library(data.table)
library(ggplot2)
library(lubridate)
library(zipcode)
library(dplyr)
library(stringr)
library(sqldf)
library(car)
library(magrittr)
library(caTools)

auto_new <- read.csv("Cardata_7_july_2017_80k.csv", header=TRUE, stringsAsFactors = FALSE)

summary(auto_new)

#Removing NA's and blanks from columns.


#auto_new$model=as.factor(auto_new$model)
#auto_new$make=as.factor(auto_new$make)
#auto_new$fuelType=as.factor(auto_new$fuelType)
auto_new["newmileage"]<-as.double(0)
auto_new["age"]<-as.double(year(today())-auto_new$year)
#is.na(auto_new$mileage)<-0

auto_new=auto_new[is.na(auto_new$price)==FALSE,]
auto_new=auto_new[is.na(auto_new$make)==FALSE,]
auto_new=auto_new[is.na(auto_new$model)==FALSE,]
auto_new=auto_new[auto_new$make!="",]
auto_new=auto_new[auto_new$model!="",]

#Only taking data from year 2000 onwards.
auto_new=auto_new[auto_new$year>=as.double(2000) & auto_new$year<=as.double(2016),]

#Replacing NA's in mileage with 0's first

for(i in 1:length(auto_new$mileage))
{
  #print(i)
  
  if(is.na(auto_new$mileage[i])==TRUE)
  {
    auto_new$mileage[i]=as.double(0)
  }
  
}


#Replacing Mileage value less that 1000 with the average value of that make and model.

averageMileage<-function(auto_new_mani)
{
  for(j in 1:length(auto_new_mani$mileage))
  {
    if(auto_new_mani$mileage[j]<=as.double(1000)) #&& auto_new_mani$age[j]>=as.double(0))
    {
      
      #auto_new_mani$newmileage[j]=mean(auto_new_mani[auto_new_mani[, "make"] ==auto_new_mani$make[j] && auto_new_mani[, "model"] ==auto_new_mani$model[j] && auto_new_mani[, "year"] ==auto_new_mani$year[j] ,5])
      #print(mean(auto_new_mani[auto_new_mani[, "make"] ==as.integer(auto_new_mani$make[j]) && auto_new_mani[, "model"] ==as.integer(auto_new_mani$model[j]) && auto_new_mani[, "year"] ==as.double(auto_new_mani$year[j]) ,5]))
      #mean_mileage= subset(auto_new_mani$mileage,auto_new_mani[, "year"] ==auto_new_mani$year[j] & auto_new_mani$mileage>=as.double(1000)) 
      mean_mileage= subset(auto_new_mani$mileage,auto_new_mani$year ==auto_new_mani$year[j] & auto_new_mani$mileage>=as.double(1000)) 
      #print(mean(mean_mileage))
      auto_new_mani$newmileage[j]=as.double(mean(mean_mileage))
      #print(subset(auto_new_mani$mileage,auto_new_mani[, "make"] ==auto_new_mani$make[j] && auto_new_mani[, "model"] ==auto_new_mani$model[j]) )
    }
    else
    {
      
      auto_new_mani$newmileage[j]=as.double(auto_new_mani$mileage[j])
      
    }
  }
  
  return(auto_new_mani)
  
}


auto_new_ext<-averageMileage(auto_new)


#auto_new_Audi<-subset(auto_new_ext,auto_new_ext$make=="Audi")   #Volkswagen
auto_new_Audi<-subset(auto_new_ext,auto_new_ext$make=="Volkswagen")
auto_new_Audi<-auto_new_Audi[auto_new_Audi$price>=1000,]
auto_new_Audi<-auto_new_Audi[is.na(auto_new_Audi$fuelType)!=TRUE,]
auto_new_Audi<-auto_new_Audi[auto_new_Audi$fuelType!="",]
auto_new_Audi<-auto_new_Audi[is.na(auto_new_Audi$engine)!=TRUE,]
auto_new_Audi<-auto_new_Audi[auto_new_Audi$engine!="",]

#removing outlier rows
#auto_new_Audi<-auto_new_Audi[-c(58095,10706,25091,14814,52387,19561,9329,13764,58790,17356),]
#auto_new_Audi<-auto_new_Audi[auto_new_Audi$model!="R8",]
auto_new_Audi$model<-as.factor(auto_new_Audi$model)
#smp_size <- floor(0.90 * nrow(auto_new_Audi))

##Considering cars only having mileage greater than 1000 to avoid missing values

auto_new_Audi<-auto_new_Audi[auto_new_Audi$mileage>=1000,]


#removing outlier and the again fitting the model

auto_new_Audi<-auto_new_Audi[-c(70509,66699,62019,2776,23944,70715,67677,68485,5228),]


## set the seed to make your partition reproductible
set.seed(123)
#train_ind <- sample(seq_len(nrow(auto_new_Audi)), size = smp_size)

#train <- auto_new_Audi[train_ind, ]
#train$model<-factor(train$model)
#test <- auto_new_Audi[-train_ind, ]
#test$model<-factor(test$model)

#Train test split stratifying

train_rows = sample.split(auto_new_Audi$model, SplitRatio=0.9)
train = auto_new_Audi[ train_rows,]
test  = auto_new_Audi[train_rows==FALSE,]


#Multiple regression Model
#fit <- lm(price ~model+year+mileage, data=train)
#fit1 <- lm(price ~model+year+newmileage, data=train)
fit2<-lm(price ~model+year+newmileage+fuelType+engine, data=train)
fit3<-lm(log(price) ~model+year+newmileage+fuelType+engine, data=train)
fit4<-lm(log(price) ~model+log(year)+newmileage+fuelType+engine, data=train)
fit5<-lm(log(price) ~model+year+log(newmileage)+fuelType+engine, data=train)
fit6<-lm(log(price) ~model+log(year)+log(newmileage)+fuelType+engine, data=train)
fit7<-lm(log(price) ~model+age+log(newmileage)+fuelType+engine, data=train)
fit8<-lm(log(price) ~model+age+mileage+fuelType+engine, data=train)
fit9<-lm(price ~model+age+mileage+fuelType+engine, data=train)


#transformed value for model using BoxCox
trans<-as.double(0.2626263)
fit9.new<-lm(((price^trans-1)/trans) ~model+age+mileage+fuelType+engine, data=train)

#fit3<-lm(price ~model+year+log(newmileage)+fuelType+engine, data=train)
#fit4<-lm(price ~model+log(year)+log(newmileage)+fuelType+engine, data=train)
#fit5<-lm(price ~model+log(year)+log(newmileage)+fuelType+engine+age, data=train)
#fit2<-lm(price ~model+year+newmileage, data=train)

summary(fit9)
# Other useful functions 
coefficients(fit2) # model coefficients
confint(fit2, level=0.80) # CIs for model parameters 
fitted(fit2) # predicted values
residuals(fit2) # residuals
anova(fit2) # anova table 
vcov(fit2) # covariance matrix for model parameters 
influence(fit2) # regression diagnostics


# diagnostic plots 
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit9.new)



#new dataset for predicting values
#new_data_test <- data.frame(year=test$year,mileage=test$mileage,model=test$model)
#new_data_test1 <- data.frame(year=test$year,newmileage=test$newmileage,model=test$model)
new_data_test2 <- data.frame(year=test$year,newmileage=test$newmileage,model=test$model,fuelType=test$fuelType,engine=test$engine)
new_data_test5 <- data.frame(year=test$year,newmileage=log(test$newmileage),model=test$model,fuelType=test$fuelType,engine=test$engine)
new_data_test6 <- data.frame(year=log(test$year),newmileage=log(test$newmileage),model=test$model,fuelType=test$fuelType,engine=test$engine)
new_data_test7 <- data.frame(age=test$age,newmileage=log(test$newmileage),model=test$model,fuelType=test$fuelType,engine=test$engine)
new_data_test8 <- data.frame(age=test$age,mileage=test$mileage,model=test$model,fuelType=test$fuelType,engine=test$engine)
new_data_test9<- data.frame(age=test$age,mileage=test$mileage,model=test$model,fuelType=test$fuelType,engine=test$engine)
#new_data_test3 <- data.frame(year=test$year,newmileage=log(test$newmileage),model=test$model,fuelType=test$fuelType,engine=test$engine)
#new_data_test5 <- data.frame(year=test$year,newmileage=log(test$newmileage),model=test$model,fuelType=test$fuelType,engine=test$engine,age=test$age)




#prediction

#fit.pred<-predict(fit,new_data_,test)
#fit.pred1<-predict(fit1,new_data_test1)
fit.pred2<-predict(fit3,new_data_test2)
fit.pred5<-predict(fit5,new_data_test5)
fit.pred6<-predict(fit6,new_data_test6)
fit.pred7<-predict(fit7,new_data_test7)
fit.pred8<-predict(fit8,new_data_test8)
fit.pred9<-predict(fit9.new,new_data_test9)
#fit.pred3<-predict(fit3,new_data_test3)
#fit.pred5<-predict(fit5,new_data_test5)

#Result
View(data.frame(fit.pred9,test$year,test$price))
#View(data.frame(fit.pred3,test$year,test$price))


#plotting the result
plot(fit.pred9,test$price)


#removing outilers and again calculating the multiple regression
outlierTest(fit9)








