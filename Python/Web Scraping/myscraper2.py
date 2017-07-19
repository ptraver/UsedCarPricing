# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 15:47:36 2017

@author: Rohit
"""

import scrapy
from scrapy.item import Item, Field
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import Rule
from scrapy.selector import Selector
from scrapy.http import HtmlResponse
#from scrapy. import XmlXPathSelector

class CraigslistSampleItem(Item):
    title = Field()
    link = Field()
    
class MySpider(scrapy.Spider):
    name = "craigs"
    allowed_domains = ["sfbay.craigslist.org"]
    start_urls = ["http://sfbay.craigslist.org/search/npo"]

    rules = (
        Rule(LinkExtractor(allow=(), restrict_xpaths=('//a[@class="button next"]',)), callback="parse", follow= True),
    )

    def parse(self, response):
        #hxs = HtmlResponse(response)
        #xxs = XmlXPathSelector(response)
        print(response)
        sel = Selector(response)
        #titles = hxs.selector.xpath('//span[@class="pl"]')
        titles = sel.xpath('//span[@class="pl"]')
        items = []
        for titles in titles:
            item = CraigslistSampleItem()
            item["title"] = titles.xpath("a/text()").extract()
            item["link"] = titles.xpath("a/@href").extract()
            items.append(item)
        return(items)