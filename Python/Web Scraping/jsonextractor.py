# -*- coding: utf-8 -*-
"""
Created on Sat Jul  1 15:21:25 2017

@author: Rohit
"""
#{"displayAttributes":[{"name":"make","value":"Mitsubishi","displayName":"Make"},{"name":"model","value":"Pajero","displayName":"Model"},{"name":"year","value":"2007","displayName":"Year"},{"name":"mileage","value":"108,000 mi","displayName":"Mileage"},{"name":"fuelType","value":"Diesel","displayName":"Fuel Type"},{"name":"transmission","value":"Manual","displayName":"Transmission"},{"name":"bodyType","value":"SUV","displayName":"Body Type"},{"name":"engine","value":"2.5 litre","displayName":"Engine Size"},{"name":"roadTax","value":"","displayName":"Road Tax"},{"name":"NCT","value":"May 2018","displayName":"NCT Expiry"},{"name":"previousOwners","value":"2","displayName":"Previous Owners"},{"name":"country","value":"Ireland","displayName":"Country of Reg."}]}
import json
from pprint import pprint
import csv


#json_parsed = json.loads(displayAttributes)
#print()

#son_data=open("out1.JSON").read()

#with open("out1.json") as f:
    #for line in f:
        #data=json.loads(line)
        #print(data['displayAttributes'])
        #print(data)
# open a file for writing

car_data = open('cardata_10.csv', 'a+')

# create the csv writer object

csvwriter = csv.writer(car_data,delimiter=',')
    
with open("DoneDealFullExtractjsonBackup_RS.json") as f:
    for line in f:
        data_json=json.loads('{"displayAttributes":'+line+'}')
        data_to_write=[]
        data=data_json['displayAttributes']
        for i in range(0,len(data)):
            #print(data[i]['value'])
            data_to_write.append(data[i]['value'])
        csvwriter.writerow(data_to_write)
            
        #slice1=data[0]
        #print(data[0]['value'])
car_data.close()       
        