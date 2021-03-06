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

sudo apt -y install postgresql postgresql-contrib

pip install django djangorestframework djangorestframework-simplejwt


sudo ufw allow OpenSSH
sudo ufw enable

echo "export COMET_DB=comet" >> ~/.bashrc

# generate the password from https://passwordsgenerator.net/ and place it in the COMET_DB_PWD env var in bashrc
