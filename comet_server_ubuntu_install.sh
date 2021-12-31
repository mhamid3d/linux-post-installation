#!/bin/bash


sudo apt -y update && sudo apt -y upgrade
git config --global credential.helper store
mkdir ~/dev

sudo apt -y install python3-pip
pip3 install virtualenv

echo | tee -a ~/.bashrc
echo | tee -a ~/.bashrc
echo "export PATH=\$PATH:~/.local/bin" | tee -a ~/.bashrc
source ~/.bashrc

cd ~/dev
virtualenv cometenv
echo | tee -a ~/.bashrc
echo "source ~/dev/cometenv/bin/activate" | tee -a ~/.bashrc
source ~/.bashrc
pip install django djangorestframework djangorestframework-simplejwt
