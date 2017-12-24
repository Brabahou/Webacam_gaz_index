#!/bin/bash

##########__WEBCAM-GAS__#####################
#Programme  capture compteur Gaz RaspberryPi
#JB Bailly
#module prendre les images capturées dans le dossier ,
# les contraster , mettre en forme v1.0
##########__WEBCAM-GAS__#####################


#dossier racine avec scrit et dossier 'capture' , 'decoupe, ', 'centrage'
DossRacine='/home/pi/Documents/Captures_webcam/'


cd "$DossRacine"capture
Images="*.jpeg"
rot=179.6
Larg=397
LargPix=294
Haut=51
X=97
Y=240
Def=60
Bright=40
Cont=40
Neg="-negate"

#largeur en pixel pour 1 chiffre
LgTl=$(echo `echo "last=0; scale=4; ($LargPix/7)"  | bc `) 2>&1

for image in $Images
 do
  M=$(identify -format %[mean] $image)
  Lum=$(printf %.0f `echo "scale=3; ($M/65535)*100"  | bc -l `) 2>&1

  if [ $Lum -lt 29 ] ; then
#image "sombre"
    Bright=45
    Cont=65
   elif [ $Lum -gt 45 ] ; then
#image claire "clair"
    Bright=65
    Cont=75
#sinon, on laisse Bright a sa couleur par defaut "normal"
  fi
  #suppression du .jpeg
  image=${image%.*}

  #creation des paramètres pour ImageMagik
  Param=" -rotate $rot -colorspace Gray "$Neg" -crop "$Larg"x"$Haut"+"$X"+"$Y" -scale "$Def"% -contrast-stretch "$Bright"x"$Cont" "
  convert "$DossRacine""capture/""$image.jpeg" $Param +repage "$DossRacine""centrage/""$image.jpeg" 2>&1
  
  #division de l'image en numeros individuels
    cd "$DossRacine"centrage
    ImgMod="$image.jpeg"
    convert $ImgMod -crop 34x"$Haut" "$DossRacine""decoupe/$image-parts-%02d.jpeg" 2>&1
    cd "$DossRacine"
 done

exit 0
