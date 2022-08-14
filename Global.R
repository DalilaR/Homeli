library(dplyr)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)

building2018 <- readRDS("building2018.rds")
compressedData <- readRDS("compressedData.rds")
var2choose <- c("address","numbPermit",
                "total_Fees","WARD","SMD","LATITUDE","LONGITUDE")
compressedChoose<- compressedData[,var2choose]
compressedChoose$address <- trimws(compressedChoose$address)
tmp <- subset(compressedData,SMD== "2E01")
tmp$BeatAutoLvl <- cut(tmp$total_Fees, 
                        c(0,100,500,1500,10000,100000), include.lowest = T,
                        labels = c('<100x', '.100-500x', '500-1500x', '1500-10000x', '10000x+'))
beatCol <- colorFactor(palette = 'RdYlGn',tmp$total_Fees )
binpal <- colorBin('YlOrRd', log(tmp$total_Fees), 6, pretty = FALSE)
mintotal = min(compressedData$total_Fees)
maxtotal = max(compressedData$total_Fees)
#compressedChoose$DESC_OF_WORK<- paste0(substr(compressedChoose$DESC_OF_WORK,1,50),"...")