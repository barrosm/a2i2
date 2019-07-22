# Programa test_scrape_wunderground_20150525.py
#convertido de IPython notebook
# coding: utf-8

# # Leitura Wunderground

# In[31]:
import numpy as np
import pandas as pd
import csv 
import urllib2
import json
# In[32]:
f = urllib2.urlopen('http://www.wunderground.com/history/airport/SBRJ/2000/1/1/CustomHistory.html?dayend=01&monthend=02&yearend=2001&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&MR=1')
# http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/conditions/q/IA/Cedar_Rapids.json')
raw = f.read()
print(raw[0:20])
print(f.code)
print(f.headers['content-type'])

# Searching for city information and returning data as JSON
# Feature: Geolookup 
# Returns the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations

# In[34]:

# Rio de Janeiro


# In[52]:
url= urllib2.urlopen('http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/q/Brazil/Rio%20de%20Janeiro.json')


# In[53]:
raw = url.read()
print(url.code)
print(url.headers['content-type'])


# In[57]:
parsed_json = json.loads(raw)


# In[61]:
print(parsed_json)


# In[55]:
location = parsed_json['location']['city']
# # temp_c = parsed_json['current_observation']['temp_c']
# print "Current temperature in %s is: %s" % (location, temp_f)
location


# In[38]:

wmo = parsed_json['location']['wmo']
wmo


# In[39]:

airport_info = parsed_json ['location']['nearby_weather_stations']#['station']#['icao']
url.close()


# In[40]:

airport_info


# In[41]:

# Sao Paulo


# In[62]:

url= urllib2.urlopen('http://api.wunderground.com/api/21e306e5b2c392d9/geolookup/q/Brazil/Sao%20Paulo.json')


# In[63]:

raw = url.read()
print(url.code)
print(url.headers['content-type'])


# In[65]:

parsed_json = json.loads(raw)


# In[66]:

print(parsed_json)


# In[67]:

print(url.headers)


# In[68]:

location = parsed_json['location']#['city']
# # temp_c = parsed_json['current_observation']['temp_c']
# print "Current temperature in %s is: %s" % (location, temp_f)
location


# In[69]:

wmo = parsed_json['location']['wmo']
wmo


# In[70]:

airport_info = parsed_json ['location']['nearby_weather_stations']#['station']#['icao']


# In[71]:

airport_info


# In[72]:

url.close()


# In[ ]:




# In[ ]:




