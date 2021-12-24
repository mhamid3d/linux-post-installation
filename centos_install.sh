#! /usr/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'

function confirm_data() {
	echo ""
	echo ""
	echo -e "${RED}Please download the data_centos.tar file and place it in the /home/mhamid/bootstrap directory"
	echo ""
	echo ""
	read -p "Please enter 'yes' when complete: "
	if [[ ${REPLY} = yes ]];
	then
		return 0;
	else
		return 1;
	fi
}

function install_shell_ext () {
	echo -e "${GREEN}Installing shell extension...${1}"
	cd /home/mhamid/bootstrap/
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
	rm ./${1}
}

function stage1 () {

	echo -e "${GREEN}Updating & Installing required packages..."
	sudo yum -y update
	sudo yum -y install epel-release
	sudo yum -y install yum-utils
	sudo yum-config-manager --enable powertools
	sudo yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
	sudo yum -y update

	sudo yum -y groupinstall "Development Tools"

	sudo yum -y install dconf-editor obs-studio gnome-tweak-tool
	sudo yum -y install ntfs-3g boost boost-devel bzip2-devel cmake curl glfw glfw-devel libpng-devel samba samba-client mesa-libGLw gamin audiofile audiofile-devel xorg-x11-fonts-ISO8859-1-75dpi xorg-x11-fonts-ISO8859-1-100dpi redhat-lsb-core gtest-devel qbittorrent glew-devel graphviz-devel libtiff-devel jemalloc-devel tbb-devel doxygen gtest-devel tcsh libgcrypt-devel libXScrnSaver wine vlc libdbusmenu unar
	sudo yum -y install centos-release-scl-rh
	sudo yum -y install devtoolset-9

	echo -e "${GREEN}Mounting Main disk..."
	sudo mkdir -p /mnt/mhamid/Main
	sudo chmod -R 777 /mnt/mhamid
	echo '/dev/sda2	/mnt/mhamid/Main	ntfs-3g defaults	0 0' | sudo tee -a /etc/fstab

	echo -e "${GREEN}Configuring GNOME Shell Settings..."
	gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
	gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
	gsettings set org.gnome.shell enabled-extensions "['top-icons@gnome-shell-extensions.gcampax.github.com']"
	dconf write /org/gtk/settings/file-chooser/show-hidden true
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	gsettings set org.gnome.desktop.background show-desktop-icons true

	echo -e "${GREEN}Installing Google Chrome..."
	cd ~
	mkdir bootstrap
	cd bootstrap
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo yum -y install ./google-chrome-stable_current_x86_64.rpm
	rm ./google-chrome-stable_current_x86_64.rpm

	echo -e "${GREEN}Installing Teamviewer..."
	wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.25.5.x86_64.rpm
	sudo yum -y install ./teamviewer_15.25.5.x86_64.rpm
	rm ./teamviewer_15.25.5.x86_64.rpm

	until confirm_data; do : ; done

	tar -C /home/mhamid/bootstrap -xvf /home/mhamid/bootstrap/data_centos.tar
	rm /home/mhamid/bootstrap/data_centos.tar

	echo -e "${GREEN}Configuring favorite apps..."
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'google-chrome.desktop']"

	echo "Installing gnome shell extensions..."
	install_shell_ext dash-to-paneljderose9.github.com.v42.shell-extension.zip
	install_shell_ext system-monitorparadoxxx.zero.gmail.com.v39.shell-extension.zip
	install_shell_ext services-systemdabteil.org.v19.shell-extension.zip
	gsettings set org.gnome.shell enabled-extensions "['top-icons@gnome-shell-extensions.gcampax.github.com', 'dash-to-panel@jderose9.github.com', 'system-monitor@paradoxxx.zero.gmail.com', 'services-systemd@abteil.org']"

	echo -e "${GREEN}Configuring gnome shell extensions..."
	gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 42
	gsettings set org.gnome.shell.extensions.dash-to-panel trans-use-custom-opacity 1
	gsettings set org.gnome.shell.extensions.dash-to-panel trans-panel-opacity 0.6
	gsettings set org.gnome.shell.extensions.system-monitor cpu-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor memory-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor net-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 85

	echo -e "${GREEN}Configuring Wallpaper..."
	cd ~/Pictures
	wget https://w.wallhaven.cc/full/ox/wallhaven-oxoz6l.png
	dconf write /org/gnome/desktop/background/picture-uri "'file:///home/mhamid/Pictures/wallhaven-oxoz6l.png'"

	echo -e "${GREEN}Disabling SELINUX..."
	sudo setenfore 0
	sudo sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

	sudo hostnamectl set-hostname tundra
	echo '127.0.0.1 localhost tundra' | sudo tee -a /etc/hosts

	echo -e "${GREEN}Installing NVIDIA drivers..."
	sudo yum -y install kernel-devel dkms
	sudo sed -i 's#GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"#GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet rd.driver.blacklist=nouveau nouveau.modeset=0"#g' /etc/default/grub
	sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	sudo touch /etc/modprobe.d/blacklist.conf
	sudo chmod 777 /etc/modprobe.d/blacklist.conf
	sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	sudo chmod 755 /etc/modprobe.d/blacklist.conf
	sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
	sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)

	echo "stage2" > /home/mhamid/bootstrap/.stage

	echo -e "${RED}Restart your machine before continuing. DO NOT LOGIN FOR STAGE 2, ENTER TERMINAL MODE AND RUN THE SCRIPT TO CONTINUE"

}

