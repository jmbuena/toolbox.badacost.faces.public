#!/usr/bin/env python
import pylab
import numpy as np
import os
colorCounter = 1
color_list = pylab.cm.tab20(np.linspace(0, 1, 40))


def getColorLabel(name):
    print (name)
    global colorCounter, color_list
    if name.find("SquaresChnFtrs") != -1 or name.find("Baseline") != -1:
        color = 'black'
        #label = "HeadHunter SquaresChnFtrs-5"
        label = "SquaresChnFtrs-5"
    elif name.find("Ours_Headhunter") != -1 or name.find("Ours HeadHunter") != -1:
        color = 'r'
        label = "HeadHunter"
    elif name.find("Face++") != -1:
        color = 'b'
        label = "Face++"
    elif name.find("Picasa") != -1:
        color = 'r'
        label = "Picasa"
    elif name.find("Structured") != -1:
        color = color_list[10]
        label = "Structured Models"
    elif name.find("WS_Boosting") != -1:
        color = color_list[1]
        label = "W.S. Boosting"
    elif name.find("Sky") != -1:
        color = color_list[2]
        label = "Sky Biometry"
    elif name.find("OpenCV") != -1:
        color = color_list[3]
        label = "OpenCV"
    elif name.find("TSM") != -1:
        color = color_list[4]
        label = "TSM"
    elif name.find("DPM") != -1 or name.find("<0.3") != -1:
        color = color_list[8]
        #color = 'b'
        label = "HeadHunter DPM"
    elif name.find("Shen") != -1:
        color = color_list[7]
        #color = 'b'
        label = "Shen et al. [27]"
    elif name.find("Viola") != -1:
        #color = color_list[9]
        color = 'b'
        label = "Viola Jones"
#    elif name.find("BAdaCost") != -1:
#        color = color_list[11]
#        label = "BAdaCost"
#    elif name.find("K-Binary") != -1:
#        color = color_list[13]
#        label = "K-Binary"
#    elif name.find("SAMME") != -1:
#        color = color_list[15]
#        label = "SAMME"
    else:
        color = color_list[colorCounter]
        colorCounter = colorCounter + 2
        print name
        label = os.path.splitext(os.path.basename(name))[0]
        label = label.replace("_", " ")
    return [color, label]
