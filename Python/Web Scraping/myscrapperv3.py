# -*- coding: utf-8 -*-
"""
Created on Tue Jun 13 19:22:15 2017

@author: Rohit
"""

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
import urllib
from scrapy.spidermiddlewares.httperror import HttpError
from twisted.internet.error import DNSLookupError
from twisted.internet.error import TimeoutError, TCPTimedOutError
from bs4 import BeautifulSoup

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
    wanted_items=5
    rate = 1
    download_delay = 1/float(rate)
    
    def parse(self, response):
        
        #self.wanted_num=28
        
        SET_SELECTOR = '.card-item'
        for donedealitem in response.css(SET_SELECTOR):
            
            NAME_SELECTOR = 'a ::attr(href)'
            url = donedealitem.css(NAME_SELECTOR).extract_first()
            
                    
            if(self.max_item_crawled<=self.wanted_items):
                if(self.item_count<28):
                    yield scrapy.Request(url=url, callback=self.parse_item_page,method='GET', encoding='utf-8')
                    self.item_count=self.item_count+1
                    self.max_item_crawled=self.max_item_crawled+1
                else:
                    self.url_index_count=self.url_index_count+28
                    self.item_count=0
                    yield scrapy.Request(url="https://www.donedeal.ie/cars?start="+str(self.url_index_count), callback=self.parse,method='GET', encoding='utf-8',errback=self.errback_httpbin,dont_filter=False)
            
    def parse_item_page(self, response):
        self.logger.info('Got successful response from {}'.format(response.url))
        web = urllib.request.urlopen("https://www.donedeal.ie/cars-for-sale/volkswagen-polo-1-0-base/15780393")

        soup = BeautifulSoup(web.read(), 'lxml')
        data  = str(soup.find_all("script")[8])
        #p = re.compile(r'window.adDetails = {.*?};')
        p=re.compile(r'"(displayAttributes)":([^$]*})') #working regex
        matches = [group for group in re.findall(p, data) if group]
        with open("DoneDeal.txt", 'a+') as f:
            f.write(str(matches[0])+"\n")
        #data=response.xpath("//script[contains(.,'window.adDetails')]/text()")
        #info = response.text("//script[contains(.,'window.adDetails')]/text()")
        #soup = BeautifulSoup(web.read(), 'lxml')
        #data  = str(soup.find_all("script")[8])
        #p = re.compile(r'window.adDetails = {.*?};')
        #m = p.match(data)
        #data=response.xpath("//script")
        #print(data[8])
        
        

    def errback_httpbin(self, failure):
        # log all failures
        self.logger.error(repr(failure))

        # in case you want to do something special for some errors,
        # you may need the failure's type:

        if failure.check(HttpError):
            response = failure.value.response
            self.logger.error('HttpError on %s', response.url)
        elif failure.check(DNSLookupError):
            # this is the original request
            request = failure.request
            self.logger.error('DNSLookupError on %s', request.url)

        elif failure.check(TimeoutError, TCPTimedOutError):
            request = failure.request
            self.logger.error('TimeoutError on %s', request.url)
        
           