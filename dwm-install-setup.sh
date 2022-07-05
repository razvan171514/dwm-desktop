#!/bin/sh

echo -e '\e[36mINFO: Creating installer script\e[0m'
sed 's/^#//' dwm-install-dev.sh | sed 's/^!/#!/' > dwm-install.sh

echo -e '\e[36mINFO: Adding execute permissions for installer\e[0m'
chmod ug+x dwm-install.sh

echo -e '\e[32mDONE\e[0m'