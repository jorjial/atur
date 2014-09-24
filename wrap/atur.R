library(shiny)
library(xlsx)

#set the working directory, that is, the location of the files to load
setwd("/Users/jorge/Dropbox/scripts/R/")

# mapa
library("sp")
load("../gadm/ESP_adm4.Rdata")
summary(gadm)
sub_gadm = gadm[data.frame(gadm)$NAME_1 == "Comunidad Valenciana",]
provsOrder = data.frame(sub_gadm)$NAME_4
saveRDS(sub_gadm, file = "atur/data/atur.rds")

# Dades d'atur
aturRaw = read.xlsx2(file="atur/DatosAnuario_20140921204225.xls", header=T, sheetIndex=1, stringsAsFactors=F)
names(aturRaw) = gsub("Paro.registrado.en...s.población.potencialmente.activa.","",names(aturRaw))
names(aturRaw)[1] <- "municipi"

years = seq(1996, 2012)

maxs <- vector()
mins <- vector()
for(i in years){
  maxs <- c(maxs, max(as.numeric(aturRaw[,as.character(i)])))
  mins <- c(mins, min(as.numeric(aturRaw[,as.character(i)])))
}
max(maxs)
min(mins)

# Canviant noms
munic = aturRaw$municipi
# el
posit_el = grep("\\(el\\)", aturRaw$municipi)
munic = gsub(" \\(el\\)", "", munic, perl=T)
munic[posit_el] <- paste("El ", munic[posit_el], sep="")
# la
posit_la = grep("\\(la\\)", aturRaw$municipi)
munic = gsub(" \\(la\\)", "", munic, perl=T)
munic[posit_la] <- paste("La ", munic[posit_la], sep="")
# l;
posit_l = grep("\\(l'\\)", aturRaw$municipi)
munic = gsub(" \\(l'\\)", "", munic, perl=T)
munic[posit_l] <- paste("L'", munic[posit_l], sep="")
# les
posit_les = grep("\\(les\\)", aturRaw$municipi)
munic = gsub(" \\(les\\)", "", munic, perl=T)
munic[posit_les] <- paste("Les ", munic[posit_les], sep="")
# els
posit_els = grep("\\(els\\)", aturRaw$municipi)
munic = gsub(" \\(els\\)", "", munic, perl=T)
munic[posit_els] <- paste("Els ", munic[posit_els], sep="")
# los
posit_los = grep("\\(Los\\)", aturRaw$municipi)
munic = gsub(" \\(Los\\)", "", munic, perl=T)
munic[posit_los] <- paste("Los ", munic[posit_los], sep="")
# /
posit_bi = grep("/", aturRaw$municipi)
munic = gsub("/.*$", "", munic, perl=T)
# puntuals
munic = gsub("Vila-real", "Villarreal", munic, perl=T)
munic = gsub("L'Alqueria de la Comtessa", "Alquería de la Condesa", munic, perl=T)
munic = gsub("Borriana", "Burriana", munic, perl=T)
munic = gsub("El Fondó de les Neus", "Hondón de las Nieves", munic, perl=T)
munic = gsub("El Benitachell", "Benitachell", munic, perl=T)
munic = gsub("Calp", "Calpe", munic, perl=T)
munic = gsub("Massalavés", "Masalavés", munic, perl=T)
munic = gsub("Montserrat", "Monserrat", munic, perl=T)
munic = gsub("Peníscola", "Peñíscola", munic, perl=T)
munic = gsub("Real$", "Real de Montroi", munic, perl=T)
munic = gsub("La Villajoyosa", "Villajoyosa", munic, perl=T)
munic = gsub("El Pinós", "Pinoso", munic, perl=T)
munic = gsub("Xaló", "Jalón", munic, perl=T)

length(setdiff(munic,provsOrder))

#grep("tell", setdiff(provsOrder, munic), value = T)
# grep("Jal", provsOrder, value = T)
# grep("Real", munic, value=T)
# munic[grep("eal", aturRaw$municipi)]

# afegint pobles corregits
aturRaw$municipi_corregit = munic

library("RColorBrewer")
colorPalette <- rev(brewer.pal(11, "RdYlGn"))
colorPalette <- c("#e0e0e0", colorPalette, "#67001f")

#province names are uppercase in the csv files, but the Rdata file
#contains province names in lowercase. Compare names always in
#uppercase. For each province name in the RData file, get its row
#position in the csv file.

# matching positions
provsIndex <- vector(length = length(provsOrder))

for(i in 1:length(provsOrder)){
  if(provsOrder[i] %in% aturRaw$municipi_corregit){
    provsIndex[i] <- which(aturRaw$municipi_corregit == provsOrder[i])
  }else{
    provsIndex[i] <- NA
  }
}

# Now get the corresponding color level for each province, based on its mortality percentage:

legend = c("sense dades", "0 - 2.5%", "2.5 - 5.0%", "5.0 - 7.5", "7.5 - 10%",
           "10.0 - 12.5%", "12.5 - 15.0%", "15.0 - 17.5", "17.5 - 20.0%", 
           "20.0 - 22.5%", "22.5 - 25.0%", "25.0 - 27.5%", "27.5 - 30.0%")

pdf("atur_maps.pdf", paper='A4r')

par(mfrow=c(2,6))

for(year in years){
  year = as.character(year)
  provsColorLevel <- vector(length = length(provsOrder))
  for(i in 1:length(provsOrder)){
    if(is.na(provsIndex[i])){
      provsColorLevel[i] <- 1
    }else{
      provsColorLevel[i] <- (as.numeric(aturRaw[provsIndex[i],year]) %/% 2.5) + 2
    }
  }
  sub_gadm$provsColorLevel = as.factor(provsColorLevel)
  sub_gadm$provsValueLevel = factor(legend[provsColorLevel], levels = legend)
    
  finalColors = colorPalette[match(levels(sub_gadm$provsValueLevel), legend)]

  p <- spplot(sub_gadm, "provsValueLevel", col.regions = finalColors,
               col = "white",
               main = year)
  
  p <- update(p, colorkey=TRUE)
  
  print(p)
  
  
}
dev.off()

# -----------------------------------
# Saving rds file
aturList = list()

# legend
aturList$legend = legend

# paleta mapa
aturList$pal = colorPalette

# paleta plot
aturList$pal2 = rev(brewer.pal(5, "Set1"))

# gadm
aturList$gadm = sub_gadm

# provsIndex
aturList$provsIndex = provsIndex

# list of years
aturList$data = list()

for(year in years){
  
  year = as.character(year)
  aturList$data[[year]] = list()
  provsColorLevel <- vector(length = length(provsOrder))
  percentAtur <- rep(0, length(provsOrder))
  for(i in 1:length(provsOrder)){
    if(is.na(provsIndex[i])){
      provsColorLevel[i] <- 1
    }else{
      percentAtur[i] = as.numeric(aturRaw[provsIndex[i],year])
      provsColorLevel[i] <- (as.numeric(aturRaw[provsIndex[i],year]) %/% 2.5) + 2
    }
  }
  
  aturList$data[[year]]$provsColorLevel = as.factor(provsColorLevel)
  aturList$data[[year]]$provsValueLevel = factor(legend[provsColorLevel], levels = legend)
  aturList$data[[year]]$percentAtur = as.numeric(percentAtur)
  
}

saveRDS(aturList, "atur/data/atur.rds")


