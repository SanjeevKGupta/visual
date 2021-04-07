#!/bin/sh
#
# edge device register unregister pattern policy
# 
#

RED="\033[31m"
GREEN="\033[32m"
OFF="\033[0m"

usage() {                      
  echo "Usage: $0 -e -k -m -r -u -p -l"
  echo "where "
  echo "   -k framework tflite | vino | mvi | mvi_p100 | pth_cpu | pth_gpu_noterm "
  echo "   -e file path to environemnt veriables "
  echo "   -m file path to mvi model file "
  echo "   -r register "
  echo "   -u unregister "
  echo "   -p pattern based deployment "
  echo "   -l policy based deployment "
}

fn_chk_env() {
    if [ -z $HZN_ORG_ID ]; then 
	echo "Must set HZN_ORG_ID in ENV file "
    fi

    if [ -z $HZN_EXCHANGE_USER_AUTH ]; then 
	echo "Must set HZN_EXCHANGE_USER_AUTH in ENV file "
    fi
}

fn_register_with_policy() {
    echo "${GREEN}Registering with ... ${OFF}"
    echo "   node_policy_${FMWK}.json"
    echo "   user_input_app_${FMWK}.json"

    hzn exchange node create -n $HZN_EXCHANGE_NODE_AUTH
    hzn register --policy=node_policy_${FMWK}.json --input-file user_input_app_${FMWK}.json
}

fn_register_with_mms_pattern() {
    echo "Registering with pattern... "

    . $ENVVAR

    fn_chk_env

    ARCH=`hzn architecture`

    hzn exchange node create -n $HZN_EXCHANGE_NODE_AUTH
    hzn register --pattern "${HZN_ORG_ID}/pattern-${EDGE_OWNER}.${EDGE_DEPLOY}.mms-${ARCH}" --input-file user-input-app.json --policy=node_policy_privileged.json
}

fn_register_with_pattern() {
    echo "Registering with pattern... "

    . $ENVVAR

    fn_chk_env

    ARCH=`hzn architecture`

    hzn exchange node create -n $HZN_EXCHANGE_NODE_AUTH
    hzn register --pattern "${HZN_ORG_ID}/pattern-${EDGE_OWNER}.${EDGE_DEPLOY}.tflite-${ARCH}" --input-file user-input-app.json --policy=node_policy_privileged.json
}

fn_unregister() {
    echo "Un-registering... "

    . $ENVVAR

    fn_chk_env

    hzn unregister -vrD
}

while getopts 'e:k:m:rlupm' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    k) FMWK=$OPTARG
       ;;
    e) ENVVAR=$OPTARG
       ;;
    m) MI_MODEL=$OPTARG
       ;;
    r) register=1
       ;;
    l) policy=1
       ;;
    u) unregister=1
       ;;
    p) pattern=1
       ;;
    m) mmspattern=1
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ -z $ENVVAR ]; then
    echo ""
    echo "Must provide one of the options to set ENV vars ENV_HZN_DEV, ENV_HZN_DEMO etc"
    echo ""
    usage
    exit 1
fi

if [ -z $FMWK ]; then
    echo ""
    echo "Must provide one of the options to set framework vino | tflite | mvi | mvi_p100 | pth_cpu | pth_gpu_noterm "
    echo ""
    usage
    exit 1
elif [ "$FMWK" = "tflite" ] || [ "$FMWK" = "vino" ] || [ "$FMWK" = "mvi" ] || [ "$FMWK" = "mvi_p100" ] || [ "$FMWK" = "pth_cpu" ] || [ "$FMWK" = "pth_gpu_noterm" ]; then

    . $ENVVAR

    fn_chk_env

    echo "\n${GREEN}Framework $FMWK"
    if [ "$FMWK" = "mvi" ] || [ "$FMWK" = "pth_cpu" ] || [ "$FMWK" = "pth_gpu_noterm" ]; then
	if [ ! -z $MI_MODEL ]; then 
	    if [ -f $MI_MODEL ]; then 
		echo "${RED}Creating directory "
		MODEL_DIR="$APP_BIND_HORIZON_DIR/ai/mi/model/$FMWK"
		mkdir -p $MODEL_DIR
		if [ -d $MODEL_DIR ]; then 
		    export APP_MI_MODEL=$MI_MODEL
		    if [ "$FMWK" = "mvi" ]; then
			echo "${OFF}Copying $MI_MODEL $MODEL_DIR/mi_mvi_model.zip"
			cp $MI_MODEL $MODEL_DIR/mi_mvi_model.zip
		    else
			echo "${OFF}Copying $MI_MODEL to $MODEL_DIR"
			cp $MI_MODEL $MODEL_DIR
		    fi
		else
		    echo "\n${RED}Failed creating directoy $MODEL_DIR\nProvide 777 privilege to $APP_BIND_HORIZON_DIR directory so that model files can be copied.\n"
		    exit 1
		fi
	    else
		echo "\n${RED}Model file $MI_MODEL does not exist.\n"
		exit 1
	    fi
	else
	    echo "\n${RED}For $FMWK, must provide a valid ML model using -m option.\n"
	    exit 1
	fi
    elif [ "$FMWK" = "mvi_p100" ]; then
	export APP_MI_MODEL="Remote model"
	echo "\n${RED}Make sure that remote model detector is running"
    else
	export APP_MI_MODEL="Local model $FMWK"
    fi
else
    echo ""
    echo "Must provide one of the options to set framework vino | tflite | mvi | mvi_p100 | pytorch"
    echo ""
    usage
    exit 1
fi

if [ ! -z $register ]; then
    if [ ! -z $pattern ]; then
	fn_register_with_pattern
    elif [ ! -z $mmspattern ]; then
	fn_register_with_mms_pattern
    elif [ ! -z $policy ]; then
	fn_register_with_policy
    else
       echo "Must provide one of the options -p or -l"
       usage
       exit 1
    fi
elif [ ! -z $unregister ]; then
    fn_unregister
else
    echo "Must provide one of the options -r or -u"
    usage
    exit 1
fi


