# Programa test_scrape_wunderground_20150525.py
# Testando a API do Wunderground
# Monica Barros

# coding: utf-8
# # Leitura Wunderground

import numpy as np
import pandas as pd
import csv 
import urllib2
import json


f = urllib2.urlopen('http://www.wunderground.com/history/airport/SBRJ/2000/1/1/CustomHistory.html?dayend=01&monthend=02&yearend=2001&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&MR=1')
# http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/conditions/q/IA/Cedar_Rapids.json')
raw = f.read()
print(raw[0:20])
print(f.code)
print(f.headers['content-type'])

# Searching for city information and returning data as JSON
# Feature: Geolookup 
# Returns the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations
# In[34]: # Rio de Janeiro

url= urllib2.urlopen('http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/q/Brazil/Rio%20de%20Janeiro.json')

raw = url.read()
print(url.code)
print(url.headers['content-type'])

parsed_json = json.loads(raw)
print(parsed_json)

location = parsed_json['location']['city']
# # temp_c = parsed_json['current_observation']['temp_c']
# print "Current temperature in %s is: %s" % (location, temp_f)
location

wmo = parsed_json['location']['wmo']
wmo

airport_info = parsed_json ['location']['nearby_weather_stations']#['station']#['icao']
url.close()
airport_info

# Sao Paulo
url= urllib2.urlopen('http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/q/Brazil/Sao%20Paulo.json')
raw = url.read()
print(url.code)
print(url.headers['content-type'])
parsed_json = json.loads(raw)
print(parsed_json)
print(url.headers)

location = parsed_json['location']#['city']
# # temp_c = parsed_json['current_observation']['temp_c']
# print "Current temperature in %s is: %s" % (location, temp_f)
location

wmo = parsed_json['location']['wmo']
wmo

airport_info = parsed_json ['location']['nearby_weather_stations']#['station']#['icao']
airport_info

url.close()
