#!/usr/bin/bash


function confirm_data() {
	echo ""
	echo ""
	echo "Please download the data.tar file and place it in the /home/mhamid/bootstrap directory"
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

function run_installer() {

	echo "Updating & Installing required packages..."
	sudo apt -y update && sudo apt -y upgrade
	sudo apt -y install aptitude dconf-editor gnome-tweaks ntfs-3g obs-studio qbittorrent libglfw3-dev libglx-dev vlc unar nvidia-driver-470 cmake git alien mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev

	echo "Mounting Main disk..."
	sudo mkdir -p /mnt/mhamid/Main
	sudo chmod -R 777 /mnt/mhamid
	echo '/dev/sda2	/mnt/mhamid/Main	ntfs-3g defaults	0 0' | sudo tee -a /etc/fstab

	echo "Configuring gsettings..."
	gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
	dconf write /org/gtk/settings/file-chooser/show-hidden true
	gsettings set org.gnome.desktop.screensaver lock-enabled false


	echo "Installing Google Chrome..."
	cd ~
	mkdir bootstrap
	cd bootstrap
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt -y install ./google-chrome-stable_current_amd64.deb
	rm ./google-chrome-stable_current_amd64.deb


	until confirm_data; do : ; done

	tar -C /home/mhamid/bootstrap -xvf /home/mhamid/bootstrap/data.tar
	rm /home/mhamid/bootstrap/data.tar

	echo "Configuring favorite apps..."
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'google-chrome.desktop']"


	echo "Installing gnome shell extensions..."
	sudo apt -y install gnome-shell-extension-dash-to-panel gnome-shell-extension-system-monitor
	gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com', 'system-monitor@paradoxxx.zero.gmail.com']"
	sudo cp /usr/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/schemas/org.gnome.shell.extensions.system-monitor.gschema.xml /usr/share/glib-2.0/schemas/
	sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
	gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 42
	gsettings set org.gnome.shell.extensions.system-monitor cpu-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor memory-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor net-refresh-time 50
	gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 85
	gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 85

	echo "Configuring Wallpaper..."
	cd ~/Pictures
	wget https://w.wallhaven.cc/full/ox/wallhaven-oxoz6l.png
	dconf write /org/gnome/desktop/background/picture-uri "'file:///home/mhamid/Pictures/wallhaven-oxoz6l.png'"


	echo "Installing Anaconda..."
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
	pip install timeago
	ln -s ~/anaconda/envs/cometpy37/syncthing ~/anaconda/envs/cometpy37/bin/syncthing


	echo "Installing RLM..."
	cd /home/mhamid/bootstrap/data/RLM_Linux-64
	chmod +x ./rlm_install.sh
	sudo ./rlm_install.sh
	source /opt/rlm/rlmenvset.sh
	sudo systemctl daemon-reload
	sudo systemctl restart rlmd
	sudo systemctl enable rlmd


	echo "Installing PyCharm..."
	cd /home/mhamid/bootstrap/
	wget https://download-cdn.jetbrains.com/python/pycharm-community-2021.1.3.tar.gz
	sudo tar -C /opt -zxvf pycharm-community-2021.1.3.tar.gz
	rm ./pycharm-community-2021.1.3.tar.gz
	sudo mv /opt/pycharm-community-2021.1.3 /opt/PyCharm-Community-2021.1.3


	echo "Installing builds..."
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

	echo "Installing Snap apps..."
	sudo snap install code --classic
	sudo snap install slack --classic
	sudo snap install discord audacity postman inkscape


	echo "Installing Foundry Products..."
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


	echo "Installing Substance products..."
	cd /home/mhamid/bootstrap
	wget https://download.substance3d.com/adobe-substance-3d-designer/11.x/Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	wget https://download.substance3d.com/adobe-substance-3d-painter/7.x/Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm

	sudo alien --scripts Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	sudo alien --scripts Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm

	rm Adobe_Substance_3D_Designer-11.2.1-4934-linux-x64-standard.rpm
	rm Adobe_Substance_3D_Painter-7.2.3-1197-linux-x64-standard.rpm

	sudo apt -y install ./adobe-substance-3d-*.deb

	sudo rm adobe-*.deb

	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Designer /opt/Adobe/Adobe_Substance_3D_Designer/Adobe\ Substance\ 3D\ Designer
	sudo cp data/Substance_Patches/Adobe\ Substance\ 3D\ Painter /opt/Adobe/Adobe_Substance_3D_Painter/Adobe\ Substance\ 3D\ Painter


	echo "Installing Houdini 19..."
	cd /home/mhamid/bootstrap
	tar -zxvf data/houdini-19.0.383-linux_x86_64_gcc9.3.tar.gz
	cd houdini-19.0.383-linux_x86_64_gcc9.3/
	sudo ./houdini.install
	cd ..
	rm -rf ./houdini-19.0.383-linux_x86_64_gcc9.3
	cd /opt/hfs19.0.383
	source houdini_setup
	sudo systemctl daemon-reload
	sudo systemctl stop sesinetd
	sudo cp /home/mhamid/bootstrap/data/Houdini_Patches/sesinetd /usr/lib/sesi/sesinetd
	sudo systemctl start sesinetd
	sudo chmod +x /home/mhamid/bootstrap/data/Houdini_Patches/Houdini-Tools

	sesi_id=`/usr/lib/sesi/sesictrl print-server | grep SERVER | tr '\n' ' ' | awk '{print $NF}' | xargs`
	sesi_host=`/usr/lib/sesi/sesictrl print-server | grep SERVER | tr '\n' ' ' | awk '{print $(NF-1)}' | xargs`
	printf "$sesi_host\n$sesi_id" | /home/mhamid/bootstrap/data/Houdini_Patches/Houdini-Tools | grep -E 'SERVER|LICENSE' | sed 's/Enter server name:Enter server id://g' | tee /home/mhamid/bootstrap/hfs_keys.txt
	while IFS="" read hfs_key; do
		/usr/lib/sesi/sesictrl install "$hfs_key"
	done </home/mhamid/bootstrap/hfs_keys.txt

	unset sesi_id
	unset sesi_host
	rm /home/mhamid/bootstrap/hfs_keys.txt


	echo "Installing Davinci Resolve..."
	cd /home/mhamid/bootstrap/data
	chmod +x ./DaVinci_Resolve_Studio_17.2.2_Linux.run
	sudo ./DaVinci_Resolve_Studio_17.2.2_Linux.run -i
	sudo cp ./ResolveCrack/resolve /opt/resolve/bin/resolve
	rm ~/Desktop/com.blackmagicdesign.resolve.desktop


	echo "Installing RV Player..."
	cd /home/mhamid/bootstrap
	wget https://sg-software.ems.autodesk.com/deploy/rv/Current_Release/Linux-release.tar.gz
	sudo tar -C /opt -zxvf Linux-release.tar.gz
	sudo mv /opt/rv-centos7-x86-64-* /opt/RV
	rm Linux-release.tar.gz


	echo "Installing Maya..."
	cd /home/mhamid/bootstrap
	cp /home/mhamid/bootstrap/data/Maya2022/Maya2022_64-2022.0-217.x86_64.rpm /home/mhamid/bootstrap/
	sudo alien --scripts Maya2022_64-2022.0-217.x86_64.rpm
	rm Maya2022_64-2022.0-217.x86_64.rpm
	sudo apt -y install ./maya2022*.deb
	sudo rm maya2022*.deb
	sudo cp /home/mhamid/bootstrap/data/Maya2022/maya.bin /usr/autodesk/maya2022/bin/maya.bin
	sudo mv /usr/autodesk/maya2022/bin/ADPClientService /usr/autodesk/maya2022/bin/ADPClientService_NOTHANKYOU
	mkdir -p ~/.autodesk/UI/Autodesk/ADPSDK/JSON/
	sudo chmod a-rwx /home/mhamid/.autodesk/UI/Autodesk/ADPSDK/JSON/

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


	echo "Installing Pixar USD..."
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

	
	echo "Installing Maya USD..."
	cd ~/workspace
	git clone -b v0.14.0 https://github.com/Autodesk/maya-usd.git
	cd maya-usd
	mkdir workspace
	python build.py --build-args=-DBUILD_WITH_PYTHON_3=ON,-DBUILD_AL_PLUGIN=OFF,-DBUILD_STRICT_MODE=OFF --maya-location /usr/autodesk/maya2022 --pxrusd-location /opt/USD --devkit-location /builds/MayaDevkit/2022/devkitBase --qt-location /home/mhamid/anaconda/envs/cometpy37/lib workspace/
	sudo mkdir -p /usr/autodesk/mayausd/2022/
	sudo cp -r workspace/install/RelWithDebInfo/ /usr/autodesk/mayausd/2022/0.14.0
	sudo mv /usr/autodesk/mayausd/2022/0.14.0/plugin/pxr/lib/python/pxr/UsdMaya /opt/USD/lib/python/pxr/
	sudo chown mhamid:mhamid /opt/USD/lib/python/pxr/UsdMaya/
	sudo rm -rf /usr/autodesk/mayausd/2022/0.14.0/plugin/pxr/lib/python/pxr
	sudo mkdir -p /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.14.0/pxrUSD.mod /usr/autodesk/modules/maya/2022/
	sudo ln -s /usr/autodesk/mayausd/2022/0.14.0/mayaUSD.mod /usr/autodesk/modules/maya/2022/
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.14.0/pxrUSD.mod
	sudo chmod 777 /usr/autodesk/mayausd/2022/0.14.0/mayaUSD.mod
	sudo sed -i 's#/home/mhamid/workspace/maya-usd/workspace/install/RelWithDebInfo#/usr/autodesk/mayausd/2022/0.14.0#g' /usr/autodesk/mayausd/2022/0.14.0/mayaUSD.mod
	sudo sed -i 's#/home/mhamid/workspace/maya-usd/workspace/install/RelWithDebInfo#/usr/autodesk/mayausd/2022/0.14.0#g' /usr/autodesk/mayausd/2022/0.14.0/pxrUSD.mod


	echo "Pulling CometPipeline"
	conda activate cometpy37
	git config --global credential.helper store
	mkdir ~/_dev
	cd ~/_dev
	git clone https://github.com/CometPipeline/cometpipeline.git
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_activate.sh ~/anaconda/envs/cometpy37/etc/conda/activate.d/site_env_activate.sh
	ln -s ~/_dev/cometpipeline/src/cometpipeline/bin/site_env_deactivate.sh ~/anaconda/envs/cometpy37/etc/conda/deactivate.d/site_env_deactivate.sh


	cp /home/mhamid/bootstrap/data/.bash_default ~/.bash_default
	cp /home/mhamid/bootstrap/data/.bashrc ~/.bashrc

	echo "\n BOOTSTRAP DONE!!!"
	echo "\n"
}


function bootstrap_enter() {
	if [[ "${BASH_SOURCE[0]}" != "${0}" ]]
	then
		run_installer
	else
	echo "You must source this script: 'source ./<script>.sh"
	fi;
}


bootstrap_enter
