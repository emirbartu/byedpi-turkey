#!/bin/bash

set -e

installdir="/home/$USER/.local/share"

if [[ ! -f /bin/git ]]; then
    echo "sisteminizde 'git' bulunamadi."
    echo "otomatik olarak kuruluyor... lutfen sudo sifresi isterse girin."
    if [[ -f /bin/pacman ]]; then
        sudo pacman -S git
    fi

    if [[ -f /bin/dnf ]]; then
        sudo dnf install git
    fi

    if [[ -f /bin/apt ]]; then
        sudo apt install git
    fi
fi

if [[ -d ${installdir}/byedpi-turkey ]]; then
    rm -r ${installdir}/byedpi-turkey
fi

cd $installdir

git clone https://github.com/elrondforwin/byedpi-turkey.git

cd byedpi-turkey

bash kurulum.sh