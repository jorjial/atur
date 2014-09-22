library("sp")

atur <- readRDS("data/atur.rds")
source("helpers.R")

shinyServer(function(input, output) {
  
  output$plotMunicipis <- renderPlot({plotMunicipi(atur, input$municipi1,
                                                   input$municipi2, input$municipi3,
                                                   input$municipi4, input$municipi5)})
  
  output$mapPercentage <- renderPlot({plotMapa(input$year, atur)})
    
})