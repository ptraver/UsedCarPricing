# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 16:04:14 2017

@author: Rohit
"""

import scrapy
from scrapy.item import Item, Field
from scrapy.http import HtmlResponse
import urllib
import requests

class DonedeallistSampleItem(Item):
    title = Field()
    link = Field()
    description = Field()


class DoneDealSpider(scrapy.Spider):
    name = 'donedeal_spider'
    start_urls = ['https://www.donedeal.ie/cars']
    
    def parse(self, response):
        SET_SELECTOR = '.card-item'
        for donedealitem in response.css(SET_SELECTOR):
            #print(donedealitem)
            NAME_SELECTOR = 'a ::attr(href)'
            #item = DonedeallistSampleItem()
            #item["title"] = donedealitem.xpath("a/text()").extract()[0]
            #item["link"] = donedealitem.xpath("a/@href").extract()[0]
            #print(item["title"])
            #print(item["link"])
            
            #yield {'name': donedealitem.css(NAME_SELECTOR).extract_first() }
            url = donedealitem.css(NAME_SELECTOR).extract_first()
            #print("URL",url)
            #print(url)
            #scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            #yield scrapy.http.HtmlResponse(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
            #yield scrapy.Request(response.urljoin(url), callback=self.parse_item_page)
    def parse_item_page(self, response):
        print("RESPONSE",response.url)
        htmlresponse= urllib.request.urlopen(response.url)
        print("Reponse got in html format")

        
        
        #print(response.xpath('/div/div[1]/div/div[2]/div[2]/div[4]/div[1]/div[2]/ul'))
        #for sel in response.xpath('/div/div[1]/div/div[2]/div[2]/div[4]/div[1]/div[2]/ul'):
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