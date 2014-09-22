library(shiny)

atur <- readRDS("data/atur.rds")

shinyUI(fluidPage(
  
  titlePanel("Evolució de l'atur al País Valencià des del 1996 fins el 2012"),
  
  sidebarLayout(
    sidebarPanel(

    h4("Selecciona l'any per al mapa del país"),  
    
    sliderInput("year", label = "", min = 1996, max = 2012, value = 2008),
    
    hr(),
    br(),
    br(),
    br(),
    
    
    h5("També pots comparar l'evolució de cinc municipis"),
    
    selectInput("municipi1", 
                label = "",
                choices = sort(atur$gadm$NAME_4),
                selected = "Antella"),
    
    selectInput("municipi2", 
                label = "",
                choices = sort(atur$gadm$NAME_4),
                selected = "Gavarda"),
    
    selectInput("municipi3", 
                label = "",
                choices = sort(atur$gadm$NAME_4),
                selected = "Sumacàrcer"),
    
    selectInput("municipi4", 
                label = "",
                choices = sort(atur$gadm$NAME_4),
                selected = "Massanassa"),
    
    selectInput("municipi5", 
                label = "",
                choices = sort(atur$gadm$NAME_4),
                selected = "Catarroja"),
    
    br(),
    br(),
    
    h6("Font: ", a("la caixa", href="http://www.anuarieco.lacaixa.comunicacions.com/java/X?cgi=caixa.le_DEM.pattern&START=YES/")),
    
    h6("Autor: ", a("@jorjial", href="https://www.twitter.com/jorjial"))
    
    
    ),
    
    mainPanel(
      h4("Percentatges de persones aturades sobre la població potencialment actives per municipi"),

      plotOutput("mapPercentage"),
      
      h4("Comparació de percentatges entre municipis"),
      
      plotOutput("plotMunicipis")
      
      )
  )
  
))