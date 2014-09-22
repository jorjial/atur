library("sp")
library("ggplot2")

plotMunicipi <- function(atur, municipi1, municipi2, municipi3, municipi4, municipi5){

  percentMunicipal = data.frame(stringsAsFactors=F)
  
  for(municipi in c(municipi1, municipi2, municipi3, municipi4, municipi5)){
    for(year in years){
      year = as.character(year)
      perc = atur$data[[year]]$percentAtur[sub_gadm$NAME_4 == municipi]
      
      percentMunicipal = rbind(percentMunicipal,
                               data.frame(any = year,
                                          percentatge = perc,
                                          municipi = municipi,
                                          stringsAsFactors = F))
      
    }
  }
  
  # plot
  
  p <- ggplot(percentMunicipal, aes(x = any, y = percentatge, col=municipi, group=municipi))
  p <- p + geom_point() + geom_line()
  p <- p + xlab("Any") + theme(axis.text.x = element_text(angle = 90, hjust = 1, size=12))
  p <- p + theme(axis.title.y = element_text(size = rel(1.2)))
  p <- p + ylab("Atur (%)") + theme(axis.text.y = element_text(size=12))
  p <- p + theme(axis.title.x = element_text(size = rel(1.2)))
  p <- p + scale_colour_manual(values=atur$pal2)
  p <- p + theme_bw()
  
  return(p)  

}


plotMapa <- function(year, atur){
  
    year = as.character(year)
    
    sub_gadm = atur$gadm
    
    sub_gadm$provsColorLevel = atur$data[[year]]$provsColorLevel
    sub_gadm$provsValueLevel = atur$data[[year]]$provsValueLevel
    
    finalColors = colorPalette[match(levels(sub_gadm$provsValueLevel), legend)]
    
    p <- spplot(sub_gadm, "provsValueLevel", col.regions = finalColors,
                col = "white",
                main = year)
    
    return(p)
    
}
