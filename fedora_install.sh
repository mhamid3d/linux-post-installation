#!/bin/bash


RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'


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
sudo dnf -y install google-chrome-stable obs-studio gnome-tweaks dconf-editor ntfs-3g cmake curl glfw glfw-devel libpng-devel mesa-libGLw-devel qbittorrent wine vlc unar gparted libzip-devel gnome-extensions-app file-roller file-roller-nautilus


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
gnome-extensions disable background-logo@fedorahosted.org
#gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com', 'system-monitor@paradoxxx.zero.gmail.com']"
gsettings set org.gnome.shell enabled-extensions "['dash-to-panel@jderose9.github.com']"
gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 42
gsettings set org.gnome.shell.extensions.dash-to-panel trans-use-custom-opacity true
gsettings set org.gnome.shell.extensions.dash-to-panel trans-panel-opacity 0.4
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
wget https://w.wallhaven.cc/full/ox/wallhaven-oxoz6l.png
dconf write /org/gnome/desktop/background/picture-uri "'file:///home/mhamid/Pictures/wallhaven-oxoz6l.png'"


echo -e "${GREEN}##########################################"
echo -e "Changing Host name..."
echo -e "##########################################${NC}"
###
sudo hostnamectl set-hostname fedora
echo '127.0.0.1 localhost fedora' | sudo tee -a /etc/hosts


echo -e "${GREEN}##########################################"
echo -e "Installing NVIDIA Drivers..."
echo -e "##########################################${NC}"
###
sudo dnf -y install akmod-nvidia
