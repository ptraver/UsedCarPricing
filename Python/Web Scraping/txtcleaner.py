# -*- coding: utf-8 -*-
"""
Created on Sat Jul  1 14:05:50 2017

@author: Rohit
"""

import string
import json, codecs

#string1="{('displayAttributes', '[{"name":"make","value":"Audi","displayName":"Make"},{"name":"model","value":"A4","displayName":"Model"},{"name":"year","value":"2007","displayName":"Year"},{"name":"mileage","value":"","displayName":"Mileage"},{"name":"fuelType","value":"Diesel","displayName":"Fuel Type"},{"name":"transmission","value":"Manual","displayName":"Transmission"},{"name":"bodyType","value":"Saloon","displayName":"Body Type"},{"name":"engine","value":"1.9 litre","displayName":"Engine Size"},{"name":"roadTax","value":"","displayName":"Road Tax"},{"name":"NCT","value":"Apr 2018","displayName":"NCT Expiry"},{"name":"previousOwners","value":"2","displayName":"Previous Owners"},{"name":"country","value":"Ireland","displayName":"Country of Reg."},{"name":"maxSpeed","value":"199 km/h","displayName":"Max Speed"},{"name":"mpgCombined","value":"49 mpg","displayName":"Fuel Economy"},{"name":"cylinders","value":"4","displayName":"Cylinders"},{"name":"noughtToSixty","value":"11.2 sec","displayName":"0-60"},{"name":"tankCapacity","value":"70 litres","displayName":"Tank Capacity"},{"name":"vehicleHeight","value":"1,427 mm","displayName":"Height"},{"name":"vehicleLength","value":"4,586 mm","displayName":"Length"},{"name":"vehicleWidth","value":"1,937 mm","displayName":"Width"}],"}"


with open("DoneDeal.txt") as f:
    with open("DoneDeajsonformat80k.txt", "wb") as f1:
        for line in f:
            linewa=line.split("displayAttributes', '",1)[1]
            linejson=linewa.split(',"}',1)[0]
            #json.dump(linejson, codecs.getwriter('utf-8')(f), ensure_ascii=False)
            f1.write(linejson)
        f1.close()
    f.close()
    