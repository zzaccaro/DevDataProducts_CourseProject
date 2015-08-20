library(shiny)
library(data.table)
library(maps)
library(mapproj)
require(rCharts)
library(ggplot2)
library(Hmisc)
library(dplyr)
library(stringi)

data <- fread("stormdata.csv")

states <<- sort(unique(data$STATE))
capStates <<- stri_trans_totitle(states)

evtypes <<- sort(unique(data$EVTYPE))
states_map <- map_data("state")

shinyServer(
  
  function(input, output)
  {
    newdata <- reactive({
      temp <- merge(
        data.table(STATE=sort(unique(data$STATE))),
          data[EVTYPE %in% input$evtypes, 
          list(INJURIES=sum(INJURIES), 
          FATALITIES=sum(FATALITIES)), 
          by=list(STATE)], 
        by=c('STATE'), all=TRUE)
      temp[is.na(temp)] <- 0
      temp
    })
    
    output$stateInput <- renderUI({
      selectInput("state", "Choose a State:", choices = capStates, selected = "Pennsylvania")
    })
    
    output$fTitle <- renderUI({
      h4(paste("Top 5 Severe Weather Events Causing Fatalities in ", input$state, " (1950-2011)"), align = "center")
    })
    
    output$fatalityChart <- renderChart({
      state <- input$state
      fatalities <- subset(data, data$STATE == tolower(state))
      fdata <- aggregate(FATALITIES ~ EVTYPE, data = fatalities, FUN = sum)
      fdata <- fdata[order(-fdata$FATALITIES),]
      fdata <- fdata[1:5,]
      fatalityChart <- Highcharts$new()
      fatalityChart$addParams(width = 500, height = 200, dom = 'fatalityChart')
      fatalityChart$series(data = fdata$FATALITIES, type = 'bar', name = "# of Fatalities")
      fatalityChart$xAxis(categories = fdata$EVTYPE)
      return(fatalityChart)
    })
    
    output$iTitle <- renderUI({
      h4(paste("Top 5 Severe Weather Events Causing Injuries in ", input$state, " (1950-2011)"), align = "center")
    })
    
    output$injuriesChart <- renderChart({
      state <- input$state
      injuries <- subset(data, data$STATE == tolower(state))
      idata <- aggregate(INJURIES ~ EVTYPE, data = injuries, FUN = sum)
      idata <- idata[order(-idata$INJURIES),]
      idata <- idata[1:5,]
      injuriesChart <- Highcharts$new()
      injuriesChart$addParams(width = 500, height = 200, dom = 'injuriesChart')
      injuriesChart$series(data = idata$INJURIES, type = 'bar', name = "# of Injuries")
      injuriesChart$xAxis(categories = idata$EVTYPE)
      return(injuriesChart)
    })
    
    output$evtypeBoxes <- renderUI({
        checkboxGroupInput('evtypes', 'Event Types:', evtypes, selected="AVALANCHE")
    })
    
    output$fatalitiesMap <- renderPlot({
      fmdata <- newdata()
      
      ftitle <- "Fatalities Across the United States"
      p <- ggplot(fmdata, aes(map_id = tolower(STATE)))
      p <- p + geom_map(aes(fill = FATALITIES), map = states_map, colour='black') + 
          expand_limits(x = states_map$long, y = states_map$lat)
      p <- p + coord_map()
      p <- p + labs(x = "Longtitude", y = "Latitude", title = ftitle)
      p
    })
    
    output$injuriesMap <- renderPlot({
      imdata <- newdata()
      
      ititle <- "Injuries Across the United States"
      i <- ggplot(imdata, aes(map_id = tolower(STATE)))
      i <- i + geom_map(aes(fill = INJURIES), map = states_map, colour='black') + 
          expand_limits(x = states_map$long, y = states_map$lat)
      i <- i + coord_map()
      i <- i + labs(x = "Longtitude", y = "Latitude", title = ititle)
      i
    })
  }
  
)