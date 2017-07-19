# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 21:20:40 2017

@author: Rohit
"""

import scrapy
import re
from scrapy.item import Item, Field

class DoneDealItem(Item):
    Link=Field()
    Make=Field()
    MianPageUrl = Field()

class mydonedealspider(scrapy.Spider):
    name = "tutorial"
    allowed_domains = ["imdb.com"]
    start_urls = ["https://www.donedeal.ie/cars"] 
    def parse(self, response):
        self.wanted_num=10
        print(response)
        #*[contains(@class,'chart')]/tbody/tr   ("//div/ul(contains@class,'card-collection']"):
        
        for sel in response.xpath('//li[@class=".card-item")]'):
            print("success")
            item = DoneDealItem()
            item['Link'] = sel.xpath('//a/@href').extract()[0]
            print("URL",sel.xpath('//a/text()').extract()[0])
            item['MianPageUrl']=item['Link']
            request = scrapy.Request(item['MianPageUrl'], callback=self.parseCarDetails)
            request.meta['item'] = item
            yield request
    def parseCarDetails(self, response):
        return
    
            
    #def parseCarDetails(self, response):
        #item = response.meta['item']
        #item = self.getBasicCarInfo(item, response)
    
    #def getBasicCarInfo(self, item, response):
        #item['Make'] = response.xpath("//div/span[@itemprop='director']/a/span/text()").extract()
        
		
  