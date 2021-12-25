#!/bin/bash


RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'


function confirm_data() {
	echo ""
	echo ""
	echo -e "${GREEN}Please download the data_centos.tar file and place it in the ~/bootstrap directory${NC}"
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
	echo -e "${GREEN}Installing shell extension...${1}${NC}"
	cd ~/bootstrap
	wget "https://extensions.gnome.org/extension-data/${1}"
	ext_uuid=`unzip -c ./${1} metadata.json | grep uuid | cut -d \" -f4`
	mkdir -p ~/.local/share/gnome-shell/extensions/${ext_uuid}
	unzip -q ./${1} -d ~/.local/share/gnome-shell/extensions/${ext_uuid}/
	gnome-extensions enable ${ext_uuid}
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


function stage1() {

	echo -e "${GREEN}##########################################"
	echo -e "Bootstrap beginning [STAGE 1]..."
	echo -e "##########################################${NC}"
	###

	echo -e "${GREEN}##########################################"
	echo -e "Tweaking DNF Configuration..."
	echo -e "##########################################${NC}"
	###
	echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
	echo "maxparallel_downloads=20" | sudo tee -a /etc/dnf/dnf.conf


	echo -e "${GREEN}##########################################"
	echo -e "Updating & Installing required packages..."
	echo -e "##########################################${NC}"
	###
	sudo dnf -y update
	sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf -y makecache
	sudo dnf -y update
	sudo dnf -y install google-chrome-stable obs-studio gnome-tweaks dconf-editor ntfs-3g cmake curl glfw glfw-devel libpng-devel mesa-libGLw-devel mesa-libGLU-devel qbittorrent wine vlc unar gparted libzip-devel gnome-extensions-app file-roller file-roller-nautilus VirtualBox pycharm-community inkscape discord audacity audiofile audiofile-devel xorg-x11-fonts-ISO8859-1-75dpi xorg-x11-fonts-ISO8859-1-100dpi libpng15


	echo -e "${GREEN}##########################################"
	echo -e "Mounting Main Disk + FSTAB Entry..."
	echo -e "##########################################${NC}"
	###
	sudo mkdir -p /mnt/mhamid/Main
	sudo chmod -R 777 /mnt/mhamid
	sudo mount /dev/sda2 /mnt/mhamid/Main
	echo '/dev/sda2	/mnt/mhamid/Main	ntfs-3g defaults	0 0' | sudo tee -a /etc/fstab


	cd ~
	mkdir bootstrap
	cd ~/bootstrap
	echo -e "${GREEN}##########################################"
	echo -e "Installing GNOME Shell Extensions..."
	echo -e "##########################################${NC}"
	###
	install_shell_ext dash-to-paneljderose9.github.com.v45.shell-extension.zip
	sudo dnf -y install gnome-shell-extension-topicons-plus
	#install_shell_ext system-monitorparadoxxx.zero.gmail.com.v39.shell-extension.zip
	#install_shell_ext services-systemdabteil.org.v19.shell-extension.zip


	echo -e "${GREEN}##########################################"
	echo -e "Configuring GNOME Shell Settings..."
	echo -e "##########################################${NC}"
	###
	gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
	gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
	dconf write /org/gtk/settings/file-chooser/show-hidden true
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	gsettings set org.gnome.desktop.background show-desktop-icons true
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'google-chrome.desktop']"
	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	gsettings set ca.desrt.dconf-editor.Settings show-warning false
	gsettings set org.gnome.desktop.session idle-delay 90
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
	gnome-extensions disable background-logo@fedorahosted.org
	#gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com', 'system-monitor@paradoxxx.zero.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com']"
	gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com', 'appindicatorsupport@rgcjonas.gmail.com']"
	gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 42
	gsettings set org.gnome.shell.extensions.dash-to-panel trans-use-custom-opacity true
	gsettings set org.gnome.shell.extensions.dash-to-panel trans-panel-opacity 0.65
	gsettings set org.gnome.shell.extensions.system-monitor cpu-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor memory-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor net-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 85


	echo -e "${GREEN}##########################################"
	echo -e "Installing TeamViewer..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
	wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.25.5.x86_64.rpm
	sudo dnf -y install ./teamviewer_15.25.5.x86_64.rpm
	rm ./teamviewer_15.25.5.x86_64.rpm


	echo -e "${GREEN}##########################################"
	echo -e "Setting Awesome Wallpaper..."
	echo -e "##########################################${NC}"
	###
	cd ~/Pictures
	mkdir Wallpapers
	cd Wallpapers
	wget https://raw.githubusercontent.com/mhamid3d/linux-post-installation/main/wallpaper_wallpaperflare.jpg
	dconf write /org/gnome/desktop/background/picture-uri "'file:///home/mhamid/Pictures/Wallpapers/wallpaper_wallpaperflare.jpg'"


	echo -e "${GREEN}##########################################"
	echo -e "Changing Host name..."
	echo -e "##########################################${NC}"
	###
	sudo hostnamectl set-hostname fedora
	echo '127.0.0.1 localhost fedora' | sudo tee -a /etc/hosts


	echo -e "${GREEN}##########################################"
	echo -e "Preparing install of NVIDIA Drivers..."
	echo -e "##########################################${NC}"
	###
	sudo dnf -y install kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
	echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist.conf
	sudo sed -i 's#GRUB_CMDLINE_LINUX="rhgb quiet.*#GRUB_CMDLINE_LINUX="rhgb quiet rd.driver.blacklist=nouveau"#g' /etc/default/grub
	sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	sudo dnf -y remove xorg-x11-drv-nouveau
	sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
	sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)
	sudo systemctl set-default multi-user.target
	
	echo "stage2" > ~/bootstrap/.stage
	
	echo -e "${RED}##########################################"
	echo -e "Restart your computer now, it will boot in terminal mode, just source the installer again and it will continue..."
	echo -e "##########################################${NC}"
	###
}

