
##########__WEBCAM-GAS__#####################
#Programme  capture compteur Gaz RaspberryPi
#JB Bailly
#module python3 permettant d'envoyer les data sur ThingSpeak
##########__WEBCAM-GAS__#####################

from __future__ import print_function
import paho.mqtt.publish as publish
import psutil
import personnaldata as pdata

channelID=		pdata.channelID
writeAPIKey=	pdata.writeAPIKey
mqttHost=		pdata.mqttHost
mqttUsername=	pdata.mqttUsername
mqttAPIKey=		pdata.mqttAPIKey

tTransport = "websockets"
tPort = 80
topic = "channels/" + channelID + "/publish/" + writeAPIKey

def sendthingspeak(timestamp,index):
	# Create the topic string.
	payload = "field1=" + str(timestamp) + "&field2=" + str(index)
	 # attempt to publish this data to the topic.
	publish.single(topic, payload, hostname=mqttHost, transport=tTransport, port=tPort,auth={'username':mqttUsername,'password':mqttAPIKey})


