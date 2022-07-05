#!/bin/sh

error() {
  echo -e "\e[31mERROR: $1\e[0m" && exit 1
}

warning() {
  echo -e "\e[31mWARNING: $1\e[0m"
}

echo "########################################################"
echo "## This installation requires dialog as a dependency. ##"
echo "## We will first sync and update all repos.           ##"
echo "########################################################"
#sudo pacman --noconfirm --needed -Syu dialog base-devel

dialog --clear \
  --title 'Welcome to dwm install scrip' \
  --yes-label 'Continue' \
  --no-label 'Exit installation' \
  --yesno "This installation should not be run as root because of changes made to the $HOME directory.\
    For any uses of the sudo command we will ask for the sudo password" 10 60 \
|| error 'Exited by user'

if [ $UID = 0 ]; then
  error 'User is root. Please run  script as non root user'
fi

install_dwm() {
  echo -e '\e[36mInstalling dwm\e[0m'
#  sudo pacman --noconfirm --needed -S xorg-server xorg-xinit xorg-xrandr libxft libxinerama
#  [ -d $HOME/.config/dwm ] && mv $HOME/.config/dwm $HOME/.config/dwm-old
#  [ -d $HOME/.dwm ] && mv $HOME/.dwm $HOME/.dwm-old
#  [ ! -d $HOME/.config/dwm ] && mkdir -p $HOME/.config/dwm
#  [ ! -d $HOME/.dwm ] && mkdir -p $HOME/.dwm
#  git clone https://github.com/razvan171514/dwm.git $HOME/.config/dwm
#  cp $HOME/.config/dwm/autostart.sh $HOME/.dwm
#  chmod a+x $HOME/.dwm/autostart.sh
#  sudo make -C $HOME/.config/dwm clean install || warning "cannot install dwm"; return
#
#  dialog --clear \
#    --title 'Install optional packages' \
#    --yes-label 'Install' \
#    --no-label 'Continue without install' \
#    --yesno 'The autostart script uses nitrogen and picom. Do you want to install them?' 10 60 || return
#  sudo pacman --noconfirm --needed -S nitrogen picom
  echo -e '\e[36mDONE installing dwm\e[0m'
}

install_additional_package() {
    echo -e "\e[36mInstalling $1\e[0m"
#    [ -d $HOME/.config/$1 ] && mv $HOME/.config/$1 $HOME/.config/$1-old
#    [ ! -d $HOME/.config/$1 ] && mkdir -p $HOME/.config/$1
#    git clone "https://github.com/razvan171514/$1.git" $HOME/.config/$1
#    sudo make -C $HOME/.config/$1 clean install || warning "cannot install $1"; return
    echo -e "\e[36mDONE installing $1\e[0m"
}

base_install() {
  to_install=$(dialog --clear \
    --checklist 'Chose the packages to install. Use space to select option' 0 70 0 \
        1 'dwm - https://github.com/razvan171514/dwm.git' off \
        2 'dmenu - https://github.com/razvan171514/dmenu.git' off \
        3 'slstatus - https://github.com/razvan171514/slstatus.git' off \
        4 'st - https://github.com/razvan171514/st.git' off 3>&1 1>&2 2>&3 3>&-)

  for package in $to_install ; do
      case $package in
      1) install_dwm ;;
      2) install_additional_package dmenu ;;
      3) install_additional_package slstatus ;;
      4) install_additional_package st ;;
      *) error 'No such selection' ;;
      esac
  done
}

install_lightdm() {
  echo -e "\e[36mInstalling lightdm\e[0m"
#    [ -f /etc/lightdm/lightdm.conf ] && cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.old
#    sudo pacman --noconfirm --needed -S lightdm lightdm-gtk-greeter
#    sudo sed -i "s/$(grep 'greeter-session=' /etc/lightdm/lightdm.conf)/greeter-session=lightdm-gtk-greeter/" /etc/lightdm/lightdm.conf
  echo -e '\e[36mDONE installing lightdm\e[0m'
}

dm_install() {
  to_install=$(dialog --clear \
    --checklist 'The display manager to install. You can skip this step if needed.' 0 70 0 \
     1 'lightdm' on \
     2 'sddm' off 3>&1 1>&2 2>&3 3>&-)

  for package in $to_install ; do
      case $package in
      1) install_lightdm ;;
      *) echo -e '\e[31mNot yet supported\e[0m' ;;
      esac
  done
}

base_install && dm_install

#clear; echo -e '\e[32mDONE\e[0m'