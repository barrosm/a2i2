# Test on use of the RgoogleMaps package
# Date: 21/05/2016
install.packages("RgoogleMaps")
install.packages("rvest")

install.packages("ggmap")

library(RgoogleMaps)
getGeoCode("Rio de Janeiro")
# Below - address for PUC - Rio
getGeoCode("Rua Marques de Sao Vicente 225 Rio de Janeiro")

location_1="Rua Marques de Sao Vicente 225 Rio de Janeiro"

# Look at the static maps for the preceding places using the function GetMap.

Rio_Map <- GetMap(center=location_1, zoom=16)
PlotOnStaticMap(Rio_Map)


library("rvest")
htmlpage = html("http://www.trivago.com.br/?iSemThemeId=24166&iPathId=78506&sem_keyword=pousada%20rio%20janeiro%20copacabana&sem_creativeid=73546849388&sem_matchtype=b&sem_network=g&sem_device=c&sem_placement=&sem_target=&sem_adposition=1t2&sem_param1=&sem_param2=&sem_campaignid=213036788&sem_adgroupid=16834812668&sem_targetid=kwd-19031780201&sem_location=1001655&cip=551210060302")
htmlpage2=html("http://www.trivago.com.br/?iPathId=78506&bDispMoreFilter=false&aDateRange%5Barr%5D=2016-06-05&aDateRange%5Bdep%5D=2016-06-06&aCategoryRange=0%2C1%2C2%2C3%2C4%2C5&iRoomType=7&sOrderBy=relevance%20desc&aPartner=&aOverallLiking=1%2C2%2C3%2C4%2C5&iOffset=25&iLimit=25&iIncludeAll=0&bTopDealsOnly=false&iViewType=0&aPriceRange%5Bfrom%5D=0&aPriceRange%5Bto%5D=0&aGeoCode%5Blng%5D=-43.178181&aGeoCode%5Blat%5D=-22.9067&bIsSeoPage=false&mgo=false&th=false&aHotelTestClassifier=&bSharedRooms=false&bIsSitemap=false&rp=&sSemKeywordInfo=pousada+rio+janeiro+copacabana&cpt=7850603&iFilterTab=0&")

htl_html <- html_nodes(htmlpage, ".item__name__copytext")
htl_html2 <- html_nodes(htmlpage2, ".item__name__copytext")
htl <- html_text(htl_html)
htl = paste("Hotel", htl, "Rio de Janeiro, Brasil")
htl2 <- html_text(htl_html2)
htl2 = paste("Hotel", htl2, "Rio de Janeiro, Brasil")

hoteis=as.data.frame(cbind(htl,htl2))

library(ggmap)
GeoLocations = geocode(as.character(hoteis$htl2),output ='latlona')
MapData = cbind(hoteis,GeoLocations)
rm(GeoLocations)

geocode("Hotel Windsor Martinique Rio de Janeiro, Brasil")

# Map is defined in terms of centre and zoom level
# Provision for missing values in the calculations
#cent2 = c(mean(MapData$lat, na.rm = TRUE), mean(MapData$lon, na.rm = TRUE))
cent2 = c(median(MapData$lat, na.rm = TRUE), median(MapData$lon, na.rm = TRUE))
zoom2 = min(MaxZoom(range(MapData$lat, na.rm = TRUE), range(MapData$lon, na.rm = TRUE)))

# Plots on NEW map
PlotOnStaticMap(Map,lat = MapData$lat, lon = MapData$lon, cex =1.5, pch = 18, col = "darkred", FUN = points, NEWMAP = TRUE)
# Note - cex controls size
# Note - pch 16 to 20 produce filled markers

