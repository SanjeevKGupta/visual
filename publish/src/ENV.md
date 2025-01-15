- [Set ENV](#set-env)
- [Download PTH Model](#downlaod-pth-model)

### Set ENV
- Use as applicable for PyTorch
```
export APP_BIND_HORIZON_DIR=/var/local/horizon
export APP_HOST_IP_ADDRESS="<ip-address-of-host>"
export APP_HOST_PORT="5000"
export APP_MODEL_FMWK="pth_nx"
export APP_MODEL_DIR="${APP_BIND_HORIZON_DIR}/ml/model/pth"
export APP_MI_MODEL="fasterrcnn_resnet50_fpn_v2_coco-dd69338a.pth"
export APP_VIDEO_FILES="${APP_BIND_HORIZON_DIR}/sample/video/sample-video.mp4"
export APP_CAMERAS="-"
export APP_RTSPS="-"
export APP_VIEW_COLUMNS="1"
export DEVICE_ID="<text-string>"
export DEVICE_NAME="Text-String"
export DEVICE_IP_ADDRESS="${APP_HOST_IP_ADDRESS}"
export SHOW_OVERLAY="true"
export PUBLISH_STREAM="true"
export MIN_CONFIDENCE_THRESHOLD="0.8"
export HTTP_PUBLISH_STREAM_URL="http://${APP_HOST_IP_ADDRESS}:${APP_HOST_PORT}/publish/stream"
```

### Downlaod PTH model 
```
wget https://download.pytorch.org/models/$APP_MI_MODEL
```
