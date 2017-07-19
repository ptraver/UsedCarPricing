# -*- coding: utf-8 -*-
"""
Created on Sun Jul  2 01:49:45 2017

@author: Rohit
"""

import json
from pprint import pprint
import csv
# open a file for writing

car_data = open('cardata_12.csv', 'a+')

# create the csv writer object

csvwriter = csv.writer(car_data,delimiter=',')

with open("DoneDealjsonformat80k.json") as f:
    for line in f:
        data_json=json.loads(line)
        data_to_write=[]
        data=data_json['displayAttributes']
        dataprice=data_json['price']
        data_to_write.append(dataprice)
        for i in range(0,len(data)):
            #print(data[i]['value'])
            data_to_write.append(data[i]['value'])
        
        csvwriter.writerow(data_to_write)
            
        #slice1=data[0]
        #print(data[0]['value'])
car_data.close() 