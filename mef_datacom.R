## Script de mise en forme des données communales
# CL, OT, décembre 2018

rm(list = ls())

library(dplyr)
library(readxl)
library(COGugaison)

#=================================================================================
# CHARGEMENT DES INDICATEURS CALCULES PAR BDL

mobilite <- read_xlsx("data/mobilite 20181218.xlsx")
sante <- read_xlsx("data/sante 20181217.xlsx")
numerique <- read_xlsx("data/numerique 20181218.xlsx")
neet <- read_xlsx("data/neet 20181217.xlsx")
cine <- read_xlsx("data/cinetheatre 201917.xlsx")
emploi <- read_xlsx("data/txemploi 201919.xlsx")
logement <- read_xlsx("data/logementsvacants.xlsx")
elec <- read_xlsx("data/elect 2019110.xlsx")

revenu_c <- read_xlsx("data/niv com median revenu.xlsx")
revenu_e <- read_xlsx("data/niv epci median revenu.xlsx")

revenu_e$epci2018 <- as.numeric(revenu_e$epci2018)

meta <- read_xlsx("data/meta.xlsx")
ngeo <- read_xlsx("data/n_geo.xlsx", sheet = "com")

#=================================================================================
# MISE EN FORME ET JOINTURE DES DONNEES

# Tester COG
COG_akinator(mobilite$codgeo, T) # 2018
COG_akinator(sante$codgeo, T) # NULL => à tester // le fichier contient les arrondissement municipaux // COG 2018
COG_akinator(numerique$codgeo, T) # NULL => à tester // des données pour les COM à supprimer // COG 2018
COG_akinator(neet$CODGEO, T) # 2017 // à convertir en COG 2018
COG_akinator(cine$CODGEO, T) # 2018
COG_akinator(emploi$CODGEO) # 2018
COG_akinator(logement$CODGEO) # 2017
COG_akinator(elec$codgeo, T) # NULL => à tester // COG 2018
COG_akinator(revenu_c$CODGEO, T) # NULL => à tester // COG 2018

# Conversion des fichiers qui ne le sont pas en COG 2018
mobilite <- select(mobilite, codgeo, numerateur, denominateur) %>%
  setNames(c("CODGEO", "num_mobilite", "denum_mobilite"))
sante <- select(sante, codgeo, numerateur, denominateur) %>%
  enlever_PLM(agregation = T) %>%
  setNames(c("CODGEO", "num_sante", "denum_sante"))
numerique <- select(numerique, codgeo, numerateur, denominateur) %>%
  filter(!(substr(codgeo, 1, 3) %in% c("975", "977", "978"))) %>%
  setNames(c("CODGEO", "num_numerique", "denum_numerique"))
neet <- select(neet, CODGEO, numerateur, denominateur) %>%
  changement_COG_varNum(c(2017:2018), agregation = T) %>%
  setNames(c("CODGEO", "num_neet", "denum_neet"))
cine <- select(cine, CODGEO, numerateur, denominateur, HC_PRESENC) %>%
  mutate(numerateur = ifelse(HC_PRESENC == "9999", NA, as.numeric(numerateur))) %>%
  mutate(denominateur = ifelse(HC_PRESENC == "9999", NA, as.numeric(denominateur))) %>%
  select(-HC_PRESENC) %>%
  setNames(c("CODGEO", "num_cine", "denum_cine"))
emploi <- select(emploi, CODGEO, numerateur, denominateur) %>%
  setNames(c("CODGEO", "num_emploi", "denum_emploi"))
logement <- select(logement, CODGEO, numerateur, denominateur) %>%
  changement_COG_varNum(c(2017:2018), agregation = T) %>%
  setNames(c("CODGEO", "num_logement", "denum_logement"))
elec <- select(elec, codgeo, numerateur, denominateur) %>%
  setNames(c("CODGEO", "num_elec", "denum_elec"))
  
# Jointure
datajoin <- full_join(mobilite, sante, by = "CODGEO") %>%
  full_join(numerique, by = "CODGEO") %>%
  full_join(neet, by = "CODGEO") %>%
  full_join(cine, by = "CODGEO") %>%
  full_join(emploi, by = "CODGEO") %>%
  full_join(logement, by = "CODGEO") %>%
  full_join(elec, by = "CODGEO")

#=================================================================================
# CALCUL DES INDICATEURS
datacom <- select(datajoin, CODGEO)
dataepci <- select(ngeo, epci2018) %>% distinct()

#for(indic in meta$id){
for(indic in c("ID_1","ID_2", "ID_3", "ID_4", "ID_5", "ID_6", "ID_7", "ID_8")){
    
  temp_com <- datajoin %>%
    mutate(result = eval(parse(text = meta$calc[meta$id == indic]))) %>%
    select(CODGEO, result) %>%
    setNames(c("CODGEO", indic))
  
  datacom <- full_join(datacom, temp_com, by = "CODGEO")
  
  temp_epci <- datajoin %>%
    left_join(select(ngeo, com2018, epci2018), by = c("CODGEO" = "com2018")) %>%
    select(-CODGEO) %>%
    group_by(epci2018) %>%
    summarise_all(sum, na.rm = T) %>%
    mutate(result = eval(parse(text = meta$calc[meta$id == indic]))) %>%
    select(epci2018, result) %>%
    setNames(c("epci2018", indic))
  
  dataepci <- full_join(dataepci, temp_epci, by = "epci2018")
}


datacom  <- full_join(datacom, revenu_c, by = "CODGEO")
dataepci  <- full_join(dataepci, revenu_e, by = "epci2018")



#=================================================================================
# CALCUL DES INDICATEURS


#=================================================================================
# EXPORT
write.csv2(datacom, "data/datacom.csv", row.names = F)
write.csv2(dataepci, "data/dataepci.csv", row.names = F)

