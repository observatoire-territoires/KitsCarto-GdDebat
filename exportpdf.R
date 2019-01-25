## Script pour exporter des pdf en boucle
# CL, OT, décembre 2018

rm(list = ls())

library(readxl)
library(knitr)
library(kableExtra)

# Création du dossier vers lequel seront exportés les rapports
dir.create("rapports")

# Sélection des EPCI sur lesquelles on va produire les kits cartographiques
ngeo <- read_xlsx("data/n_geo.xlsx", sheet = "com")
comepcis <- read.csv2("data/comepci2018simple.csv")

listepci <- unique(ngeo$epci2018)
listepci <- listepci[!is.na(listepci)]

# Création des rapports
for(terr in listepci){ 
  
  epci <- terr
  dep <- substr(comepcis[comepcis$epci2018==terr, c(1)],1 ,2)
  nomcom <- comepcis[comepcis$epci2018==terr,c(3)]

  rmarkdown::render(input = "dossierCarto.Rmd", 
                    output_format = "pdf_document",
                    output_file = paste0(nomcom,".pdf"),
                    output_dir = "rapports",
                 encoding = "UTF-8")
  
}
