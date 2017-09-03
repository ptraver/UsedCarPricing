rm(list=ls())

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
require(Matrix)
require(data.table)
if (!require(vcd)) {
  install.packages('vcd') #Available in Cran. Used for its dataset with categorical values.
  require(vcd)
}
library(ggplot2)
library(plotly)
library(caret)
library(monomvn)
library(leaps)
library(quantreg)
library(caret)

#Reading the data from CSV file
auto_new <- read.csv("CarDataClean_Edited_RoadTax_EngineSize_09.csv", header=TRUE, stringsAsFactors = FALSE)

summary(auto_new)

#Removing NA's and blanks from columns.
auto_new["newmileage"]<-as.double(0)
auto_new["age"]<-as.double(year(today())-auto_new$year)
auto_new=auto_new[is.na(auto_new$price)==FALSE,]
auto_new=auto_new[is.na(auto_new$make)==FALSE,]
auto_new=auto_new[is.na(auto_new$model)==FALSE,]
auto_new=auto_new[auto_new$make!="",]
auto_new=auto_new[auto_new$model!="",]

#Only taking data from year 2005 onwards.
auto_new=auto_new[auto_new$year>=as.double(2005) & auto_new$year<=as.double(2014),]
auto_new=auto_new[auto_new$fuelType=="Diesel" | auto_new$fuelType=="Petrol",]
auto_new=auto_new[auto_new$transmission=="Automatic" | auto_new$transmission=="Manual",]
auto_new=auto_new[auto_new$bodyType!="",]
auto_new$fuelType<-as.factor(auto_new$fuelType)
auto_new$transmission<-as.factor(auto_new$transmission)

#Replacing NA's in mileage with 0's first
for(i in 1:length(auto_new$mileage))
{
  
  
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
      mean_mileage= subset(auto_new_mani$mileage,auto_new_mani$year ==auto_new_mani$year[j] & auto_new_mani$mileage>=as.double(1000)) 
      auto_new_mani$newmileage[j]=as.double(mean(mean_mileage))
      
    }
    else
    {
      
      auto_new_mani$newmileage[j]=as.double(auto_new_mani$mileage[j])
      
    }
  }
  
  return(auto_new_mani)
  
}

auto_new_ext<-averageMileage(auto_new)

# Working on the Volkswagen data subset
auto_new_subset<-subset(auto_new_ext,auto_new_ext$make=="Volkswagen")
auto_new_subset<-auto_new_subset[auto_new_subset$price>=1000,]
auto_new_subset<-auto_new_subset[is.na(auto_new_subset$fuelType)!=TRUE,]
auto_new_subset<-auto_new_subset[auto_new_subset$fuelType!="",]
auto_new_subset<-auto_new_subset[is.na(auto_new_subset$engine)!=TRUE,]
auto_new_subset<-auto_new_subset[auto_new_subset$engine!="",]
auto_new_subset$model<-as.factor(auto_new_subset$model)


#Considering cars only having mileage greater than 1000 to avoid missing values
auto_new_subset<-auto_new_subset[auto_new_subset$mileage>=1000 & auto_new_subset$mileage<=300000,]


#function for the model which has atleast specified number of cars
groupbymodel<-function(auto_data,minDP)
{
  unique_models<-unique(auto_data$model)
  auto_merge_Dp<-data.frame()
  
  for(m in 1:length(unique_models))
  {
    modelDp_count<-auto_data[auto_data$model==unique_models[m],]
    if(NROW(modelDp_count)>=minDP) #&& first_model==as.numeric(1))
    {
      modelDp_rows<-subset(auto_data,model==unique_models[m])
      auto_merge_Dp<-rbind(auto_merge_Dp,modelDp_rows)
     }
  }

  return(auto_merge_Dp)
  
}

#normalising the age column
range_age<-max(auto_new_subset$age)-min(auto_new_subset$age)
auto_new_subset$normed_age<-(auto_new_subset$age/range_age)
range_mileage<-max(auto_new_subset$newmileage)-min(auto_new_subset$newmileage)

