#!/bin/sh

error() {
    clear; printf "Error: %s\n" "$1"; exit 1
}

echo "########################################################"
echo "## This installation requires dialog as a dependency. ##"
echo "## We will first synk and update all repos.           ##"
echo "########################################################"
#sudo pacman --noconfirm --needed -Syu dialog make || error "Error synking the repos."

dialog --clear --title 'Welcome to dwm install scrip'\
    --yes-label 'Continue'\
    --no-label 'Exit installation'\
    --yesno 'This installation should not be run as root becaues of changes made to the $HOME directory. For any uses of the sudo command we will ask for the sudo password' 10 60 || error 'Exited by user'

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
	    1) echo "1" ;;
	    2) echo "2" ;;
	    3) echo "3" ;;
	    4) echo "4" ;;
	esac
    done
}

install_dwm_desktop || error "Wrong choice"

