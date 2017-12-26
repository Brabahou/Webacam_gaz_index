# -*- coding:Utf8 -*-

##########__WEBCAM-GAS__#####################
#Programme  capture compteur Gaz RaspberryPi
#JB Bailly
#module python3 d'anlayse de valeur dans l'image
##########__WEBCAM-GAS__#####################


import matplotlib
# use a non-interactive backend 
matplotlib.use('agg')
import matplotlib.pyplot as plt
import thingspeak as ts

import numpy as np

from scipy import misc
import skimage
from skimage.transform import resize
import os
import pickle

#read images 
i=0
filenames=[]
dirname = "/home/pi/Documents/Captures_webcam/decoupe/"
for fname in os.listdir(dirname):
    filenames.append(os.path.join(dirname, fname))
filenames.sort()

# Read every filename as an RGB image
imgs = [plt.imread(fname).astype(np.uint8) for fname in filenames]

# Crop every image to a square
def imcrop_tosquare(img):
    """Make any image a square image.  """
    size = np.min(img.shape[:2])
    extra = img.shape[:2] - size
    crop = img
    for i in np.flatnonzero(extra):
        crop = np.take(crop, extra[i] // 2 + np.r_[:size], axis=i)
    return crop
imgs = [imcrop_tosquare(img_i) for img_i in imgs]

# Then resize the square image to 28 x 28 pixels
imgs = [resize(img_i, (28, 28), mode='constant') for img_i in imgs]

#convert images to 1D
images=np.array(imgs).reshape(-1,28*28)

#on charge le classifieur
with open('gaz-digits4MLP.pkl', 'rb') as fichier:
     mon_depickler = pickle.Unpickler(fichier)
     classifier = mon_depickler.load()

#index de la valeur max de sortie du classifieur 
#qui correspond au chiffre identifié, pour chaque image
index=list(classifier.predict(images))

#concatenation de la liste des vlaeurs en un seul nombre
index = str(index)[1:-1].replace(",", "").replace(" ", "")

#recuperation du nom du fichier complet contenant la date & heure
#sortie sous forme '29/03/2017 11:03:09'

time=filenames[0].split('/')[-1][4:-14].split('-')
timestamp=time[2]+'/'+time[1]+'/'+time[0]+' '+time[4]+':'+time[5]+':'+time[6]

#enregistrement dans le fichier index
with open('index.csv', 'a') as fichier:
    fichier.write(timestamp+';'+index+';'+proba+'\n')
    
#envoi des données sur "Thingspeak"
ts.sendthingspeak(timestamp,index)
