# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 16:13:36 2017

@author: Rohit
"""

import urllib, json
from sys import argv
import requests
htmlresponse= urllib.request.urlopen("https://www.donedeal.ie/cars-for-sale/2007-ford-smax-1-8d-153k-kms-fresh-nct/15754729?campaign=3")
#data = json.loads(htmlresponse.read())
#print(data)
htm=htmlresponse.read()
htm
info = json.loads(str(htm))
print(info)

#target = open("output.html",'w')
#target.write
 
 
import urllib.request, json 
with urllib.request.urlopen("https://www.donedeal.ie/cars-for-sale/2007-ford-smax-1-8d-153k-kms-fresh-nct/15754729?campaign=3") as url:
    data = json.loads(url.read().decode())
    #print(data)
    
import requests

jstr=requests.get("https://www.donedeal.ie/cars-for-sale/2007-ford-smax-1-8d-153k-kms-fresh-nct/15754729?campaign=3").json()


import sys, json
struct = {}

dataform = str(data).strip("'<>() ").replace('\'', '\"')
struct = json.loads(dataform)
 
print(dataform)

from scrapy.http import FormRequest

url = 'https://www.donedeal.ie/cars-for-sale/2007-ford-smax-1-8d-153k-kms-fresh-nct/15754729?campaign=3'
payload = {'action': 'displayAttributes', 'make':'0'}

req = FormRequest(url, formdata=payload)
#fetch(req)

import scrapy
selector = scrapy.Selector(text=""+ htm + "")

import re
JSON = re.compile('window.adDetails = ({.*?});', re.DOTALL)

matches = JSON.search(htm)

print(matches.group(1))


import re, json