auto_new_subset$normed_mileage<-((auto_new_subset$newmileage-min(auto_new_subset$newmileage))/range_mileage)

###Number of days calculation for NCT
#Change date format to yyyy-mm--dd
auto_new_subset$New_NCT = as.Date(auto_new_subset$NCT,'%d-%m-%Y')


#Calculate difference between NCT expiry date and current system date and add new NCT column
auto_new_subset$diff_in_days<- difftime(auto_new_subset$New_NCT,Sys.Date() , units = c("days"))
auto_new_subset$normed_NCT<-0
for(z in 1:length(auto_new_subset$diff_in_days))
{
  if(auto_new_subset$diff_in_days[z]<=0 || is.na(auto_new_subset$diff_in_days[z])==TRUE)
  {
    auto_new_subset$normed_NCT[z]<-0
  }
  else if(auto_new_subset$diff_in_days[z]<=30)
  {
    auto_new_subset$normed_NCT[z]<-0
  }
  
  else
  {
    auto_new_subset$normed_NCT[z]<-1
  }
}


auto_data_model<-groupbymodel(auto_new_subset,200)


#Again converting the model to factor as we have filtered out some enteries
auto_data_model$model<-as.factor(auto_data_model$model)


## set the seed to make your partition reproductible
set.seed(123)
for( k in 1:length(auto_data_model$age))
{
  auto_data_model$age_reci[k]<-(1/auto_data_model$age[k])
  
}

#transform newmileage and age using Boxcox and YeoJohnson transformation
summary(auto_data_model[,22:23])
preprocessParams <- preProcess(auto_data_model[,22:23], method=c("YeoJohnson"))
print(preprocessParams)
# transform the dataset using the parameters
transformed <- predict(preprocessParams, auto_data_model[,22:23])
# summarize the transformed dataset (note pedigree and age)
summary(transformed)
colnames(transformed) <- c("newmileage_tran", "age_tran")


#Add these columns to original data frame
auto_data_model$newmileage_tran<-transformed$newmileage_tran
auto_data_model$age_tran<-transformed$age_tran
auto_data_model$newmileage_sqrt<-sqrt(auto_data_model$newmileage)


#Split the the data in 90:10 ratio
train_rows = sample.split(auto_data_model$model, SplitRatio=0.9)
train = auto_data_model[ train_rows,]
train<-train[train$model=="Golf" | train$model=="Passat" | train$model=="Polo",]

test  = auto_data_model[train_rows==FALSE,]
test<-test[test$model=="Golf" | test$model=="Passat" | test$model=="Polo",]

sparse_matrix_model_train = sparse.model.matrix(price~model-1, data = train)
sparse_matrix_model_test = sparse.model.matrix(price~model-1, data = test)


sparse_matrix_auto_train<-data.frame(train,data.matrix(sparse_matrix_model_train))
sparse_matrix_auto_test<-data.frame(test,data.matrix(sparse_matrix_model_test))



