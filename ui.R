library(shiny)
require(rCharts)
library(Hmisc)
library(dplyr)
options(RCHART_LIB = 'highcharts')

shinyUI(pageWithSidebar(
  
  headerPanel("Measuring Fatalities/Injuries within the Storm Database (1950-2011)"),
  
  sidebarPanel(
    uiOutput("stateInput"),
    uiOutput("evtypeBoxes")
  ),
  
  mainPanel(tabsetPanel(
    
    tabPanel("About", includeMarkdown("README.md")), 
    
    tabPanel("By State", 
        h4("Choose a state on the left to see the top 5 most destructive weather events within that state."),
        h2("FATALITIES"),
        uiOutput("fTitle"),
        showOutput("fatalityChart", "highcharts"),
        h2("INJURIES"),
        uiOutput("iTitle"),
        showOutput("injuriesChart", "highcharts")
    ),
    
    tabPanel("By Event",
       h4("Select weather events on the left to see which states those events occur in the most."),
       h2("FATALITIES"),
       plotOutput("fatalitiesMap"),
       h2("INJURIES"),
       plotOutput("injuriesMap"))
  ))
  
))




