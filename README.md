# KitsCarto-GdDebat

<p align="right">
  <img src="https://raw.githubusercontent.com/observatoire-territoires/KitsCarto-GdDebat/master/img/logoGDN.png" width="256">
</p>     
     
Les scripts présents dans ce dossier permettent la production automatisée des dossiers cartographiques réalisés dans le cadre du Grand Débat National lancé le 15 janvier 2019 (https://granddebat.fr). 

Les kits cartographiques créés grâce à ces scripts sont disponibles pour l'ensemble des EPCI grâce à une carte interactive accessible au lien suivant : 

https://cget-carto.github.io/le-grand-debat-national/

La construction des kits cartographiques se déroule en 2 étapes : d'abord la production des cartes au format image  (script *carto.R*), puis la production des kits au format pdf (script *exportpdf.R*). Les kits sont produits grâce à un script RMarkdown (*dossierCarto.Rmd*) qui fait largement appel au langage Latex pour la mise en page.

Ces scripts peuvent être répliqués en utilisant d'autres indicateurs, en appliquant les scripts sur un échantillon d'EPCI voire en changeant la maille d'observation (canton, zone d'emploi,...) en modifiant un peu le code.

</br>
<p align="center">
  <img src="https://raw.githubusercontent.com/observatoire-territoires/KitsCarto-GdDebat/master/img/couv_ex.png" width="500">
</p>     
