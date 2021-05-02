#
# videoObjectDetector.py
#
# An implementation using IBM Edge Application Manager (IEAM) to deploy container workloads on edge nodes
#
# IEAM - containers deployment and life cycle management
# IEAM Deployment Policy - policy based
# IEAM MMS - Model Management System for machine inferencing model deployments to edge nodes
#
# OpenCV - image capture and image manipulation 
# TensorFlow Lite - object classification using coco_ssd_mobilenet_v1_1.0 model
# Kafka - send inferred meta data and annotated image to event stream
#
# Sanjeev Gupta, April 2020
#
# - A simple video device discoverer connected via USB
# - Consumes RTSP streams additionally
# - Python threads for each video source feed
#   - OpenCV based video capture
#   - mobilenet tflite based object detector
#   - OpenCV for image annotation
#   - Dynamic consolidation of each video streams in presentation frame
#   - Configutable horizontal and vertical layout 
# - Local viewing over http
# - Result streaming to Kafka based event stream 
# - Result visualization in grafana after processing via cloud function
# - Separate threads for MMS based configuration and model updates

from package import Config
from package.video import VideoSourceProcessor

import importlib.util
import os
import time

if __name__ == '__main__':
    print ("{:.7f} Entered main {}".format(time.time(), os.environ['DEVICE_IP_ADDRESS']))

    config = Config(os.environ['APP_MODEL_FMWK'], framerate=30)

    sources = {}
    sources['camera'] = config.discoverVideoDeviceSources(8)
    sources['rtsp'] = config.getRTSPStreams()
    sources['file'] = config.getVideoFiles()

    index = 0
    videoSourceProcessor = None

    # source can have value int 0 which will evalute to False if tested for "if source:"
    for source in sources['camera']:
        sourceName = "Video " + str(index + 1) + "    /dev/video" + str(source)
        print ("{:.7f} Video source: ".format(time.time()), sourceName, index, end="\n", flush=True)
        if videoSourceProcessor is None:
            videoSourceProcessor = VideoSourceProcessor(config, "camera", source, sourceName)
        else:
            videoSourceProcessor.addVideoSource("camera", source, sourceName)

        videoSourceProcessor.processThread(index, True)
        index += 1
        
    for source in sources['rtsp']:
        if source: 
            sourceName = "Video " + str(index + 1) + "    " + source
            #createVideoSourceProcessor(config, "rtsp", source, sourceName, index, videoSourceProcessor, True)
            print ("{:.7f} Video source: ".format(time.time()), sourceName, index, end="\n", flush=True)
            if videoSourceProcessor is None:
                videoSourceProcessor = VideoSourceProcessor(config, "rtsp", source, sourceName)
            else:
                videoSourceProcessor.addVideoSource("rtsp", source, sourceName)

            videoSourceProcessor.processThread(index, True)
            index += 1
        
    for source in sources['file']:
        if source: 
            sourceName = "Video " + str(index + 1) + "    " + source
            #createVideoSourceProcessor(config, "file", source, sourceName, index, videoSourceProcessor, True)
            print ("{:.7f} Video source: ".format(time.time()), sourceName, index, end="\n", flush=True)
            if videoSourceProcessor is None:
                videoSourceProcessor = VideoSourceProcessor(config, "file", source, sourceName)
            else:
                videoSourceProcessor.addVideoSource("file", source, sourceName)

            videoSourceProcessor.processThread(index, True)
            index += 1
            
    if videoSourceProcessor is None:
        print ("{:.7f} No video source found".format(time.time()), end="\n", flush=True)
    else:
        config.mmsPoller()
            
    
