library(shiny)
library(feather)
library(ggplot2)
library(DT)

#used in test environment
# setwd("C:/Users/fsjun/Documents/R/Course_Project_Shiny_Application/ShinyAPP")

#Load Data
CMMData <- read_feather("Data/subset3")

# Define UI for application that draws a histogram
shinyUI(navbarPage("Dimensional Capability Dashboard",
                   tabPanel("Introduction",
                            fluidPage(p("This is a Shiny application built for Cousera Course \"Developing Data Products\".
                                        This application is a handy tool to check out the dimensional capability of machining process of one component."),
                                      p("The data was collected from the CMM(Coordinate-Measuring Machine) measurement result of one component from January to June 2016.
                                        My focus is the Cpk value of each feature, which is calculated based on the mean, stdev and spec range of the feature.
                                        I will consider the feature to be capable when its Cpk is larger or equal to  1.33. 
                                        Otherwise, it will be considered as not capable and it will require our attentions to improve the process capability.
                                        "),
                                      h3("Instruction:"),
                                      h3("Tab \"Capability Summary\":"),
                                      h3("- Access:"),
                                      p("Please click tab \"Capability Summary\" to see the summary of capability."),
                                      h3("- How to use:"),
                                      p("By default, the capability summary of each Feature will be presented at a increasing order of Cpk.
                                        Features will be highlited as red in column \"Cpk\" if its Cpk value is less than 1.33"),
                                      p("If you select Feature Type from drop-down list, you can check out the capability status of each Feature Type."),
                                      h3("Tab \"Single Feature Run Chart & Histogram\":"),
                                      h3("- Access:"),
                                      p("Please click tab \"Single Feature Run Chart & Histogram\" to see the Run Chart and Histogram of the measurement of a single feature."),
                                      h3("- How to use:"),
                                      p("By default, the Run Chart & Histogram of the first feature will be presented."),
                                      p("Once the feature is changed from the drop-down list, the run chart & histogram will be updated and the charts of selected feature will be presented on the page. 
                                        At the same time, the Cpk of this feature will be shown at the title of histogram as well.")
                                      )

                   ),
                   tabPanel("Capability Summary",
                            fluidRow("Please select one Feature Type from drop-down list below:"),
                            flowLayout(
                              div(class="span4", 
                                  selectInput("FeatureType", 
                                              "FeatureType:", 
                                              c("All", 
                                                unique(as.character(CMMData$FeatureType))))
                              )
                            ),
                            fluidRow( DT::dataTableOutput('SumTbl'))

                   ),
                   tabPanel("Single Feature Run Chart & Histogram",
                            fluidRow("Please select one Feature from drop-down list below:"),
                            flowLayout(
                              div(class="span4", 
                                  selectInput("Feature", 
                                              "Feature:", 
                                              c("All", 
                                                unique(as.character(CMMData$Feature))), "10FM")
                              )
                            )
                            ,
                            fluidRow( plotOutput("CMMRunChart")),
                            fluidRow( plotOutput("CMMHistogram"))
                   )

))
