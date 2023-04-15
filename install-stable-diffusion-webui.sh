#!/bin/bash

INFO_COLOR='\033[1;34m'
NO_COLOR='\033[0m'

#alias curl='curl -S -s'
#QUIET=' --quiet'

NONPERSISTENT_DIR="/kaggle/tmp"
PERSISTENT_DIR="/kaggle/working"

if [ "x$USE_PERSISTENCE" = "x1" ]; then
    SDW_DIR=$PERSISTENT_DIR/stable-diffusion-webui
else
    SDW_DIR=$NONPERSISTENT_DIR/stable-diffusion-webui
fi

CNET_MODEL_DIR=$NONPERSISTENT_DIR/controlnet-models
MODEL_DIR=$NONPERSISTENT_DIR/stable-diffusion-models
EMB_DIR=$NONPERSISTENT_DIR/stable-diffusion-embeddings

if [ "x$FORCE_REINSTALL" = "x1" ]; then
    rm -rf $NONPERSISTENT_DIR/.memfix $MODEL_DIR $CNET_MODEL_DIR $EMB_DIR $SDW_DIR $NONPERSISTENT_DIR/stable-diffusion-webui
fi

python --version
pip --version
git --version
git lfs install
git lfs --version

# Memory Fix
echo -e "${INFO_COLOR}Installing memory fix packages${NO_COLOR}"
if [ ! -f "$NONPERSISTENT_DIR/.memfix" ]; then
mkdir $NONPERSISTENT_DIR/tmp
cd $NONPERSISTENT_DIR/tmp
curl -Lo memfix.zip https://github.com/nolanaatama/sd-webui/raw/main/memfix.zip
unzip memfix.zip
apt install -y -qq libunwind8-dev
dpkg -i *.deb
cd $NONPERSISTENT_DIR
rm -rf $NONPERSISTENT_DIR/tmp
touch $NONPERSISTENT_DIR/.memfix
fi

# Stable Diffusion WebUI
if [ ! -d "$SDW_DIR" ]; then
    echo -e "${INFO_COLOR}Installing Stable Diffusion WebUI${NO_COLOR}"
    echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Core${NO_COLOR}"
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $SDW_DIR $QUIET
    echo -e "${INFO_COLOR}    Downgrading Stable Diffusion WebUI to a working release${NO_COLOR}"
    cd $SDW_DIR
    #git checkout 22bcc7be428c94e9408f589966c2040187245d81
    git checkout 0cc0ee1
    mv $SDW_DIR/models $MODEL_DIR
    ln -s $MODEL_DIR $SDW_DIR/models
    mkdir $NONPERSISTENT_DIR/{outputs,log}
    ln -s $NONPERSISTENT_DIR/outputs $SDW_DIR/outputs
    ln -s $NONPERSISTENT_DIR/log $SDW_DIR/log
fi

if [ ! -d "$SDW_DIR/models" ]; then
    mkdir -p $NONPERSISTENT_DIR/models/{deepbooru,karlo,Stable-diffusion,VAE,VAE-approx}
    ln -s $MODEL_DIR $SDW_DIR/models
fi

if [ ! -d  "$SDW_DIR/outputs" ]; then
    mkdir -p $NONPERSISTENT_DIR/outputs
    ln -s $NONPERSISTENT_DIR/outputs $SDW_DIR/outputs
fi

if [ ! -d  "$SDW_DIR/log" ]; then
    mkdir -p $NONPERSISTENT_DIR/log
    ln -s $NONPERSISTENT_DIR/log $SDW_DIR/log
fi

if [ ! -d  "$EMB_DIR" ]; then
    mkdir -p $EMB_DIR
    ln -s $EMB_DIR $SDW_DIR/embeddings
fi

# Python VENV
if [ ! -d "$SDW_DIR/venv/bin" ]; then
    echo -e "${INFO_COLOR}Creating Python virtual environment${NO_COLOR}"
    python -m venv $SDW_DIR/venv
fi
echo -e "${INFO_COLOR}Activating Python virtual environment${NO_COLOR}"
source $SDW_DIR/venv/bin/activate
echo -e "${INFO_COLOR}Upgrading Python virtual environment tools${NO_COLOR}"
pip install --upgrade pip setuptools $QUIET

# FastAPI
echo -e "${INFO_COLOR}Installing FastAPI${NO_COLOR}"
pip install --upgrade fastapi==0.90.1 $QUIET

# pyTorch
echo -e "${INFO_COLOR}Installing pyTorch${NO_COLOR}"
pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 torchtext==0.14.1 torchdata==0.5.1 --extra-index-url https://download.pytorch.org/whl/cu117 -U $QUIET

