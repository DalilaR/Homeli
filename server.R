library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)




shinyServer(function(input, output) {
 
  data_of_click <- reactiveValues(clickedMarker=NULL)
  
  output$fdata <- DT::renderDataTable(compressedChoose,
                  options =   list(searching = TRUE,
                                   autoWidth = TRUE,
                                   rownames = FALSE,
                                   scroller = TRUE,
                                   scrollX = TRUE,
                                   scrollY = "500px",
                                   fixedHeader = TRUE)
                  )
  output$SliderWidget <- renderUI({
    if (input$anc == "All"){
      sliderInput("range","Range:",min = mintotal, max = maxtotal,value = c(mintotal+10,maxtotal-10),
                            pre = "$",sep = ",")
    }
    else {
      tmp <- subset(compressedData, SMD = input$anc)
      mintotal <- min(tmp$total_Fees)
      maxtotal <- max(tmp$total_Fees)
      sliderInput("range","Range:",min = mintotal, max = maxtotal,value = c(mintotal+10,maxtotal-10),
                  pre = "$",sep = ",")
    }
  })
  output$map <- renderLeaflet({
    mintotal <- input$range[1]
    maxtotal <- input$range[2]
    tmp <- compressedData
    tmp<- compressedData %>%
      filter(
        total_Fees >= mintotal,
        total_Fees <= maxtotal
        )
    tmp$BeatAutoLvl <- cut(tmp$total_Fees, 
                           c(0,100,500,1500,10000,50000), include.lowest = T,
                           labels = c('<100x', '.100-500x', '500-1500x', '1500-10000x', '10000x+'))
    beatCol <- colorFactor(palette = 'YlOrRd', factor(tmp$BeatAutoLvl ))
    
    if (input$anc != "All"){
      tmp <- compressedData %>%
        filter (
          total_Fees >= input$range[1],
          total_Fees <= input$range[2],
          SMD == input$anc
        )
      tmp <- as.data.frame(tmp)
     
      tmp$BeatAutoLvl <- cut(tmp$total_Fees, 
                             c(0,100,500,1500,10000,50000), include.lowest = T,
                             labels = c('<100x', '.100-500x', '500-1500x', '1500-10000x', '10000x+'))
      beatCol <- colorFactor(palette = 'RdYlGn', factor(tmp$BeatAutoLvl ))
    }
    my.map <- leaflet() %>%
      addProviderTiles(provider = providers$CartoDB.Positron ) %>%
      #addPolygons(data= mapStates,opacity = 0) %>%
      addCircleMarkers(layerId = tmp$MARADDRESSREPOSITORYID, 
                       lng=tmp$LONGITUDE, lat=tmp$LATITUDE, color = beatCol(tmp$BeatAutoLvl),radius= 5,label= tmp$total_Fees, 
                       popup = paste("Address: ",tmp$address, "<br>",
                                     "# Permits: ",tmp$numbPermit, "<br>",
                                     "Fees Paid: ",tmp$total_Fees, "<br>")) 
                                                 
    })
  observeEvent(input$map_marker_click,{
    data_of_click$clickedMarker <- input$map_marker_click
  })
  output$detail = renderDataTable({
    my_desc=data_of_click$clickedMarker$id
    if (is.null(my_desc)){my_desc = tmp$MARADDRESSREPOSITORYID[1]}
    subset(building2018,MARADDRESSREPOSITORYID == my_desc)[,c("FULL_ADDRESS","PERMIT_ID","DESC_OF_WORK")]
    
  })
    # observeEvent(input$map_marker_click,
    #              {data_of_click$clickedMarker->input$map_marker_click})
    # 
})
