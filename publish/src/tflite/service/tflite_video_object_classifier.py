#
# tflite_video_object_classifier.py
#
# OpenCV - image capture and image manipulation 
# TensorFlow Lite - object classification using coco_ssd_mobilenet_v1_1.0 model
# Kafka - send inferred meta data and annotated image to event stream
#
# Sanjeev Gupta, April 2020
#

import time

from package import Config
from package import VideoObjectClassifier

if __name__ == '__main__':

    config = Config(resolution=(640, 480), framerate=30)
    sources = config.discoverVideoDeviceSources(8) # Max number of /dev/videoX to discover for

    nsources = len(sources)

    if nsources > 1:
        config.mmsPoller()

        if nsources == 1:
            viewcols = 1
        else:
            viewcols = 2
        
    videoObjectClassifier = None

    index = 0
    for source in sources:
        if videoObjectClassifier is None:
            videoObjectClassifier = VideoObjectClassifier(config, viewcols, "Camera " + str(index + 1), source)
        else:
            videoObjectClassifier.addVideoSource("Camera " + str(index + 1), source)

        videoObjectClassifier.processThread(index)

        index += 1
        
