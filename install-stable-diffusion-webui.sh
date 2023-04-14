#!/bin/bash

INFO_COLOR='\033[1;34m'
NO_COLOR='\033[0m'

#alias curl='curl -S -s'
#QUIET=' --quiet'

NONPERSISTENT_DIR="/kaggle/tmp"
PERSISTENT_DIR="/kaggle/working"

if [ "x$FORCE_REINSTALL" = "x1" ]; then
    rm -rf $NONPERSISTENT_DIR/.memfix $NONPERSISTENT_DIR/repositories $PERSISTENT_DIR/stable-diffusion-webui
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
cd /kaggle/tmp
if [ ! -d "/kaggle/tmp/stable-diffusion-webui" ]; then
echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Core${NO_COLOR}"
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui $QUIET
fi
echo -e "${INFO_COLOR}    Downgrading Stable Diffusion to a working release${NO_COLOR}"
cd /kaggle/tmp/stable-diffusion-webui
git fetch
#git checkout 22bcc7be428c94e9408f589966c2040187245d81
git checkout 0cc0ee1

# Python VENV
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/venv/bin" ]; then
echo -e "${INFO_COLOR}Creating Python virtual environment${NO_COLOR}"
python -m venv /kaggle/tmp/stable-diffusion-webui/venv
fi
echo -e "${INFO_COLOR}Activating Python virtual environment${NO_COLOR}"
source /kaggle/tmp/stable-diffusion-webui/venv/bin/activate
echo -e "${INFO_COLOR}Upgrading Python virtual environment tools${NO_COLOR}"
pip install --upgrade pip setuptools

# FastAPI
echo -e "${INFO_COLOR}Installing FastAPI${NO_COLOR}"
pip install --upgrade fastapi==0.90.1 $QUIET

# pyTorch
echo -e "${INFO_COLOR}Installing pyTorch${NO_COLOR}"
pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 torchtext==0.14.1 torchdata==0.5.1 --extra-index-url https://download.pytorch.org/whl/cu117 -U $QUIET

if [ "x$INSTALL_CONTROLNET" = "x1" ]; then

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI ControlNet extension${NO_COLOR}"
	
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet" ]; then 
git clone https://github.com/Mikubill/sd-webui-controlnet /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet
git pull $QUIET
fi


echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI OpenPose editor extension${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/openpose-editor" ]; then 
git clone https://github.com/fkunn1326/openpose-editor /kaggle/tmp/stable-diffusion-webui/extensions/openpose-editor $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/openpose-editor
git pull $QUIET
fi

fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI Image Browser extension${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser" ]; then 
git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser /kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI LoCon extension${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/a1111-sd-webui-locon" ]; then 
git clone https://github.com/Lucky3x5/a1111-sd-webui-locon /kaggle/tmp/stable-diffusion-webui/extensions/a1111-sd-webui-locon $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/a1111-sd-webui-locon
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI LoRA block weight extension${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-lora-block-weight" ]; then 
git clone https://github.com/hako-mikan/sd-webui-lora-block-weight /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-lora-block-weight $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-lora-block-weight
git pull $QUIET
fi

echo -e "${INFO_COLOR}    Installing Stable Diffusion WebUI HighRes Fix extension${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-hires-fix-progressive" ]; then 
git clone https://github.com/Kahsolt/stable-diffusion-webui-hires-fix-progressive /kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-hires-fix-progressive $QUIET
else
cd /kaggle/tmp/stable-diffusion-webui/extensions/stable-diffusion-webui-hires-fix-progressive
git pull $QUIET
fi

## Stable Diffusion Models
echo -e "${INFO_COLOR}    Installing Stable Diffusion Models${NO_COLOR}"
echo -e "${INFO_COLOR}        Models: $SD_MODELS${NO_COLOR}"
read -ra newarr <<< "$SD_MODELS"
for model_url in "${newarr[@]}";
do
    model_name=$(basename "$model_url")
    if [ ! -r "/kaggle/tmp/stable-diffusion-webui/models/Stable-diffusion/$model_name" ]; then
    echo -e "${INFO_COLOR}            $model_name${NO_COLOR}"
    curl -Lo "/kaggle/tmp/stable-diffusion-webui/models/Stable-diffusion/$model_name" "$model_url"
    fi
done

if [ "x$INSTALL_CONTROLNET" = "x1" ]; then
## ControlNet Models
echo -e "${INFO_COLOR}    Installing ControlNet Models${NO_COLOR}"
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_canny.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_depth.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_depth-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_hed-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_hed-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_mlsd-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_mlsd-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_normal-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_normal-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_openpose-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_scribble-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_scribble-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/control_seg-fp16.safetensors https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_seg-fp16.safetensors
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_canny_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_canny_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_color_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_color_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_depth_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_depth_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_keypose_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_keypose_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_openpose_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_openpose_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_seg_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_seg_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_sketch_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_sketch_sd14v1.pth
#curl -Lo /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/t2iadapter_style_sd14v1.pth https://huggingface.co/TencentARC/T2I-Adapter/resolve/main/models/t2iadapter_style_sd14v1.pth
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models/.git" ]; then
rm -rf /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models
git clone https://huggingface.co/webui/ControlNet-modules-safetensors /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models
fi
cd /kaggle/tmp/stable-diffusion-webui/extensions/sd-webui-controlnet/models
git pull $QUIET
git lfs pull $QUIET
fi

## LoRA
echo -e "${INFO_COLOR}    Installing Stable Diffusion LoRAs${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/models/Lora/.git" ]; then
rm -rf /kaggle/tmp/stable-diffusion-webui/models/Lora
git clone https://huggingface.co/Lucky555/Lora /kaggle/tmp/stable-diffusion-webui/models/Lora $QUIET
fi
cd /kaggle/tmp/stable-diffusion-webui/models/Lora
git pull $QUIET
git lfs pull $QUIET

## Embeddings
echo -e "${INFO_COLOR}    Installing Stable Diffusion Embeddings${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/embeddings/.git" ]; then
rm -rf /kaggle/tmp/stable-diffusion-webui/embeddings
git clone https://huggingface.co/Lucky555/embeddings /kaggle/tmp/stable-diffusion-webui/embeddings $QUIET
fi
cd /kaggle/tmp/stable-diffusion-webui/embeddings
git pull $QUIET
git lfs pull $QUIET

## VAE
echo -e "${INFO_COLOR}    Installing Stable Diffusion VAEs${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/models/VAE/.git" ]; then
rm -rf /kaggle/tmp/stable-diffusion-webui/models/VAE
git clone https://huggingface.co/Lucky555/VAE /kaggle/tmp/stable-diffusion-webui/models/VAE $QUIET
fi
cd /kaggle/tmp/stable-diffusion-webui/models/VAE
git pull $QUIET
git lfs pull $QUIET

## ESRGAN
echo -e "${INFO_COLOR}   Installing Stable Diffusion ESRGAN${NO_COLOR}"
if [ ! -d "/kaggle/tmp/stable-diffusion-webui/models/ESRGAN" ]; then
git clone https://huggingface.co/nolanaatama/ESRGAN /kaggle/tmp/stable-diffusion-webui/models/ESRGAN $QUIET
fi
cd /kaggle/tmp/stable-diffusion-webui/models/ESRGAN
git pull $QUIET
git lfs pull $QUIET

echo -e "${INFO_COLOR}Installation completed"

# Web UI tunnel
echo -e "${INFO_COLOR}Starting WebUI${NO_COLOR}"
