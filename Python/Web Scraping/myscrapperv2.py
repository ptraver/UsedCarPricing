# -*- coding: utf-8 -*-
"""
Created on Tue Jun 13 15:55:22 2017

@author: Rohit
"""

import scrapy
from scrapy.item import Item, Field
from scrapy.http import HtmlResponse
import re
import json

class DonedeallistSampleItem(Item):
    title = Field()
    link = Field()
    description = Field()


class DoneDealSpider(scrapy.Spider):
    name = 'donedeal_spider'
    start_urls = ['https://www.donedeal.ie/cars']
    #item_count=0
    url_index_count=0
    item_count=0
    max_item_crawled=0
    wanted_items=100
    rate = 1
    download_delay = 1/float(rate)
    
    def parse(self, response):
        
        #self.wanted_num=28
        
        SET_SELECTOR = '.card-item'
        for donedealitem in response.css(SET_SELECTOR):
            #item_count=0
            #print(donedealitem)
            NAME_SELECTOR = 'a ::attr(href)'
            #item = DonedeallistSampleItem()
            #item["title"] = donedealitem.xpath("a/text()").extract()[0]
            #item["link"] = donedealitem.xpath("a/@href").extract()[0]
            #print(item["title"])
            #print(item["link"])
            
            #yield {'name': donedealitem.css(NAME_SELECTOR).extract_first() }
            url = donedealitem.css(NAME_SELECTOR).extract_first()
            #if(self.item_count<28):
                #print("If executed")                
                #yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
                #self.item_count=self.item_count+1
                #self.max_item_crawled=self.max_item_crawled+1
            #else:
                #print("Else executed")
                #print(
                #self.url_index_count=self.url_index_count+28
                
                
                #print(url="https://www.donedeal.ie/cars?start="+str(self.url_index_count))
                #yield scrapy.Request(url="https://www.donedeal.ie/cars?start="+str(self.url_index_count), callback=self.parse,method='GET', encoding='utf-8')
                #self.item_count=0
                    
            if(self.max_item_crawled<=self.wanted_items):
                if(self.item_count<28):
                    yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
                    self.item_count=self.item_count+1
                    self.max_item_crawled=self.max_item_crawled+1
                else:
                    self.url_index_count=self.url_index_count+28
                    self.item_count=0
                    yield scrapy.Request(url="https://www.donedeal.ie/cars?start="+str(self.url_index_count), callback=self.parse,method='GET', encoding='utf-8')
                    
                    
                    
                    
                    
                #yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
                #self.item_count=self.item_count+1
                #print(self.item_count)
                
            #else:
                #self.url_index_count=self.url_index_count+28
                #yield scrapy.Request(url="https://www.donedeal.ie/cars?start="+self.url_index_count, callback=self.parse,method='GET', encoding='utf-8')
                #self.item_count=0
                
                
            #yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            
            #print("URL",url)
            #print(url)
            #scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            #if(self.item_count<28):
                #yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
                #self.item_count=self.item_count+1
                #print(self.item_count)
                
            #else:
                #self.url_index_count=self.url_index_count+28
                #yield scrapy.Request(url="https://www.donedeal.ie/cars?start="+self.url_index_count, callback=self.parse,method='GET', encoding='utf-8')
                #self.item_count=0
                
                
            #yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            #yield scrapy.http.HtmlResponse(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            #yield scrapy.Request(response.urljoin(url), callback=self.parse_item_page)
    def parse_item_page(self, response):
        print("Response URL",response.url)
        #self.wanted_num=28
       #self.item_count=0
        
        #print("call made to the parse_item_page")
        #yield scrapy.Request(url="https://www.donedeal.ie/cars?start=28", callback=self.parse,method='GET', encoding='utf-8')
        #print("parse Item executed")
        
        
        
        #pattern = re.compile(r"window.adDetails:({.*?})", re.MULTILINE | re.DOTALL)
        #print(response.xpath('//script/text()'))

        
        
        #print(response.xpath('//script/text()').re("window\.adDetails\ = {([^}]*)}"))
        #print(response.xpath("//script[contains(.,'window.adDetails')]/text()"))
        #info = json.loads(response.xpath("//script[contains(.,'window.adDetails')]/text()"))
        #print(info)

        #print(response.xpath("//script/window.adDetails"))
        #for sel in response.xpath('//script'):
            #print(sel)
        #for sel in response.css('.key-info-attrs space-bottom-20'):
            #print(sel)
        #for sel in response.xpath('//html/body/main/div/div[1]/div/div[2]/div[2]/div[4]/div[1]/div[2]/ul'):
            #print(sel)
        #print(response.xpath('//div/div/ul').len())
            #x=sel.xpath('//li/span[@class="attr-value"]//text()').extract()
            #x=sel.xpath("/li/span[contains(@class,'attr-value')]/text()").extract()
            #print(x)
            #print(sel.xpath('/li[@class="ng-scope"]/span[@class="attr-value"]/text()').extract())
            #print(sel.xpath('/li/span[@class="attr-value"]/text()').extract())
            #print(sel.xpath('/li[@class="ng-scope"]').extract())
        #print(response.xpath('//html/body/main/div/div[1]/div/div[2]/div[2]/div[4]/div[1]/div[2]/ul/li[1]/span[2]').extract())
        #print(response)
        #response1 = HtmlResponse(response.url)
        #print("Success")
        #print("RESPONSE",response1)
        #hxs = HtmlResponse(response)
        #DESCRIPTION_SELECTOR='.cad-content divider'
        #DESCRIPTION_SELECTOR='.//html/body/main/div/div[1]/div/div[2]/div[2]/div[4]/div[1]/div[2]/ul'
        #print(DESCRIPTION_SELECTOR)
        #print(response.css(DESCRIPTION_SELECTOR))
        #print(response.xpath(DESCRIPTION_SELECTOR))
        #for descriptionitem in response.xpath(DESCRIPTION_SELECTOR):
            #print(descriptionitem)
            #MAKE_SELECTOR=".//span[2]/text"
            #yield { 'make': descriptionitem.xpath(MAKE_SELECTOR).extract_first()}
        
        #hxs = HtmlXPathSelector(response)

        #item = response.meta['item']
        #item['description'] = hxs.select('//section[@id="postingbody"]/text()').extract()
        return #item