function stage2() {
	echo -e "${GREEN}##########################################"
	echo -e "Bootstrap resuming [STAGE 2]..."
	echo -e "##########################################${NC}"
	###
	
	echo -e "${GREEN}##########################################"
	echo -e "Installing NVIDIA Drivers..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
	wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.94/NVIDIA-Linux-x86_64-470.94.run
	chmod +x ./NVIDIA-Linux-x86_64-470.94.run
	sudo ./NVIDIA-Linux-x86_64-470.94.run
	sudo systemctl set-default graphical.target
	
	echo "stage3" > ~/bootstrap/.stage
	
	echo -e "${RED}##########################################"
	echo -e "Restart your computer now, it will boot in graphical mode again, just source the installer again and it will continue..."
	echo -e "##########################################${NC}"
	###
}


function stage3() {

	echo -e "${GREEN}##########################################"
	echo -e "Bootstrap resuming [STAGE 3]..."
	echo -e "##########################################${NC}"
	###

	echo -e "${GREEN}##########################################"
	echo -e "Installing Anaconda..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap/
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
	pip install timeago
	ln -s ~/anaconda/envs/cometpy37/syncthing ~/anaconda/envs/cometpy37/bin/syncthing


	until confirm_data; do : ; done
	tar -C ~/bootstrap -xvf ~/bootstrap/data_centos.tar
	rm ~/bootstrap/data_centos.tar


	echo -e "${GREEN}##########################################"
	echo -e "Installing RLM..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap/data/RLM_Linux-64
	chmod +x ./rlm_install.sh
	sudo ./rlm_install.sh
	source /opt/rlm/rlmenvset.sh
	sudo systemctl daemon-reload
	sudo systemctl restart rlmd
	sudo systemctl enable rlmd


	echo -e "${GREEN}##########################################"
	echo -e "Installing Builds..."
	echo -e "##########################################${NC}"
	###
	sudo mkdir /builds
	sudo chmod -R 777 /builds
	cd /builds
	git clone -b v1.2 https://github.com/colour-science/OpenColorIO-Configs.git
	git clone -b 1.4.0 https://github.com/Psyop/Cryptomatte.git

	cp -r ~/bootstrap/data/ktoa-3.2.2.1-kat4.0-linux /builds/

	cd ~/bootstrap
	wget https://autodesk-adn-transfer.s3-us-west-2.amazonaws.com/ADN+Extranet/M%26E/Maya/devkit+2022/Autodesk_Maya_2022_DEVKIT_Linux.tgz
	mkdir -p /builds/MayaDevkit/2022
	tar -zxvf Autodesk_Maya_2022_DEVKIT_Linux.tgz
	mv devkitBase /builds/MayaDevkit/2022
	rm ./Autodesk_Maya_2022_DEVKIT_Linux.tgz

	wget https://peregrinelabs-deploy.s3.amazonaws.com/Bokeh/1.4.8/Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	tar -C /builds -zxvf Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	rm ./Bokeh-v1.4.8_Nuke13.0-linux.tar.gz
	mv /builds/Bokeh-v1.4.8_Nuke13.0-linux /builds/pgBokeh-v1.4.8


	echo -e "${GREEN}##########################################"
	echo -e "Installing Snap..."
	echo -e "##########################################${NC}"
	###
	sudo dnf -y install snapd
	sudo systemctl enable --now snapd.socket
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install snap-store
	sudo snap install snap-store
	sudo snap install code --classic
	sudo snap install slack --classic


	echo -e "${GREEN}##########################################"
	echo -e "Installing Foundry Products..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
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


	echo -e "${GREEN}##########################################"
	echo -e "Installing Substance Products..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
	wget https://download.substance3d.com/adobe-substance-3d-designer/11.x/Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	wget https://download.substance3d.com/adobe-substance-3d-painter/7.x/Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm
	sudo dnf -y install ./Adobe_Substance_3D*.rpm
	rm Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	rm Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm
	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Designer /opt/Adobe/Adobe_Substance_3D_Designer/Adobe\ Substance\ 3D\ Designer
	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Painter /opt/Adobe/Adobe_Substance_3D_Painter/Adobe\ Substance\ 3D\ Painter


	echo -e "${GREEN}##########################################"
	echo -e "Installing Houdini..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
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


	echo -e "${GREEN}##########################################"
	echo -e "Installing Davinci Resolve..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap/data
	chmod +x ./DaVinci_Resolve_Studio_17.2.2_Linux.run
	sudo ./DaVinci_Resolve_Studio_17.2.2_Linux.run -i
	sudo cp ./ResolveCrack/resolve /opt/resolve/bin/resolve
	rm ~/Desktop/com.blackmagicdesign.resolve.desktop


	echo -e "${GREEN}##########################################"
	echo -e "Installing RV Player..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap
	wget https://sg-software.ems.autodesk.com/deploy/rv/Current_Release/Linux-release.tar.gz
	sudo tar -C /opt -zxvf Linux-release.tar.gz
	sudo mv /opt/rv-centos7-x86-64-* /opt/RV
	rm Linux-release.tar.gz


	echo -e "${GREEN}##########################################"
	echo -e "Installing Maya..."
	echo -e "##########################################${NC}"
	###
	cd ~/bootstrap/data/Maya2022
	sudo dnf -y install ./Maya2022_64-2022.0-217.x86_64.rpm
	sudo cp ./maya.bin /usr/autodesk/maya2022/bin/maya.bin
	sudo mv /usr/autodesk/maya2022/bin/ADPClientService /usr/autodesk/maya2022/bin/ADPClientService_NOTHANKYOU
	mkdir -p ~/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo chmod a-rwx /home/mhamid/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo ln -s /usr/lib64/libssl.so.1.1 /usr/autodesk/maya2022/lib/libssl.so.10
	sudo ln -s /usr/lib64/libcrypto.so.1.1 /usr/autodesk/maya2022/lib/libcrypto.so.10

	cd /usr/autodesk/maya2022/lib/python3.7/lib-dynload
	sudo mkdir rhel
	sudo mv readline* rhel/
	sudo mv _ssl* rhel/
	sudo mv _hashlib* rhel/
	sudo cp -a /usr/autodesk/maya2022/support/python/3.7.7/readline* ./
	sudo cp -a /usr/autodesk/maya2022/support/python/3.7.7/libreadline* ./
	sudo cp -a /usr/autodesk/maya2022/support/python/3.7.7/_hashlib* ./
	sudo cp -a /usr/autodesk/maya2022/support/python/3.7.7/_ssl* ./

	sudo /usr/autodesk/maya2022/bin/mayapy -m pip install pymel



	# do usd stuff here


	echo -e "${GREEN}##########################################"
	echo -e "Patching Houdini..."
	echo -e "##########################################${NC}"
	###
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


}
