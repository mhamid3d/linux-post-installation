#! /usr/bin/bash


function install_shell_ext () {
	echo "Installing shell extension...${1}"
	cd /tmp/bootstrap_tmp/
	wget "https://extensions.gnome.org/extension-data/${1}"
	ext_uuid=`unzip -c ./${1} metadata.json | grep uuid | cut -d \" -f4`
	mkdir -p ~/.local/share/gnome-shell/extensions/${ext_uuid}
	unzip -q ./${1} -d ~/.local/share/gnome-shell/extensions/${ext_uuid}/
	gnome-shell-extension-tool -e ${ext_uuid}
	gnome-shell-extension-tool -r ${ext_uuid}
	count=`ls -l ~/.local/share/gnome-shell/extensions/${ext_uuid}/schemas/*.xml 2>/dev/null | wc -l`
	if [ $count != 0 ]
	then
	sudo cp ~/.local/share/gnome-shell/extensions/${ext_uuid}/schemas/*.xml /usr/share/glib-2.0/schemas/
	fi
	unset ext_uuid
	unset count
	sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
}

function stage1 () {
	echo "LINUX BOOSTRAP - STARTING ......"

	echo "[Step 1] ...... Yum update and bare minimum installs"

	sudo yum -y update
	sudo yum -y install epel-release
	sudo yum -y install yum-utils
	sudo yum-config-manager --enable powertools
	sudo yum -y update
	
	sudo yum -y groupinstall "Development Tools"

	sudo yum -y install gnome-tweaks dconf-editor
	sudo yum -y install ntfs-3g boost boost-devel bzip2-devel cmake curl glfw glfw-devel libpng-devel samba samba-client mesa-libGLw gamin audiofile audiofile-devel xorg-x11-fonts-ISO8859-1-75dpi xorg-x11-fonts-ISO8859-1-100dpi redhat-lsb-core gtest-devel qbittorrent glew-devel graphviz-devel libtiff-devel jemalloc-devel tbb-devel doxygen OpenEXR-devel OpenImageIO-devel OpenColorIO-devel hdf5-devel gtest-devel tcsh libgcrypt-devel libXScrnSaver
	#sudo yum -y install gcc-toolset-9-gcc gcc-toolset-9-gcc-c++
	sudo yum -y install centos-release-scl-rh
	sudo yum -y install devtoolset-9


	# BASIC GNOME SETTINGS
	echo "[Step 2] ...... Setting gnome shell settings"
	gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
	gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
	#gsettings set org.gnome.shell enabled-extensions "['desktop-icons@gnome-shell-extensions.gcampax.github.com']"
	gsettings set org.gnome.shell enabled-extensions "['top-icons@gnome-shell-extensions.gcampax.github.com']"
	dconf write /org/gtk/settings/file-chooser/show-hidden true
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	gsettings set org.gnome.desktop.background show-desktop-icons true


	# CHROME
	echo "[Step 3] ...... Installing Google Chrome"
	cd /tmp
	mkdir bootstrap_tmp
	cd bootstrap_tmp
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo yum -y install ./google-chrome-stable_current_x86_64.rpm

	# UPDATE FAVORITE APPS, ONLY TERMINAL, CHROME, AND FILES
	echo "[Step 4] ...... Setting favorite apps"
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'google-chrome.desktop']"
	

	# INSTALL EXTENSIONS
	echo "[Step 5] ...... Installing gnome shell extensions"
	install_shell_ext dash-to-paneljderose9.github.com.v42.shell-extension.zip
	install_shell_ext system-monitorparadoxxx.zero.gmail.com.v39.shell-extension.zip
	#install_shell_ext tray-iconszhangkaizhao.com.v6.shell-extension.zip
	install_shell_ext services-systemdabteil.org.v19.shell-extension.zip

	#EXTENSION SETTINGS
	echo "[Step 6] ...... Configuring gnome shell extensions"
	gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 38
	gsettings set org.gnome.shell.extensions.system-monitor cpu-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor memory-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor net-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 85

	cd ~/Pictures
	wget https://wallpaperaccess.com/full/203551.jpg
	dconf write /org/gnome/desktop/background/picture-uri "'file:///home/mhamid/Pictures/203551.jpg'"
	

	#DISABLE SELINUX
	echo "[Step 7] ...... Disabling SELINUX"
	sudo setenfore 0
	sudo sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config


	#INSTALL NVIDIA DRIVERS
	echo "[Step 8] ...... Installing NVIDIA drivers"
	sudo yum -y install kernel-devel dkms
	sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	sudo touch /etc/modprobe.d/blacklist.conf
	sudo chmod 777 /etc/modprobe.d/blacklist.conf
	sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	sudo chmod 755 /etc/modprobe.d/blacklist.conf
	sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
	sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)

	echo "stage2" > /tmp/bootstrap_tmp/.stage

	echo "Restart your machine before continuing. DO NOT LOGIN FOR STAGE 2, ENTER TERMINAL MODE AND RUN THE SCRIPT TO CONTINUE"

}

function stage2 () {
	echo "LINUX BOOSTRAP - RESUMING - STAGE [2] ......"

	#INSTALL NVIDIA DRIVERS
	echo "[Step 8] ...... Installing NVIDIA drivers"
	sudo systemctl isolate multi-user.target
	cd /tmp/bootstrap_tmp
	wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.63.01/NVIDIA-Linux-x86_64-470.63.01.run
	chmod +x ./NVIDIA-Linux-x86_64-*.run
	sudo ./NVIDIA-Linux-x86_64-*.run

	echo "stage3" > /tmp/bootstrap_tmp/.stage
	
	echo "Restart your machine before continuing. YOU CAN USE GUI MODE FROM HERE"
}


function stage3 () {
	echo "LINUX BOOSTRAP - RESUMING - STAGE [3] ......"
	
	#ANACONDA SETUP
	echo "[Step 9] ...... Installing Anaconda"
	cd /tmp/bootstrap_tmp/
	wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
	chmod +x ./Anaconda3-2021.05-Linux-x86_64.sh
	./Anaconda3-2021.05-Linux-x86_64.sh
	ln -s ~/anaconda3 ~/anaconda
	source ~/.bashrc
	conda config --add channels conda-forge
	conda update -n base -c defaults conda -y
	conda create --name cometpy37 python=3.7 -y
	conda activate cometpy37
	conda install -y pyside2 qtpy jinja2 pyopengl pillow requests pyyaml python-dateutil cmake git
	
	#RLM CONFIGURE
	echo "[Step 10] ...... Installing RLM"
	cd /tmp/bootstrap_tmp/data/RLM_Linux-64
	chmod +x ./rlm_install.sh
	sudo ./rlm_install.sh
	source /opt/rlm/rlmenvset.sh
	sudo systemctl daemon-reload
	sudo systemctl restart rlmd
	sudo systemctl enable rlmd

	#INSTALL PYCHARM
	echo "[Step 11] ...... Installing PyCharm"
	cd /tmp/bootstrap_tmp/
	wget https://download-cdn.jetbrains.com/python/pycharm-community-2021.2.tar.gz
	sudo tar -C /opt -zxvf pycharm-community-2021.2.tar.gz
	sudo mv /opt/pycharm-community-2021.2 /opt/PyCharm-Community-2021.2

	#INSTALL BUILDS
	echo "[Step 12] ...... Installing builds"
	sudo mkdir /builds
	sudo chmod -R 777 /builds
	cd /builds
	git clone -b v1.2 https://github.com/colour-science/OpenColorIO-Configs.git
	git clone -b 1.4.0 https://github.com/Psyop/Cryptomatte.git

	cp -r /tmp/bootstrap_tmp/data/ktoa-3.2.2.1-kat4.0-linux /builds/

	cd /tmp/bootstrap_tmp
	wget https://autodesk-adn-transfer.s3-us-west-2.amazonaws.com/ADN+Extranet/M%26E/Maya/devkit+2022/Autodesk_Maya_2022_DEVKIT_Linux.tgz
	mkdir -p /builds/MayaDevkit/2022
	mv devkitBase /builds/MayaDevkit/2022
	
	wget https://peregrinelabs-deploy.s3.amazonaws.com/Bokeh/1.4.8/Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	tar -C /builds -zxvf Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	mv /builds/Bokeh-v1.4.8_Nuke13.0-linux /builds/pgBokeh-v1.4.8

	#SNAP APPS
	echo "[Step 13] ...... Installing Snap"
	sudo yum -y install snapd
	sudo systemctl enable --now snapd.socket
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install snap-store
	sudo snap install snap-store
	sudo snap install code --classic
	sudo snap install discord audacity vlc postman inkscape

	#FOUNDRY PRODUCTS
	echo "[Step 14] ...... Installing Foundry Products"
	cd /tmp/bootstrap_tmp
	wget https://thefoundry.s3.amazonaws.com/products/nuke/releases/13.0v4/Nuke13.0v4-linux-x86_64.tgz
	wget https://thefoundry.s3.amazonaws.com/products/modo/15.1v1/Modo15.1v1_Linux.run
	wget https://thefoundry.s3.amazonaws.com/products/mari/releases/4.7v4/Mari4.7v4-linux-x86-release-64.run
	wget https://thefoundry.s3.amazonaws.com/products/katana/releases/4.0v5/Katana4.0v5-linux-x86-release-64.tgz

	tar -zxvf Nuke13.0v4-linux-x86_64.tgz
	mkdir ./katana
	tar -C ./katana -zxvf Katana4.0v5-linux-x86-release-64.tgz
	tar -zxvf Nuke13.0v4-linux-x86_64.tgz

	chmod +x ./Mari4.7v4-linux-x86-release-64.run
	chmod +x ./Modo15.1v1_Linux.run
	chmod +x ./katana/install.sh
	chmod +x ./Nuke13.0v4-linux-x86_64.run

	sudo mkdir /opt/Mari4.7v4
	sudo mkdir /opt/Modo15.1v1
	sudo mkdir /opt/Katana4.0v5
	sudo mkdir /opt/Nuke13.0v4

	sudo ./Nuke13.0v4-linux-x86_64.run --prefix=/opt --accept-foundry-eula
	sudo ./Mari4.7v4-linux-x86-release-64.run --prefix=/opt/Mari4.7v4 --accept-eula
	sudo ./Modo15.1v1_Linux.run --accept-eula --target /opt/Modo15.1v1
	cd katana
	sudo ./install.sh --no-3delight --accept-eula --katana-path /opt/Katana4.0v5
	
	#SUBSTANCE PRODUCTS
	cd /tmp/bootstrap_tmp/data
	sudo yum -y install ./Substance_Designer-11.1.2-4593-linux-x64-standard.rpm
	sudo yum -y install ./Substance_Painter-7.1.1-954-linux-x64-standard.rpm
	sudo cp ./Substance_Patches/Substance\ Painter /opt/Allegorithmic/Substance_Painter/Substance\ Painter
	sudo cp ./Substance_Patches/Substance\ Designer /opt/Allegorithmic/Substance_Designer/Substance\ Designer
	

	#RV SOFTWARE
	echo "[Step 15] ...... Installing RV Player"
	cd /tmp/bootstrap_tmp
	wget https://sg-software.ems.autodesk.com/deploy/rv/Current_Release/Linux-release.tar.gz
	sudo tar -C /opt -zxvf Linux-release.tar.gz
	sudo mv /opt/rv-centos7-x86-64-2021.1.0 /opt/RV-2021.1.0

	#TLM SERVER
	#echo "[Step 16] ...... Installing TLM License Server"
	#cd /tmp/bootstrap_tmp/data
	#sudo cp -r ./TLM /opt/
	#sudo chmod -R 777 /opt/TLM/
	#cd /opt/TLM/scripts
	#sudo ./install_tlmserver
	#sudo systemctl daemon-reload
	#sudo systemctl restart tlmd
	#sudo systemctl enable tlmd
	
	#MAYA
	echo "[Step 16] ...... Installing MAYA"
	cd /tmp/bootstrap_tmp/data/Maya2022
	sudo yum -y install ./Maya2022_64-2022.0-217.x86_64.rpm
	sudo cp ./maya.bin /usr/autodesk/maya2022/bin/maya.bin
	sudo mv /usr/autodesk/maya2022/bin/ADPClientService /usr/autodesk/maya2022/bin/ADPClientService_NOTHANKYOU
	mkdir -p ~/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo chmod a-rwx /home/mhamid/.autodesk/UI/Autodesk/ADPSDK/JSON/

	#USD
	echo "[Step 17] ...... Installing USD"
	mkdir ~/workspace
	cd ~/workspace
	git clone -b v21.08 https://github.com/PixarAnimationStudios/USD.git
	sudo mkdir /opt/USD
	sudo chmod -R 777 /opt/USD
	conda activate cometpy37
	#source /opt/rh/gcc-toolset-9/enable
	source /opt/rh/devtoolset-9/enable
	conda activate cometpy37
	cd ~/workspace/USD
	python build_scripts/build_usd.py --build-args=USD,"-DPXR_USE_PYTHON_3=ON" --alembic --hdf5 --no-tests --opencolorio --openimageio --usdview /opt/USD
	
	cd ~/workspace
	git clone -b v0.12.0 https://github.com/Autodesk/maya-usd.git
	cd maya-usd
	mkdir workspace
	python build.py --build-args=-DBUILD_WITH_PYTHON_3=ON,-DBUILD_AL_PLUGIN=OFF,-DBUILD_STRICT_MODE=OFF --maya-location /usr/autodesk/maya2022 --pxrusd-location /opt/USD --devkit-location /builds/MayaDevkit/2022/devkitBase --qt-location /home/mhamid/anaconda/envs/cometpy37/lib workspace/
	sudo mkdir -p /usr/autodesk/mayausd/2022/
	sudo cp -r workspace/install/RelWithDebInfo/ /usr/autodesk/mayausd/2022/0.12.0
	sudo mv /usr/autodesk/mayausd/2022/0.12.0/plugin/pxr/lib/python/pxr/UsdMaya /opt/USD/lib/python/pxr/
	sudo chown mhamid:mhamid /opt/USD/lib/python/pxr/UsdMaya/
	sudo rm -rf /usr/autodesk/mayausd/2022/0.12.0/plugin/pxr/lib/python/pxr
	sudo mkdir -p /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.12.0/pxrUSD.mod /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.12.0/mayaUSD.mod /usr/autodesk/modules/maya/2022/
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.12.0/pxrUSD.mod
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.12.0/mayaUSD.mod
	
	#COMETPIPELINE
	echo "[Step 18] ...... Pulling CometPipeline"
	conda activate cometpy37
	git config --global credential.helper store
	mkdir ~/_dev
	cd ~/_dev
	git clone https://github.com/CometPipeline/cometpipeline.git
	git clone https://github.com/CometPipeline/cometpipeline-dcc.git
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_activate.sh ~/anaconda/envs/cometpy37/etc/conda/activate.d/site_env_activate.sh
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_deactivate.sh ~/anaconda/envs/cometpy37/etc/conda/deactivate.d/site_env_deactivate.sh

	echo "\n INSTALL DONE!!!"
	echo "\n"
	echo "\n Please manually do the following tasks:"
	echo "\n 	1) Adjust paths in pxrUSD.mod and mayaUSD.mod to fix their paths"
	echo "\n	2) Generate license.gto file from windows and place it /opt/RV-*/etc/"

}


function bootstrap_enter() {
	if [[ "${BASH_SOURCE[0]}" != "${0}" ]]
	then
		if [ -f /tmp/bootstrap_tmp/.stage ]
		then
		current_stage=`cat /tmp/bootstrap_tmp/.stage`
		eval $current_stage
		else
		stage1
		fi
	else
	echo "You must source this script: 'source ./<script>.sh"
	fi;
}


bootstrap_enter
