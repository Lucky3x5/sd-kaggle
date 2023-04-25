#!/bin/bash

INFO_COLOR='\033[1;34m'
NO_COLOR='\033[0m'

#alias curl='curl -S -s'
#QUIET=' --quiet'

NONPERSISTENT_DIR="/kaggle/tmp"
PERSISTENT_DIR="/kaggle/working"

if [ "x$FORCE_REINSTALL" = "x1" ]; then
    rm -rf $NONPERSISTENT_DIR/.memfix $NONPERSISTENT_DIR/repositories $NONPERSISTENT_DIR/stable-diffusion-webui
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
echo -e "${INFO_COLOR}Installing Stable Diffusion WebUI${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui" ]; then
    echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Core${NO_COLOR}"
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $NONPERSISTENT_DIR/stable-diffusion-webui $QUIET
fi
echo -e "${INFO_COLOR}    Downgrading Stable Diffusion to a working release${NO_COLOR}"
cd $NONPERSISTENT_DIR/stable-diffusion-webui
git fetch
#git checkout 22bcc7be428c94e9408f589966c2040187245d81
git checkout 0cc0ee1

# Python VENV
if [ ! -d "$NONPERSISTENT_DIR/stable-diffusion-webui/venv/bin" ]; then
    echo -e "${INFO_COLOR}Creating Python virtual environment${NO_COLOR}"
    python -m venv $NONPERSISTENT_DIR/stable-diffusion-webui/venv
fi
echo -e "${INFO_COLOR}Activating Python virtual environment${NO_COLOR}"
source $NONPERSISTENT_DIR/stable-diffusion-webui/venv/bin/activate
echo -e "${INFO_COLOR}Upgrading Python virtual environment tools${NO_COLOR}"
pip install --upgrade pip setuptools

# FastAPI
echo -e "${INFO_COLOR}Installing FastAPI${NO_COLOR}"
pip install --upgrade fastapi==0.90.1 $QUIET

# pyTorch
echo -e "${INFO_COLOR}Installing pyTorch${NO_COLOR}"
pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 torchtext==0.14.1 torchdata==0.5.1 --extra-index-url https://download.pytorch.org/whl/cu117 -U $QUIET

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Image Browser extension${NO_COLOR}"
if [ ! -d "$NONPERSISTENT_DIR/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser" ]; then 
    git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser $NONPERSISTENT_DIR/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser $QUIET
else
    cd $NONPERSISTENT_DIR/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
    git pull $QUIET
fi

## Stable Diffusion Models
echo -e "${INFO_COLOR}    Installing Stable Diffusion Models${NO_COLOR}"
echo -e "${INFO_COLOR}        Models: $SD_MODELS${NO_COLOR}"
read -ra newarr <<< "$SD_MODELS"
for model_url in "${newarr[@]}";
do
    model_name=$(basename "$model_url")
    if [ ! -r "$NONPERSISTENT_DIR/stable-diffusion-webui/models/Stable-diffusion/$model_name" ]; then
    echo -e "${INFO_COLOR}            $model_name${NO_COLOR}"
    curl -Lo "$NONPERSISTENT_DIR/stable-diffusion-webui/models/Stable-diffusion/$model_name" "$model_url"
    fi
done

## VAE
echo -e "${INFO_COLOR}    Installing Stable Diffusion VAEs${NO_COLOR}"
if [ ! -d "$NONPERSISTENT_DIR/stable-diffusion-webui/models/VAE/.git" ]; then
    rm -rf $NONPERSISTENT_DIR/stable-diffusion-webui/models/VAE
    git clone https://huggingface.co/Lucky555/VAE $NONPERSISTENT_DIR/stable-diffusion-webui/models/VAE $QUIET
fi
cd $NONPERSISTENT_DIR/stable-diffusion-webui/models/VAE
git pull $QUIET
git lfs pull $QUIET

## ESRGAN
echo -e "${INFO_COLOR}   Installing Stable Diffusion ESRGAN${NO_COLOR}"
if [ ! -d "$NONPERSISTENT_DIR/stable-diffusion-webui/models/ESRGAN" ]; then
    git clone https://huggingface.co/nolanaatama/ESRGAN $NONPERSISTENT_DIR/stable-diffusion-webui/models/ESRGAN $QUIET
fi
cd $NONPERSISTENT_DIR/stable-diffusion-webui/models/ESRGAN
git pull $QUIET
git lfs pull $QUIET

echo -e "${INFO_COLOR}Installation completed"

# Web UI tunnel
echo -e "${INFO_COLOR}Starting WebUI${NO_COLOR}"
