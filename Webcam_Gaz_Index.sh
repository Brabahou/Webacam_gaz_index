#!/bin/bash

##########__WEBCAM-GAS__#####################
#Programme  capture compteur Gaz RaspberryPi
#JB Bailly
#module principal v1.71
#changement de 5min de roulement + gaz-digits5MLP.pkl
##########__WEBCAM-GAS__#####################

gpio mode 0 out 		#check de la sortie du pin de la LED
#echo "" > fsw-errors.txt & 	#reset du log
horodatage=$(date -d "-1 minutes" "+%Y%m%d%H%M%S") #initialisation pour démarrage

#creation des dossiers pour le traitement Python si inexistants
if [ ! -d "/home/pi/Documents/Captures_webcam/" ];then
   mkdir "/home/pi/Documents/Captures_webcam/"
   fi
if [ ! -d "/home/pi/Documents/Captures_webcam/capture/" ];then
   mkdir "/home/pi/Documents/Captures_webcam/capture/"
   fi
if [ ! -d "/home/pi/Documents/Captures_webcam/centrage/" ];then
   mkdir "/home/pi/Documents/Captures_webcam/centrage/"
   fi
if [ ! -d "/home/pi/Documents/Captures_webcam/decoupe/" ];then
   mkdir "/home/pi/Documents/Captures_webcam/decoupe/"
   fi

while true :
do
 ##test si valeur "horodatage" est dépassé
Now=$(date "+%Y%m%d%H%M%S")
if [ "$Now" -gt "$horodatage" ]
 then
  ##Creation de dossier du jour si non existant
  dossierjour="/home/pi/Documents/Captures_webcam/`date +%Y-%m-%d`/"
  if [ ! -d $dossierjour ];then
   mkdir $dossierjour
  fi

 #script de capture image via webcam
 sh /home/pi/webcamgas/captureimage.sh

 #on ajoute 10 min à l'horodatage pour prochaine capture
 horodatage=$(date -d "+5 minutes" "+%Y%m%d%H%M%S") 

 #script de decoupe de l'image
 sh /home/pi/webcamgas/analyseimage.sh

 #lancement du script Python permettant l'analyse de l'image, le stockage en csv, l'envoi vers ThingSpeak 
 python3 /home/pi/webcamgas/digits_recognition.py >> digits-errors.txt 2>&1

 #deplacement de l'image vers dossier du jour
 mv /home/pi/Documents/Captures_webcam/capture/*.jpeg  $dossierjour

 #suppression du contenu de centrage et decoupe
 cd /home/pi/Documents/Captures_webcam/centrage
 rm -rf *
 cd /home/pi/Documents/Captures_webcam/decoupe
 rm -rf *
 cd /home/pi/webcamgas

 fi
# on fait un sleep 1 pour eviter de tourner la boucle "while true" à vide
sleep 1

done

############ AUTRES COMMANDES###############

####envoi d'email#####
#echo "image webcam" |mutt -s "Webacam-gaz" xx.xx@gmail.com -a /home/pi//Documents/test.jpeg$

####tuer le programme en 1 ligne#####
#kill $(ps -e |grep fswebcam | awk '{print $1}')

