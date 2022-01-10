#!/bin/sh

error() {
    clear; printf "Error: %s\n" "$1"; exit 1
}

echo "########################################################"
echo "## This installation requires dialog as a dependency. ##"
echo "## We will first synk and update all repos.           ##"
echo "########################################################"
sudo pacman --noconfirm --needed -Syu dialog sed make base-devel xorg-server xorg-xinit xorg-xrandr libxft libxinerama || error "Error synking the repos."

dialog --clear --title 'Welcome to dwm install scrip'\
    --yes-label 'Continue'\
    --no-label 'Exit installation'\
    --yesno "This installation should not be run as root becaues of changes made to the $HOME directory. For any uses of the sudo command we will ask for the sudo password" 10 60 || error 'Exited by user'

if [[ $(id -u) = 0 ]]; then
    error "User is not supposed to be root. Please run installation as a normal user."
fi

last_worning() {
    dialog --clear --title 'Last worning'\
	--yes-label 'Begin installation'\
	--no-label 'Exit installation'\
	--yesno 'The installation is about to begin.' 10 60 || error "Installation aboarted"
}

last_worning || error "Wrong choice"

install_dwm() {
    echo "Installing dwm"
    [ -d $HOME/.config/dwm ] && mv $HOME/.config/dwm $HOME/.config/dwm-old
    [ -d $HOME/.dwm ] && mv $HOME/.dwm $HOME/.dwm-old
    [ ! -d $HOME/.config/dwm ] && mkdir -p $HOME/.config/dwm
    [ ! -d $HOME/.dwm ] && mkdir -p $HOME/.dwm
    git clone https://github.com/razvan171514/dwm.git $HOME/.config/dwm
    cp $HOME/.config/dwm/autostart.sh $HOME/.dwm
    chmod a+x $HOME/.dwm/autostart.sh
    sudo make -C $HOME/.config/dwm clean install
    sudo pacman --noconfirm --needed -S nitrogen picom
    echo "DONE"
}

install_dwm_additional_package() {
    echo "Installing $1"
    [ -d $HOME/.config/$1 ] && mv $HOME/.config/$1 $HOME/.config/$1-old
    [ ! -d $HOME/.config/$1 ] && mkdir -p $HOME/.config/$1
    git clone "https://github.com/razvan171514/$1.git" $HOME/.config/$1
    sudo make -C $HOME/.config/$1 clean install
    echo 'DONE'
}

install_dwm_desktop() {
    choices=$(dialog --clear\
	--checklist 'Chose the packages to install. Use space to select option' 0 70 0\
	    1 'dwm - https://github.com/razvan171514/dwm.git' off\
	    2 'dmenu - https://github.com/razvan171514/dmenu.git' off\
	    3 'slstatus - https://github.com/razvan171514/slstatus.git' off\
	    4 'st - https://github.com/razvan171514/st.git' off 3>&1 1>&2 2>&3 3>&-)
    for package in $choices 
    do
	case $package in
	    1) install_dwm ;;
	    2) install_dwm_additional_package dmenu ;; 
	    3) install_dwm_additional_package slstatus ;;
	    4) install_dwm_additional_package st ;;
	esac
    done
}

#install_dwm_desktop || error "Wrong choice"

install_lightdm() {
    [ -f /etc/lightdm/lightdm.conf ] && cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.old
    sudo pacman --noconfirm --needed -S lightdm lightdm-gtk-greeter
    sudo sed -i "s/$(grep 'greeter-session=' /etc/lightdm/lightdm.conf)/greeter-sesstion=lightdm-gtk-greeter/" /etc/lightdm/lightdm.conf
}

install_sddm() {
    sudo pacman --noconfirm --needed -S sddm
}

#TODO: Make configuration for xdm
install_xdm() {
    sudo pacman --noconfirm --needed -S xdm-archlinux
}

#TODO: Problem when starting dm (it stops the install script) 
enable_dm() {
    echo "Enableing $1"
    if [ -f /etc/systemd/system/display-manager.service ]; then
	echo "Disableing allready existing display manager"
	sudo systemctl disable display-manager.serveice 
	sudo systemctl stop display-manager.serveice
    fi
    sudo systemctl enable "$1"
#    sudo systemctl start "$1"
    echo "DONE"
}

install_diaplay_manager() {
    declare -a dms=('lightdm' 'sddm' 'xdm-archlinux')
    choices=$(dialog --clear\
	--cancel-label 'Skip'\
	--checklist 'Chose display managers to install. Use space to select option' 0 70 0\
	     $(echo "${dms[@]}" | sed 's/ /\n/g' | awk '{print NR, $1, "off"}') 3>&1 1>&2 2>&3 3>&-)
    declare -a chosen_dms=()
    for package in $choices 
    do
	chosen_dms+=("${dms[${package}-1]}")
	case $package in
	    1) echo "";; #install_lightdm ;;
	    2) echo "";; #install_sddm ;; 
	    *) echo "";; #echo 'Option not supported yet' ;;
	esac
    done
    dm_to_enable=$(dialog --clear\
	--cancel-label 'Skip'\
	--menu 'Chose display manager to enable' 0 70 0\
	    $(echo ${chosen_dms[@]} | sed 's/ /\n/g' | awk '{print NR, $1}') 3>&1 1>&2 2>&3 3>&-)
    enable_dm "${chosen_dms[${dm_to_enable}-1]}" || error "Cannot enable $dm_to_enable"
}

install_diaplay_manager || error "Wrong choice"