function stage2 () {
	echo -e "${GREEN}LINUX BOOSTRAP - RESUMING - STAGE [2] ......"

	echo -e "${GREEN}Installing NVIDIA drivers..."
	sudo systemctl isolate multi-user.target
	cd /home/mhamid/bootstrap
	wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.63.01/NVIDIA-Linux-x86_64-470.63.01.run
	chmod +x ./NVIDIA-Linux-x86_64-*.run
	sudo ./NVIDIA-Linux-x86_64-*.run
	rm ./NVIDIA-Linux-x86_64-*.run

	echo "stage3" > /home/mhamid/bootstrap/.stage

	echo -e "${RED}Restart your machine before continuing. YOU CAN USE GUI MODE FROM HERE"
}

function stage3 () {
	echo -e "${GREEN}LINUX BOOSTRAP - RESUMING - STAGE [3] ......"

	echo -e "${GREEN}Installing Anaconda..."
	cd /home/mhamid/bootstrap/
	wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
	chmod +x ./Anaconda3-2021.11-Linux-x86_64.sh
	./Anaconda3-2021.11-Linux-x86_64.sh
	rm Anaconda3-2021.11-Linux-x86_64.sh
	ln -s ~/anaconda3 ~/anaconda
	source ~/.bashrc
	conda config --add channels conda-forge
	conda update -n base -c defaults conda -y

	conda create --name cometpy37 python=3.7 -y
	conda create --name cometpy37libs python=3.7 -y --no-default-packages
	conda create --name cometpy27libs python=2.7 -y --no-default-packages

	conda activate cometpy37libs
	conda install -y qtpy pillow jinja2 pyopengl pillow requests pyyaml python-dateutil setproctitle
	pip install timeago

	conda activate cometpy27libs
	conda install -y qtpy pillow jinja2 pyopengl pillow requests pyyaml python-dateutil setproctitle
	pip install timeago

	conda activate cometpy37
	conda install -y pyside2 qtpy jinja2 pyopengl pillow requests pyyaml python-dateutil cmake git setproctitle libcurl syncthing psutil
	conda install -y -c bioconda perl-local-lib
	pip install timeago
	ln -s ~/anaconda/envs/cometpy37/syncthing ~/anaconda/envs/cometpy37/bin/syncthing

	echo -e "${GREEN}Installing RLM..."
	cd /home/mhamid/bootstrap/data/RLM_Linux-64
	chmod +x ./rlm_install.sh
	sudo ./rlm_install.sh
	source /opt/rlm/rlmenvset.sh
	sudo systemctl daemon-reload
	sudo systemctl restart rlmd
	sudo systemctl enable rlmd

	echo -e "${GREEN}Installing PyCharm..."
	cd /home/mhamid/bootstrap/
	wget https://download-cdn.jetbrains.com/python/pycharm-community-2021.1.3.tar.gz
	sudo tar -C /opt -zxvf pycharm-community-2021.1.3.tar.gz
	rm ./pycharm-community-2021.1.3.tar.gz
	sudo mv /opt/pycharm-community-2021.1.3 /opt/PyCharm-Community-2021.1.3

	echo -e "${GREEN}Installing builds..."
	sudo mkdir /builds
	sudo chmod -R 777 /builds
	cd /builds
	git clone -b v1.2 https://github.com/colour-science/OpenColorIO-Configs.git
	git clone -b 1.4.0 https://github.com/Psyop/Cryptomatte.git

	cp -r /home/mhamid/bootstrap/data/ktoa-3.2.2.1-kat4.0-linux /builds/

	cd /home/mhamid/bootstrap
	wget https://autodesk-adn-transfer.s3-us-west-2.amazonaws.com/ADN+Extranet/M%26E/Maya/devkit+2022/Autodesk_Maya_2022_DEVKIT_Linux.tgz
	mkdir -p /builds/MayaDevkit/2022
	tar -zxvf Autodesk_Maya_2022_DEVKIT_Linux.tgz
	mv devkitBase /builds/MayaDevkit/2022
	rm ./Autodesk_Maya_2022_DEVKIT_Linux.tgz

	wget https://peregrinelabs-deploy.s3.amazonaws.com/Bokeh/1.4.8/Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	tar -C /builds -zxvf Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	rm ./Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	mv /builds/Bokeh-v1.4.8_Nuke13.0-linux /builds/pgBokeh-v1.4.8


	echo -e "${GREEN}Installing Snap..."
	sudo yum -y install snapd
	sudo systemctl enable --now snapd.socket
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install snap-store
	sudo snap install snap-store
	sudo snap install code --classic
	sudo snap install slack --classic
	sudo snap install discord audacity postman inkscape

	echo -e "${GREEN}Installing Foundry Products..."
	cd /home/mhamid/bootstrap
	wget https://thefoundry.s3.amazonaws.com/products/nuke/releases/13.1v1/Nuke13.1v1-linux-x86_64.tgz
	wget https://thefoundry.s3.amazonaws.com/products/modo/15.1v1/Modo15.1v1_Linux.run
	wget https://s3.amazonaws.com/thefoundry/products/mari/releases/5.0v1/Mari5.0v1-linux-x86-release-64.run
	wget https://thefoundry.s3.amazonaws.com/products/katana/releases/5.0v1/Katana5.0v1-linux-x86-release-64.tgz

	tar -zxvf Nuke13.1v1-linux-x86_64.tgz
	rm ./Nuke13.1v1-linux-x86_64.tgz
	mkdir ./katana
	tar -C ./katana -zxvf Katana5.0v1-linux-x86-release-64.tgz
	rm ./Katana5.0v1-linux-x86-release-64.tgz

	chmod +x ./Mari5.0v1-linux-x86-release-64.run
	chmod +x ./Modo15.1v1_Linux.run
	chmod +x ./katana/install.sh
	chmod +x ./Nuke13.1v1-linux-x86_64.run

	sudo mkdir /opt/Mari5.0v1
	sudo mkdir /opt/Modo15.1v1
	sudo mkdir /opt/Katana5.0v1
	sudo mkdir /opt/Nuke13.1v1

	sudo ./Nuke13.1v1-linux-x86_64.run --prefix=/opt --accept-foundry-eula
	sudo ./Mari5.0v1-linux-x86-release-64.run --prefix=/opt/Mari5.0v1 --accept-eula
	sudo ./Modo15.1v1_Linux.run --accept-eula --target /opt/Modo15.1v1
	cd katana
	sudo ./install.sh --no-3delight --accept-eula --katana-path /opt/Katana5.0v1

	cd ..
	rm ./Modo15.1v1_Linux.run
	rm ./Mari5.0v1-linux-x86-release-64.run
	rm -rf ./katana
	rm ./Nuke13.1v1-linux-x86_64.run

	echo -e "${GREEN}Installing Substance products..."
	cd /home/mhamid/bootstrap
	wget https://download.substance3d.com/adobe-substance-3d-designer/11.x/Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	wget https://download.substance3d.com/adobe-substance-3d-painter/7.x/Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm
	sudo yum -y install ./Adobe_Substance_3D*.rpm
	rm Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	rm Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm
	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Designer /opt/Adobe/Adobe_Substance_3D_Designer/Adobe\ Substance\ 3D\ Designer
	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Painter /opt/Adobe/Adobe_Substance_3D_Painter/Adobe\ Substance\ 3D\ Painter

	echo -e "${GREEN}Installing Houdini 19..."
	cd /home/mhamid/bootstrap
	tar -zxvf data/houdini-19.0.383-linux_x86_64_gcc9.3.tar.gz
	cd houdini-19.0.383-linux_x86_64_gcc9.3/
	sudo ./houdini.install
	cd ..
	rm -rf ./houdini-19.0.383-linux_x86_64_gcc9.3
	sudo systemctl daemon-reload
	sudo /etc/init.d/sesinetd stop
	sudo cp /home/mhamid/bootstrap/data/Houdini_Patches/sesinetd /usr/lib/sesi/sesinetd
	sudo cp /home/mhamid/bootstrap/data/Houdini_Patches/sesinetd /usr/lib/sesi/sesinetd
	sudo /etc/init.d/sesinetd start
	sudo chmod +x /home/mhamid/bootstrap/data/Houdini_Patches/Houdini-Tools

	echo -e "${GREEN}Installing Davinci Resolve..."
	cd /home/mhamid/bootstrap/data
	chmod +x ./DaVinci_Resolve_Studio_17.2.2_Linux.run
	sudo ./DaVinci_Resolve_Studio_17.2.2_Linux.run -i
	sudo cp ./ResolveCrack/resolve /opt/resolve/bin/resolve
	rm ~/Desktop/com.blackmagicdesign.resolve.desktop

	echo -e "${GREEN}Installing RV Player..."
	cd /home/mhamid/bootstrap
	wget https://sg-software.ems.autodesk.com/deploy/rv/Current_Release/Linux-release.tar.gz
	sudo tar -C /opt -zxvf Linux-release.tar.gz
	sudo mv /opt/rv-centos7-x86-64-* /opt/RV
	rm Linux-release.tar.gz

	echo -e "${GREEN}Installing Maya..."
	cd /home/mhamid/bootstrap/data/Maya2022
	sudo yum -y install ./Maya2022_64-2022.0-217.x86_64.rpm
	sudo cp ./maya.bin /usr/autodesk/maya2022/bin/maya.bin
	sudo mv /usr/autodesk/maya2022/bin/ADPClientService /usr/autodesk/maya2022/bin/ADPClientService_NOTHANKYOU
	mkdir -p ~/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo chmod a-rwx /home/mhamid/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo /usr/autodesk/maya2022/bin/mayapy -m pip install pymel

	echo -e "${GREEN}Installing Pixar USD..."
	mkdir ~/workspace
	cd ~/workspace
	git clone -b v21.11 https://github.com/PixarAnimationStudios/USD.git
	sudo mkdir /opt/USD
	sudo chmod -R 777 /opt/USD
	conda activate cometpy37
	source /opt/rh/devtoolset-9/enable
	conda activate cometpy37
	cd ~/workspace/USD
	python build_scripts/build_usd.py --build-args=USD,"-DPXR_USE_PYTHON_3=ON" --alembic --hdf5 --no-tests --opencolorio --openimageio --usdview /opt/USD

	echo -e "${GREEN}Installing Maya USD..."
	cd ~/workspace
	git clone -b v0.15.0 https://github.com/Autodesk/maya-usd.git
	cd maya-usd
	mkdir workspace
	python build.py --build-args=-DBUILD_WITH_PYTHON_3=ON,-DBUILD_AL_PLUGIN=OFF,-DBUILD_STRICT_MODE=OFF --maya-location /usr/autodesk/maya2022 --pxrusd-location /opt/USD --devkit-location /builds/MayaDevkit/2022/devkitBase --qt-location /home/mhamid/anaconda/envs/cometpy37/lib workspace/
	sudo mkdir -p /usr/autodesk/mayausd/2022/
	sudo cp -r workspace/install/RelWithDebInfo/ /usr/autodesk/mayausd/2022/0.15.0
	sudo mv /usr/autodesk/mayausd/2022/0.15.0/plugin/pxr/lib/python/pxr/UsdMaya /opt/USD/lib/python/pxr/
	sudo chown mhamid:mhamid /opt/USD/lib/python/pxr/UsdMaya/
	sudo rm -rf /usr/autodesk/mayausd/2022/0.15.0/plugin/pxr/lib/python/pxr
	sudo mkdir -p /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.15.0/pxrUSD.mod /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.15.0/mayaUSD.mod /usr/autodesk/modules/maya/2022/
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.15.0/pxrUSD.mod
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.15.0/mayaUSD.mod
	sudo sed -i 's#/home/mhamid/workspace/maya-usd/workspace/install/RelWithDebInfo#/usr/autodesk/mayausd/2022/0.15.0#g' /usr/autodesk/mayausd/2022/0.15.0/mayaUSD.mod
	sudo sed -i 's#/home/mhamid/workspace/maya-usd/workspace/install/RelWithDebInfo#/usr/autodesk/mayausd/2022/0.15.0#g' /usr/autodesk/mayausd/2022/0.15.0/pxrUSD.mod

	echo -e "${GREEN}Pulling CometPipeline"
	conda activate cometpy37
	git config --global credential.helper store
	mkdir ~/_dev
	cd ~/_dev
	git clone https://github.com/CometPipeline/cometpipeline.git
	git clone https://github.com/CometPipeline/cometpipeline-dcc.git
	mkdir -p ~/anaconda/envs/cometpy37/etc/conda/activate.d
	mkdir -p ~/anaconda/envs/cometpy37/etc/conda/deactivate.d
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_activate.sh ~/anaconda/envs/cometpy37/etc/conda/activate.d/site_env_activate.sh
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_deactivate.sh ~/anaconda/envs/cometpy37/etc/conda/deactivate.d/site_env_deactivate.sh

	echo -e "${GREEN}Patching Houdini..."
	cd /opt/hfs19.0.383
	source ./houdini_setup
	sesi_id=`/usr/lib/sesi/sesictrl print-server | grep SERVER | tr '\n' ' ' | awk '{print $NF}' | xargs`
	sesi_host=`/usr/lib/sesi/sesictrl print-server | grep SERVER | tr '\n' ' ' | awk '{print $(NF-1)}' | xargs`
	printf "$sesi_host\n$sesi_id" | /home/mhamid/bootstrap/data/Houdini_Patches/Houdini-Tools | grep -E 'SERVER|LICENSE' | sed 's/Enter server name:Enter server id://g' | tee /home/mhamid/bootstrap/hfs_keys.txt
	while IFS="" read hfs_key; do
		/usr/lib/sesi/sesictrl install "$hfs_key"
	done </home/mhamid/bootstrap/hfs_keys.txt

	unset sesi_id
	unset sesi_host
	rm /home/mhamid/bootstrap/hfs_keys.txt

	echo -e "${GREEN}Copying bashrc file..."
	cp /home/mhamid/bootstrap/data/.bashrc ~/.bashrc

	echo -e "\n INSTALL DONE!!!"
	echo -e "\n"
	echo -e "\n Please manually do the following tasks:"
	echo -e "\n	1) Generate license.gto file from windows and place it /opt/RV-*/etc/"

}


function bootstrap_enter() {
	if [[ "${BASH_SOURCE[0]}" != "${0}" ]]
	then
		if [ -f /home/mhamid/bootstrap/.stage ]
		then
		current_stage=`cat /home/mhamid/bootstrap/.stage`
		eval $current_stage
		else
		stage1
		fi
	else
	echo "You must source this script: 'source ./<script>.sh"
	fi;
}


bootstrap_enter
unset GREEN
unset RED
