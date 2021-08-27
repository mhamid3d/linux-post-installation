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
	sudo yum -y install ntfs-3g boost boost-devel bzip2-devel cmake curl glfw glfw-devel libpng-devel samba samba-client mesa-libGLw gamin audiofile audiofile-devel xorg-x11-fonts-ISO8859-1-75dpi xorg-x11-fonts-ISO8859-1-100dpi redhat-lsb-core gtest-devel qbittorrent glew-devel graphviz-devel libtiff-devel jemalloc-devel tbb-devel doxygen OpenEXR-devel OpenImageIO-devel OpenColorIO-devel hdf5-devel gtest-devel gcc-toolset-9-gcc gcc-toolset-9-gcc-c++


	# BASIC GNOME SETTINGS
	echo "[Step 2] ...... Setting gnome shell settings"
	gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
	gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
	gsettings set org.gnome.shell enabled-extensions "['desktop-icons@gnome-shell-extensions.gcampax.github.com']"
	dconf write /org/gtk/settings/file-chooser/show-hidden true
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'


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
	install_shell_ext tray-iconszhangkaizhao.com.v6.shell-extension.zip
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


	#SNAP APPS
	echo "[Step 13] ...... Installing Snap"
	sudo yum -y install snapd
	sudo systemctl enable --now snapd.socket
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install snap-store
	sudo snap install snap-store
	sudo snap install code --classic
	sudo snap install discord audacity vlc postman inkscape
}


function bootstrap_enter() {
	if [ -f /tmp/bootstrap_tmp/.stage ]
	then
	current_stage=`cat /tmp/bootstrap_tmp/.stage`
	eval $current_stage
	else
	stage1
	fi
}


bootstrap_enter

