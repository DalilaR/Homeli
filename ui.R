library(leaflet)
library(shinydashboard)
library(DT)
shinyUI(dashboardPage(
  dashboardHeader(title = "Homeli"),
  dashboardSidebar(
    sidebarMenu(
    menuItem("Data", tabName="data"),
    menuItem("Map", tabName="mapStat")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "data",
              
                  column(6,DT::dataTableOutput("fdata",width = "200%"), collapsible = FALSE)
               
              ),
      tabItem(tabName = "mapStat",
              h1("Building"),
              fluidRow(
                column(4,
                       selectInput("anc","ANC",
                                   c("All",sort(unique(as.character(building2018$SMD)))))
              )),
              fluidRow(
              column(4,
                     #sliderInput("range","Range:",min = 1, max = 100000,value = c(1000,80000),
                      #             pre = "$",sep = ",")
                     uiOutput("SliderWidget")
              )),
              fluidRow(
                column(6,leafletOutput("map",height="500px")),
                column(6,dataTableOutput('detail')))
    )         )
  )
)
)