#function to test multiple model on the formulas.
model_names_col<-c("lm")
runmultipleModels<-function(model_names)
{
  
  set.seed(123)
  
  #all formuals for testing 
  formula1<-price ~newmileage_tran+age_tran+engine+fuelType+modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT
  formula2<-log(price)~newmileage_tran+age_tran+engine+fuelType+modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT
  formula3<-log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+poly(newmileage,3)+engine+age+fuelType
  formula4<-log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+poly(newmileage,2)+engine+age+fuelType
  formula5<-log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+newmileage_sqrt+engine+age+fuelType
  
  #all test data dataframes according to the each model
  new_data_frame_1<-data.frame(modelGolf=sparse_matrix_auto_test$modelGolf,modelPassat=sparse_matrix_auto_test$modelPassat,modelPolo=sparse_matrix_auto_test$modelPolo,newmileage=sparse_matrix_auto_test$newmileage,engine=sparse_matrix_auto_test$engine,fuelType=sparse_matrix_auto_test$fuelType,age=sparse_matrix_auto_test$age,bodyType=sparse_matrix_auto_test$bodyType,transmission=sparse_matrix_auto_test$transmission,normed_NCT=sparse_matrix_auto_test$normed_NCT)
  new_data_frame_2<-data.frame(modelGolf=sparse_matrix_auto_test$modelGolf,modelPassat=sparse_matrix_auto_test$modelPassat,modelPolo=sparse_matrix_auto_test$modelPolo,newmileage_tran=sparse_matrix_auto_test$newmileage_tran,engine=sparse_matrix_auto_test$engine,fuelType=sparse_matrix_auto_test$fuelType,age_tran=sparse_matrix_auto_test$age_tran,bodyType=sparse_matrix_auto_test$bodyType,transmission=sparse_matrix_auto_test$transmission,normed_NCT=sparse_matrix_auto_test$normed_NCT)
  new_data_frame_3<-data.frame(modelGolf=sparse_matrix_auto_test$modelGolf,modelPassat=sparse_matrix_auto_test$modelPassat,modelPolo=sparse_matrix_auto_test$modelPolo,newmileage=sparse_matrix_auto_test$newmileage,engine=sparse_matrix_auto_test$engine,fuelType=sparse_matrix_auto_test$fuelType,age=sparse_matrix_auto_test$age,bodyType=sparse_matrix_auto_test$bodyType,transmission=sparse_matrix_auto_test$transmission,normed_NCT=sparse_matrix_auto_test$normed_NCT)
  new_data_frame_4<-data.frame(modelGolf=sparse_matrix_auto_test$modelGolf,modelPassat=sparse_matrix_auto_test$modelPassat,modelPolo=sparse_matrix_auto_test$modelPolo,newmileage=sparse_matrix_auto_test$newmileage,engine=sparse_matrix_auto_test$engine,fuelType=sparse_matrix_auto_test$fuelType,age=sparse_matrix_auto_test$age,bodyType=sparse_matrix_auto_test$bodyType,transmission=sparse_matrix_auto_test$transmission,normed_NCT=sparse_matrix_auto_test$normed_NCT)
  new_data_frame_5<-data.frame(modelGolf=sparse_matrix_auto_test$modelGolf,modelPassat=sparse_matrix_auto_test$modelPassat,modelPolo=sparse_matrix_auto_test$modelPolo,newmileage_sqrt=sparse_matrix_auto_test$newmileage_sqrt,engine=sparse_matrix_auto_test$engine,fuelType=sparse_matrix_auto_test$fuelType,age=sparse_matrix_auto_test$age,bodyType=sparse_matrix_auto_test$bodyType,transmission=sparse_matrix_auto_test$transmission,normed_NCT=sparse_matrix_auto_test$normed_NCT)
  
  
  fitControl <- trainControl(method = "repeatedcv",number = 10,repeats = 10)
  #Grid <- expand.grid(mtry = seq(4,16,4))
  first_formula_all_model_results<-data.frame()
  second_formula_all_model_results<-data.frame()
  third_formula_all_model_results<-data.frame()
  fourth_formula_all_model_results<-data.frame()
  fifth_formula_all_model_results<-data.frame()
  
  for(model in 1:length(model_names))
  {
    count_formula<-0
    #model_name<-paste(model_names[model],count,".RData", sep="")
    
    fit1<-train(price ~newmileage+age+engine+fuelType+modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT, data =sparse_matrix_auto_train, method =model_names[model],trControl = fitControl,max.iter=100)#,tau = 0.95, maxit = 10,mtry = seq(4,10,by=1))
    summary(fit1)
    count_formula<-count_formula+1
    predict.fit1<-predict(fit1,new_data_frame_1)
    model_name1<-paste(model_names[model],count_formula,".RData", sep="")
    predicted1<-paste(model_names[model],count_formula,"_predicted",".csv", sep="")
    print(model_name1)
    save(fit1,file = model_name1)
    #save(data.frame(predict.fit1,sparse_matrix_auto_test),file=predicted1)
    
    fit2<-train(log(price) ~newmileage_tran+age_tran+engine+fuelType+modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT, data = sparse_matrix_auto_train, method =model_names[model],trControl = fitControl,max.iter=100)
    summary(fit2)
    count_formula<-count_formula+1
    predict.fit2<-predict(fit2,new_data_frame_2)
    model_name2<-paste(model_names[model],count_formula,".RData", sep="")
    predicted2<-paste(model_names[model],count_formula,"_predicted",".csv", sep="")
    save(fit2,file = model_name2)
    #save(data.frame(predict.fit2,sparse_matrix_auto_test),file=predicted2)
    
    fit3<-train(log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+poly(newmileage,3)+engine+age+fuelType, data = sparse_matrix_auto_train, method =model_names[model],trControl = fitControl,max.iter=100)#,tau = 0.95, maxit = 10,mtry = seq(4,10,by=1))
    summary(fit3)
    count_formula<-count_formula+1
    predict.fit3<-predict(fit3,new_data_frame_3)
    model_name3<-paste(model_names[model],count_formula,".RData", sep="")
    predicted3<-paste(model_names[model],count_formula,"_predicted",".csv", sep="")
    save(fit3,file = model_name3)
    #save(data.frame(predict.fit3,sparse_matrix_auto_test),file=predicted3)
    
    fit4<-train(log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+poly(newmileage,2)+engine+age+fuelType, data = sparse_matrix_auto_train, method =model_names[model],trControl = fitControl,max.iter=100)#,tau = 0.95, maxit = 10,mtry = seq(4,10,by=1))
    summary(fit4)
    count_formula<-count_formula+1
    predict.fit4<-predict(fit4,new_data_frame_4)
    model_name4<-paste(model_names[model],count_formula,".RData", sep="")
    predicted4<-paste(model_names[model],count_formula,"_predicted",".csv", sep="")
    save(fit4,file = model_name4)
    #save(data.frame(predict.fit4,sparse_matrix_auto_test),file=predicted4)
    
    
    fit5<-train(log(price)~modelGolf+modelPassat+modelPolo+bodyType+transmission+normed_NCT+newmileage_sqrt+engine+age+fuelType, data = sparse_matrix_auto_train, method =model_names[model],trControl = fitControl,max.iter=100)#,tau = 0.95, maxit = 10,mtry = seq(4,10,by=1))
    summary(fit5)
    count_formula<-count_formula+1
    predict.fit5<-predict(fit5,new_data_frame_5)
    model_name5<-paste(model_names[model],count_formula,".RData", sep="")
    predicted5<-paste(model_names[model],count_formula,"_predicted",".csv", sep="")
    save(fit5,file = model_name5)
    #save(data.frame(predict.fit5,sparse_matrix_auto_test),file=predicted5)
    
    #Calculation for all formulas
    
    #Calculation for 1st formula
    #print(predict.fit1$results)
    abs_error_percent<<-abs((((data.frame(predict.fit1))-sparse_matrix_auto_test$price)/sparse_matrix_auto_test$price)*100)
    Frequency<-abs(predict.fit1)
    z<- sparse_matrix_auto_test$price
    Percentage_of_absolute_error<-abs(Frequency-z)/z*100
    Residual_price_in_euro <-Frequency-z
    sum_pred_price<-sum(predict.fit1)
    mean_error<-mean(((((predict.fit1)- sparse_matrix_auto_test$price))))
    mean_absolute_error<-mean(((abs(abs(predict.fit1)- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))
    mean_absolute_error_per<-mean(((abs(abs(predict.fit1)- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    sd_price<-sd(predict.fit1)
    sd_error<-sd(((((predict.fit1)- sparse_matrix_auto_test$price))))
    sd_absolute_error<-sd(((abs(abs(predict.fit1)- sparse_matrix_auto_test$price))))
    sd_absolute_error_per<-sd(((abs(abs(predict.fit1)- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    result_1<-data.frame(sum_pred_price,mean_error,mean_absolute_error,mean_absolute_error_per,sd_price,sd_error,sd_absolute_error,sd_absolute_error_per,fit1$results)
    write.csv(data.frame(predict.fit1,abs_error_percent,Residual_price_in_euro,sparse_matrix_auto_test),file=predicted1)
    
    #calculation for second formula
    abs_error_percent<<-abs(((exp(data.frame(predict.fit2))-sparse_matrix_auto_test$price)/sparse_matrix_auto_test$price)*100)
    Frequency<-abs((exp(predict.fit2)))
    z<- sparse_matrix_auto_test$price
    Percentage_of_absolute_error<-abs(Frequency-z)/z*100
    Residual_price_in_euro <-Frequency-z
    sum_pred_price<-sum(exp(predict.fit2))
    mean_error<-mean(((((exp(predict.fit2))- sparse_matrix_auto_test$price))))
    mean_absolute_error<-mean(((abs(abs(exp(predict.fit2))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))
    mean_absolute_error_per<-mean(((abs(abs(exp(predict.fit2))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    sd_error<-sd(((((exp(predict.fit2))- sparse_matrix_auto_test$price))))
    sd_absolute_error<-sd(((abs(abs(exp(predict.fit2))- sparse_matrix_auto_test$price))))
    sd_absolute_error_per<-sd(((abs(abs(exp(predict.fit2))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    result_2<-data.frame(sum_pred_price,mean_error,mean_absolute_error,mean_absolute_error_per,sd_price,sd_error,sd_absolute_error,sd_absolute_error_per,fit2$results)
    write.csv(data.frame(exp(predict.fit2),abs_error_percent,Residual_price_in_euro,sparse_matrix_auto_test),file=predicted2)
    
    #calculation for third formula
    abs_error_percent<<-abs(((exp(data.frame(predict.fit3))-sparse_matrix_auto_test$price)/sparse_matrix_auto_test$price)*100)
    Frequency<-abs((exp(predict.fit3)))
    z<- sparse_matrix_auto_test$price
    Percentage_of_absolute_error<-abs(Frequency-z)/z*100
    Residual_price_in_euro <-Frequency-z
    sum_pred_price<-sum(exp(predict.fit3))
    mean_error<-mean(((((exp(predict.fit3))- sparse_matrix_auto_test$price))))
    mean_absolute_error<-mean(((abs(abs(exp(predict.fit3))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))
    mean_absolute_error_per<-mean(((abs(abs(exp(predict.fit3))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    sd_error<-sd(((((exp(predict.fit3))- sparse_matrix_auto_test$price))))
    sd_absolute_error<-sd(((abs(abs(exp(predict.fit3))- sparse_matrix_auto_test$price))))
    sd_absolute_error_per<-sd(((abs(abs(exp(predict.fit3))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    result_3<-data.frame(sum_pred_price,mean_error,mean_absolute_error,mean_absolute_error_per,sd_price,sd_error,sd_absolute_error,sd_absolute_error_per,fit3$results)
    write.csv(data.frame(exp(predict.fit3),abs_error_percent,Residual_price_in_euro,sparse_matrix_auto_test),file=predicted3)
    
    #calculation for fourth formula
    abs_error_percent<<-abs(((exp(data.frame(predict.fit4))-sparse_matrix_auto_test$price)/sparse_matrix_auto_test$price)*100)
    Frequency<-abs((exp(predict.fit4)))
    z<- sparse_matrix_auto_test$price
    Percentage_of_absolute_error<-abs(Frequency-z)/z*100
    Residual_price_in_euro <-Frequency-z
    sum_pred_price<-sum(exp(predict.fit4))
    mean_error<-mean(((((exp(predict.fit4))- sparse_matrix_auto_test$price))))
    mean_absolute_error<-mean(((abs(abs(exp(predict.fit4))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))
    mean_absolute_error_per<-mean(((abs(abs(exp(predict.fit4))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    sd_error<-sd(((((exp(predict.fit4))- sparse_matrix_auto_test$price))))
    sd_absolute_error<-sd(((abs(abs(exp(predict.fit4))- sparse_matrix_auto_test$price))))
    sd_absolute_error_per<-sd(((abs(abs(exp(predict.fit4))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    result_4<-data.frame(sum_pred_price,mean_error,mean_absolute_error,mean_absolute_error_per,sd_price,sd_error,sd_absolute_error,sd_absolute_error_per,fit4$results)
    write.csv(data.frame(exp(predict.fit4),abs_error_percent,Residual_price_in_euro,sparse_matrix_auto_test),file=predicted4)
    
    #calculation for fifth formula
    abs_error_percent<<-abs(((exp(data.frame(predict.fit5))-sparse_matrix_auto_test$price)/sparse_matrix_auto_test$price)*100)
    Frequency<-abs((exp(predict.fit5)))
    z<- sparse_matrix_auto_test$price
    Percentage_of_absolute_error<-abs(Frequency-z)/z*100
    Residual_price_in_euro <-Frequency-z
    sum_pred_price<-sum(exp(predict.fit5))
    mean_error<-mean(((((exp(predict.fit5))- sparse_matrix_auto_test$price))))
    mean_absolute_error<-mean(((abs(abs(exp(predict.fit5))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))
    mean_absolute_error_per<-mean(((abs(abs(exp(predict.fit5))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    sd_error<-sd(((((exp(predict.fit5))- sparse_matrix_auto_test$price))))
    sd_absolute_error<-sd(((abs(abs(exp(predict.fit5))- sparse_matrix_auto_test$price))))
    sd_absolute_error_per<-sd(((abs(abs(exp(predict.fit5))- sparse_matrix_auto_test$price))/sparse_matrix_auto_test$price))*100
    result_5<-data.frame(sum_pred_price,mean_error,mean_absolute_error,mean_absolute_error_per,sd_price,sd_error,sd_absolute_error,sd_absolute_error_per,fit5$results)
    write.csv(data.frame(exp(predict.fit5),abs_error_percent,Residual_price_in_euro,sparse_matrix_auto_test),file=predicted5)
    
    
    model_metrics<-rbind(result_1,result_2,result_3,result_4,result_5)
    model_metrics_filename<-paste(model_names[model],"_metrics_summary",".csv",sep="")
    write.csv(model_metrics,file=model_metrics_filename)
    
    
    first_formula_all_model_results<-rbind(first_formula_all_model_results,result_1)
    second_formula_all_model_results<-rbind(second_formula_all_model_results,result_2)
    third_formula_all_model_results<-rbind(third_formula_all_model_results,result_3)
    fourth_formula_all_model_results<-rbind(fourth_formula_all_model_results,result_4)
    fifth_formula_all_model_results<-rbind(fifth_formula_all_model_results,result_5)
    
    
    
    print("model Number")
    print(model)
    
    
    
  }
  
  write.csv(first_formula_all_model_results,"firstformulaallmodelresults.csv")
  write.csv(second_formula_all_model_results,"secondformulaallmodelresults.csv")
  write.csv(third_formula_all_model_results,"thirdformulaallmodelresults.csv")
  write.csv(fourth_formula_all_model_results,"fourthformulaallmodelresults.csv")
  write.csv(fifth_formula_all_model_results,"fifthformulaallmodelresults.csv")
  
  
  
  if(model==length(model_names))
  {
    return("Success")
  }
  else
  {
    
    return("Failure")
  }
  
  
}



model_run_result<-runmultipleModels(model_names_col)


















