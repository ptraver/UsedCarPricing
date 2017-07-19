library(data.table)
library(ggplot2)
library(lubridate)
library(zipcode)
library(dplyr)
library(stringr)
library(sqldf)

auto_new <- read.csv("Cardata_7_july_2017_80k.csv", header=TRUE)

Summary(auto_new)

#Removing NA's and blanks from columns.


auto_new$model=as.factor(auto_new$model)
auto_new$make=as.factor(auto_new$make)
auto_new$fuelType=as.factor(auto_new$fuelType)
auto_new["newmileage"]<-as.double(0)
auto_new["age"]<-year(today())-auto_new$year
#is.na(auto_new$mileage)<-0

auto_new=auto_new[is.na(auto_new$price)==FALSE,]
auto_new=auto_new[is.na(auto_new$make)==FALSE,]
auto_new=auto_new[is.na(auto_new$model)==FALSE,]
auto_new=auto_new[auto_new$make!="",]
auto_new=auto_new[auto_new$model!="",]

#Only taking data from year 2000 onwards.
auto_new=auto_new[auto_new$year>=as.double(2000),]

#Replacing NA's in mileage with 0's first

for(i in 1:length(auto_new$mileage))
{
  #print(i)

  if(is.na(auto_new$mileage[i])==TRUE)
  {
    auto_new$mileage[i]=0
  }

}

#Replacing Mileage value less that 1000 with the average value of that make and model.

averageMileage<-function(auto_new_mani)
{
  for(j in 1:length(auto_new_mani$mileage))
  {
    if(auto_new_mani$mileage[j]<=as.double(1000) && auto_new_mani$age[j]>=as.double(0))
       {
      
        #auto_new_mani$newmileage[j]=mean(auto_new_mani[auto_new_mani[, "make"] ==auto_new_mani$make[j] && auto_new_mani[, "model"] ==auto_new_mani$model[j] && auto_new_mani[, "year"] ==auto_new_mani$year[j] ,5])
        #print(mean(auto_new_mani[auto_new_mani[, "make"] ==as.integer(auto_new_mani$make[j]) && auto_new_mani[, "model"] ==as.integer(auto_new_mani$model[j]) && auto_new_mani[, "year"] ==as.double(auto_new_mani$year[j]) ,5]))
        mean_mileage= subset(auto_new_mani$mileage,auto_new_mani[, "year"] ==auto_new_mani$year[j],na.rm=TRUE) 
        print(mean(mean_mileage))
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



View(auto_new_ext)










