##########__WEBCAM-GAS__#####################
#Programme  capture compteur Gaz RaspberryPi
#JB Bailly
#module de capture d'image v1.0
##########__WEBCAM-GAS__#####################

#allumage LED
gpio write 0 1
sleep 2
    
#prise de vue avec fswebcam, enregistrement avec date+heure dans dossier "capture",
# envoi vers "capture", recetion sorties du programmes dans "fsw-errors.txt"
fswebcam --log log_fswebcam -d /dev/video0 -i 0 -r 640x480 /home/pi/Documents/Captures_webcam/capture/CAM-%Y-%m-%d--%H-%M-%S.jpeg >> fsw-errors.txt 2>&1

sleep 5
#eteindre LED
gpio write 0 0

#test si message d'erreur dans le log de fswebcam
nerror=`grep VIDIOC_STREAMON log_fswebcam | wc -l`

#si message d'erreur existant
if [ $nerror -eq 1 ] ; then
	#note la date dans la sauvegarde d'erreur
	echo `date +%Y-%m-%d--%H-%M-%S` >> fsw-errors.txt
	#on cherche le n° de port usb de la Webcam
	num=$(lsusb | grep Web | awk '{print $4}' | cut -f1 -d":")
	# on reset le port de la webcam
	sudo /opt/usbreset/usbreset /dev/bus/usb/001/$num >> fsw-errors.txt 2>&1 
	#vidage des fichiers logs
	echo "" >> fsw-errors.txt		
	echo "" > log_fswebcam &
	#on relance alors la capture
	fswebcam --log log_fswebcam -d /dev/video0 -i 0 -r 640x480 /home/pi/Documents/Captures_webcam/capture/CAM-%Y-%m-%d--%H-%M-%S.jpeg >> fsw-errors.txt 2>&1
fi
