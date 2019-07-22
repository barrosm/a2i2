# Using the ggmap package
# 
# Date: 2016-04-09

install.packages("ggmap")
install.packages("dplyr")

require(colorspace)
require(ggmap)
require(ggplot2)
library(rvest)
library(dplyr)

setwd('c:\\Users\\Monica\\Documents')
dir()
# ==========================================================
# get_map is a smart wrapper that queries the Google Maps, 
# OpenStreetMap, Stamen Maps or Naver Map servers for a map.
# ==========================================================
# Usage
# get_map(location = c(lon = -95.3632715, lat = 29.7632836), zoom = "auto",
        # scale = "auto", maptype = c("terrain", "terrain-background", "satellite",
        #  "roadmap", "hybrid", "toner", "watercolor", "terrain-labels", "terrain-lines",
        # "toner-2010", "toner-2011", "toner-background", "toner-hybrid",
        # "toner-labels", "toner-lines", "toner-lite"), 
        # source = c("google", "osm",
        # "stamen", "cloudmade"), force = ifelse(source == "google", TRUE, TRUE),
        # messaging = FALSE, urlonly = FALSE, filename = "ggmapTemp",
        # crop = TRUE, color = c("color", "bw"), language = "en-EN", api_key)


# lat & long for R. Domingos Ferreira, Copacabana, Rio de Janeiro
# Está errado - está mais perto da Santa Clara
latit = -22.972
longit = - 43.187

# Quck maps
qmap(location = "Avenida Atlantica Rio de Janeiro",maptype = 'hybrid', zoom = 20 )

qmap(location = "rio de janeiro", maptype = 'roadmap', zoom = 17)

qmap(location = " PUC Rio de Janeiro", maptype = 'roadmap', source = 'google', zoom = 17)


map_Image =  get_map(location = c(lon = longit,lat = latit),
                     color = "color", source = "google",
                    maptype = "roadmap",
                        # api_key = "your_api_key", # only needed for source = "cloudmade"
                        zoom = 17)

# precisa especificar os dados dentro da geom_path abaixo
ggmap(map_Image,
      extent = "device", # "panel" keeps in axes, etc.
      ylab = "Latitude",
      xlab = "Longitude",
      legend = "right") +
  geom_path(aes(x = Longitude, # path outline
                y = Latitude),
            data = gps,
            colour = "black",
            size = 2) +
  geom_path(aes(x = Longitude, # path
                y = Latitude),
            colour = pathcolor,
            data = gps,
            size = 1.4) # +
# labs(x = "Longitude",
#   y = "Latitude") # if you do extent = "panel"


# Dados da rede retiro de farmácias - interior do estado do RJ
# Colocar num mapa
