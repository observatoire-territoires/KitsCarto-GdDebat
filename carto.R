## Script de cartographie des données communales et intercommunales
# CL, OT, décembre 2018

rm(list = ls())

library(readxl)
library(dplyr)
library(sf)
library(cartography)
library(COGugaison)
library(ggplot2)

#=================================================================================
# CHARGEMENT DES TABLES ET FONDS DE CARTES
# Tables de données
datacom <- read.csv2("data/datacom.csv")
dataepci <- read.csv2("data/dataepci.csv") %>%
  mutate(epci2018 = as.character(epci2018)) %>%
  filter(!is.na(epci2018))

# Métadonnées
meta <- read_xlsx("data/meta.xlsx")
ngeo <- read_xlsx("data/n_geo.xlsx", sheet = "com")
libepci <- read_xlsx("data/n_geo.xlsx", sheet = "epci2018")

# Fonds de carte
epci_geo <- st_read("geo/epci2018.shp")
dep_geo <- st_read("geo/dep.shp")
com_geo <- st_read("geo/com2018.shp")
reg_geo <- st_read("geo/reg2016.shp")
cercles <- st_read("geo/CERCLES_DROM.shp")
cldep <- st_read("geo/ENSEMBLE_CHEF_LIEU.shp") %>%
  filter(STATUT %in% c("Préfecture de département", "Préfecture de région", "Capitale d'État")) %>%
  left_join(select(ngeo, codgeo, reg2016), by = c("CODGEO" = "codgeo")) %>%
  st_transform(2154)

# Apparier epci et région
tabepcireg <- select(ngeo, epci2018, reg2016) %>%
  mutate(epci2018 = as.character(epci2018)) %>%
  distinct() %>%
  group_by(epci2018) %>%
  mutate(nb_reg = length(unique(reg2016)), regtot = paste(reg2016, collapse = ",")) %>%
  select(epci2018, regtot) %>%
  distinct() %>%
  filter(!is.na(epci2018))

# Commune la plus peuplée de chaque EPCI pour cartes communales
comepci <- read.csv2("data/comepci2018.csv", stringsAsFactors = F)

# Création des dossiers vers lesquels seront exportées les cartes
dir.create("cartes")
dir.create("cartes/pdg")
dir.create("cartes/nat")
dir.create("cartes/reg")
dir.create("cartes/loc")

#=================================================================================
# Sélection des epci
listepci <- dataepci$epci2018

# CARTOGRAPHIE
# Cartes de localisation (pour page de garde)
for (epci in listepci){
    
  png(paste0("cartes/pdg/", epci, ".png"), width = 400, height = 400, bg = NA)
  par(mar = c(0,0,0,0))
  
  plot(st_geometry(epci_geo), col = "#d7dae9", border = "#d7dae9", lwd = 10)
  plot(st_geometry(epci_geo), col = "#4e58a0", border = "#4e58a0", add = T)
  plot(st_geometry(filter(epci_geo, codgeo == epci)), col = "#04050d", border = "#04050d", add = T)
  plot(st_buffer(st_centroid(st_geometry(filter(epci_geo, codgeo == epci))), dist = 40000), lwd = 2, col = NA, border = "#04050d", add = T)
  
  dev.off()
}

# Carte nationale niveau epci pour chaque indicateur
for(indic in meta$id){

  dfcarto <- left_join(epci_geo, select(dataepci, epci2018, indic), by = c("codgeo" = "epci2018"))
  
  png(paste0("cartes/nat/", indic, "_nat.png"), width = 827, height = 827)
  
  par(mar = c(0,0,0,0))
  
  choroLayer(x = dfcarto,
             var = indic,
             breaks = eval(parse(text = meta$discr[meta$id == indic])),
             col = eval(parse(text = meta$pal[meta$id == indic])),
             border = NA,
             legend.pos = "none") 
  
  plot(st_geometry(reg_geo), col = NA, border = "white", add = T)
  
  dev.off()
}

# Carte régionale niveau EPCI pour chaque indicateur
for (epci in listepci){
  for(indic in meta$id){
    
    reg <- unlist(strsplit(tabepcireg$regtot[tabepcireg$epci2018 == epci], split=","))

    png(paste0("cartes/reg/", indic, "_reg_", epci,".png"), width = 945, height = 413)
    par(mar = c(0,0,0,0))
    
    dfcarto <- left_join(epci_geo, select(dataepci, epci2018, indic), by = c("codgeo" = "epci2018"))
    
    plot(st_geometry(filter(reg_geo, codgeo %in% c(reg))))
    
    choroLayer(x = dfcarto,
               var = indic,
               breaks = eval(parse(text = meta$discr[meta$id == indic])),
               col = eval(parse(text = meta$pal[meta$id == indic])),
               border = NA,
               legend.pos = "none",
               add = T)
    
    plot(st_geometry(dep_geo), col = NA, border = "white", add = T)
    plot(st_geometry(reg_geo), col = NA, border = "white", lwd = 2, add = T)
    plot(st_geometry(filter(epci_geo, codgeo == epci)), col = NA, border = "grey20", add = T)
    plot(st_geometry(filter(cldep, reg2016 %in% reg)), pch = 18, cex = 2, col = "black", add = T)
    
    labelLayer(x = filter(cldep, reg2016 %in% reg),
               halo = T,
               r = 0.3,
               txt = "LIBGEO",
               pos = 3)
    
    plot(st_geometry(cercles), col = NA, border = "grey80", add = T)

    dev.off()
  }
}

# Carte locale niveau commune pour chaque indicateur
for (epci in listepci){
  for(indic in meta$id){
      
  reg <- unlist(strsplit(tabepcireg$regtot[tabepcireg$epci2018 == epci], split=","))

  comref_geo <- filter(select(com_geo, codgeo), codgeo == comepci$com2018[comepci$epci2018 == epci]) %>%
    left_join(comepci, by = c("codgeo" = "com2018"))
  
  png(paste0("cartes/loc/", indic, "_loc_", epci,".png"), width = 945, height = 413)
  par(mar = c(0,0,0,0))
  
  dfcarto <- left_join(com_geo, select(datacom, CODGEO, indic), by = c("codgeo" = "CODGEO"))
  
  plot(st_geometry(filter(epci_geo, codgeo == epci)))
  
  choroLayer(x = dfcarto,
             var = indic,
             breaks = eval(parse(text = meta$discr[meta$id == indic])),
             col = eval(parse(text = meta$pal[meta$id == indic])),
             border = "white",
             lwd = 0.2,
             legend.pos = "none",
             add = T)
  
  plot(st_geometry(epci_geo), col = NA, border = "white", add = T)
  plot(st_geometry(reg_geo), col = NA, border = "white", lwd = 2, add = T)
  plot(st_geometry(filter(epci_geo, codgeo == epci)), col = NA, border = "grey20", add = T)
  
  labelLayer(x = comref_geo,
             txt = "LIBGEO",
             r = 0.3,
             cex = 1.3,
             halo = T)
  
  dev.off()
  }
}