if [ "x$INSTALL_CONTROLNET" = "x1" ]; then
    echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI ControlNet extension${NO_COLOR}"
    if [ ! -d "$SDW_DIR/extensions/sd-webui-controlnet" ]; then 
        git clone https://github.com/Mikubill/sd-webui-controlnet $SDW_DIR/extensions/sd-webui-controlnet $QUIET
    else
        cd $SDW_DIR/extensions/sd-webui-controlnet
        git pull $QUIET
    fi

    echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI OpenPose editor extension${NO_COLOR}"
    if [ ! -d "$SDW_DIR/extensions/openpose-editor" ]; then 
        git clone https://github.com/fkunn1326/openpose-editor $SDW_DIR/extensions/openpose-editor $QUIET
    else
        cd $SDW_DIR/extensions/openpose-editor
        git pull $QUIET
    fi
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Image Browser extension${NO_COLOR}"
if [ ! -d "$SDW_DIR/extensions/stable-diffusion-webui-images-browser" ]; then 
git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser $SDW_DIR/extensions/stable-diffusion-webui-images-browser $QUIET
else
cd $SDW_DIR/extensions/stable-diffusion-webui-images-browser
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI LoCon extension${NO_COLOR}"
if [ ! -d "$SDW_DIR/extensions/a1111-sd-webui-locon" ]; then 
git clone https://github.com/Lucky3x5/a1111-sd-webui-locon $SDW_DIR/extensions/a1111-sd-webui-locon $QUIET
else
cd $SDW_DIR/extensions/a1111-sd-webui-locon
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI LoRA block weight extension${NO_COLOR}"
if [ ! -d "$SDW_DIR/extensions/sd-webui-lora-block-weight" ]; then 
git clone https://github.com/hako-mikan/sd-webui-lora-block-weight $SDW_DIR/extensions/sd-webui-lora-block-weight $QUIET
else
cd $SDW_DIR/extensions/sd-webui-lora-block-weight
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI HighRes Fix extension${NO_COLOR}"
if [ ! -d "$SDW_DIR/extensions/stable-diffusion-webui-hires-fix-progressive" ]; then 
git clone https://github.com/Kahsolt/stable-diffusion-webui-hires-fix-progressive $SDW_DIR/extensions/stable-diffusion-webui-hires-fix-progressive $QUIET
else
cd $SDW_DIR/extensions/stable-diffusion-webui-hires-fix-progressive
git pull $QUIET
fi

## Stable Diffusion Models
echo -e "${INFO_COLOR}    Installing Stable Diffusion Models${NO_COLOR}"
echo -e "${INFO_COLOR}        Models: $SD_MODELS${NO_COLOR}"
read -ra newarr <<< "$SD_MODELS"
for model_url in "${newarr[@]}";
do
    model_name=$(basename "$model_url")
    if [ ! -r "$MODEL_DIR/Stable-diffusion/$model_name" ]; then
    echo -e "${INFO_COLOR}            $model_name${NO_COLOR}"
    curl -Lo "$MODEL_DIR/Stable-diffusion/$model_name" "$model_url"
    fi
done

## ControlNet Models
if [ "x$INSTALL_CONTROLNET" = "x1" ]; then
    echo -e "${INFO_COLOR}    Installing ControlNet Models${NO_COLOR}"
    if [ ! -d "$SDW_DIR/extensions/sd-webui-controlnet/models/.git" ]; then
        git clone https://huggingface.co/webui/ControlNet-modules-safetensors $CNET_MODEL_DIR
        rm -rf $SDW_DIR/extensions/sd-webui-controlnet/models
        ln -s $CNET_MODEL_DIR $SDW_DIR/extensions/sd-webui-controlnet/models
    fi
    cd $CNET_MODEL_DIR
    git pull $QUIET
    git lfs pull $QUIET
fi

## LoRA
echo -e "${INFO_COLOR}    Installing Stable Diffusion LoRAs${NO_COLOR}"
if [ ! -d "$MODEL_DIR/Lora/.git" ]; then
    rm -rf $MODEL_DIR/Lora
    git clone https://huggingface.co/Lucky555/Lora $MODEL_DIR/Lora $QUIET
fi
cd $MODEL_DIR/Lora
git pull $QUIET
git lfs pull $QUIET

## Embeddings
echo -e "${INFO_COLOR}    Installing Stable Diffusion Embeddings${NO_COLOR}"
if [ ! -d "$SDW_DIR/embeddings/.git" ]; then
    git clone https://huggingface.co/Lucky555/embeddings $EMB_DIR $QUIET
    rm -rf $SDW_DIR/embeddings
    ln -s $EMB_DIR $SDW_DIR/embeddings
fi
cd $EMB_DIR
git pull $QUIET
git lfs pull $QUIET

## VAE
echo -e "${INFO_COLOR}    Installing Stable Diffusion VAEs${NO_COLOR}"
if [ ! -d "$MODEL_DIR/VAE/.git" ]; then
    rm -rf $MODEL_DIR/VAE
    git clone https://huggingface.co/Lucky555/VAE $MODEL_DIR/VAE $QUIET
fi
cd $MODEL_DIR/VAE
git pull $QUIET
git lfs pull $QUIET

## ESRGAN
echo -e "${INFO_COLOR}   Installing Stable Diffusion ESRGAN${NO_COLOR}"
if [ ! -d "$MODEL_DIR/ESRGAN" ]; then
    git clone https://huggingface.co/nolanaatama/ESRGAN $MODEL_DIR/ESRGAN $QUIET
fi
cd $MODEL_DIR/ESRGAN
git pull $QUIET
git lfs pull $QUIET

echo -e "${INFO_COLOR}Installation completed"

pip cache purge

# Web UI tunnel
echo -e "${INFO_COLOR}Starting WebUI${NO_COLOR}"
