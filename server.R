library(shiny)
library(feather)
library(ggplot2)
library(DT)

# WD of test environment
# setwd("C:/Users/fsjun/Documents/R/Course_Project_Shiny_Application/ShinyAPP")


#Load Data
CMMData <- read_feather("Data/subset3")

source("functions.R")

#################################Summarize Data####################################
SummaryData <- GroupBy(CMMData, FeatureType, Feature)

#reorder data frame in order of Cpk
SummaryData <- SummaryData[order(SummaryData$Cpk),]


shinyServer(function(input, output) {

  output$SumTbl <- renderDataTable({
    
    ####filter data based on inputs from ui.R
    data <- SummaryData

    if (input$FeatureType != "All"){
      data <- data[data$FeatureType == input$FeatureType,]
    }

    data

    #####set conditional format of output table
    DT::datatable(data ,
                  options = list(pageLength = 10,rowCallback = JS('
                                          function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                                          if (parseFloat(aData[11]) < 1.33)
                                          $("td:eq(11)", nRow).css("background-color", "#FF0000");
                                          }')
                                )
                  )
    })
  
  ########################Build CMMRunChart###############################  

  output$CMMRunChart <- renderPlot({
    ####filter data based on inputs from ui.R
    data <- CMMData

    if (input$Feature != "All"){     
        data <- data[data$Feature == input$Feature,]
        nominal <- max(data[,"Nominal"])
        uppertol <- max(data[,"Plus_Tol"])
        lowertol <- min(data[,"Minus_Tol"])
        usl <- nominal + uppertol
        lsl <- nominal - abs(lowertol)
      
      
      hlines <- data.frame(ControlValue = c(lsl, nominal,  usl),
                           ControlType = c("LSL", "Nominal",  "USL" ))
      
      g <- ggplot(data, aes(x=Date, y=value  )) +
        geom_line(size=1,color="blue") +
        geom_hline(data=hlines, aes(yintercept=ControlValue, colour = ControlType ), linetype="dashed",  size=1) + 
        xlab("Date") +            
        ylab(input$Feature) +
        ggtitle(paste("CMM Dimension Run Chart - Feature: ",input$Feature)) + 
        theme(text = element_text(size=20))
      
      print(g)

    }
  })  

  ########################build CMM Histogram###############################  
  
  output$CMMHistogram <- renderPlot({
    ####filter data based on inputs from ui.R
    data <- CMMData
    Cpk <- max(SummaryData$Cpk[which(SummaryData$Feature==input$Feature)])
    
    if (input$Feature != "All"){     
      data <- data[data$Feature == input$Feature,]
      nominal <- max(data[,"Nominal"])
      uppertol <- max(data[,"Plus_Tol"])
      lowertol <- min(data[,"Minus_Tol"])
      usl <- nominal + uppertol
      lsl <- nominal - abs(lowertol)
      
      
      vlines <- data.frame(ControlValue = c(lsl, nominal,  usl),
                           ControlType = c("LSL", "Nominal",  "USL" ))
      
      g <- ggplot(data, aes(x = data$value)) + 
        geom_histogram(binwidth=.005, alpha = 0.8, position = "dodge") +
        geom_density(alpha=.2, fill="#FF6666")+
        geom_vline(data=vlines, aes(xintercept=ControlValue, colour = ControlType ), linetype="dashed",  size=1) + 
        xlab("Measurement") +            
        ylab("Count") +
        ggtitle(paste("CMM Dimension Histogram - Feature: ",input$Feature, " Cpk=", Cpk )) + 
        theme(text = element_text(size=20)) 
      
      
      print(g)
      
    }
  })  
    
})
